package vitals

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"afyamind-backend/src/database"

	"github.com/google/uuid"
)

var ErrVitalNotFound = errors.New("vital sign not found")

type Repository interface {
	Insert(ctx context.Context, v *VitalSign) error
	UpsertByClientID(ctx context.Context, v *VitalSign) (id uuid.UUID, created bool, err error)
	ListByPatient(ctx context.Context, patientID uuid.UUID, from, to *time.Time, source *VitalSource) ([]VitalSign, error)
	ListUnackedClinicVitals(ctx context.Context, patientID uuid.UUID, since *time.Time) ([]VitalSign, error)
	AckVitals(ctx context.Context, patientID uuid.UUID, vitalIDs []uuid.UUID) error
	FindPatientIDByEncounter(ctx context.Context, encounterID uuid.UUID) (uuid.UUID, error)
}

type repository struct {
	db database.DBTX
}

func NewRepository(db database.DBTX) Repository {
	return &repository{db: db}
}

const vitalColumns = `id, encounter_id, patient_id, source, client_id,
	systolic_bp, diastolic_bp, pulse, respiratory_rate,
	temperature, spo2, blood_sugar, weight, recorded_at`

type rowScanner interface {
	Scan(dest ...interface{}) error
}

func scanVital(r rowScanner) (VitalSign, error) {
	var v VitalSign
	err := r.Scan(
		&v.ID, &v.EncounterID, &v.PatientID, &v.Source, &v.ClientID,
		&v.SystolicBP, &v.DiastolicBP, &v.Pulse, &v.RespiratoryRate,
		&v.Temperature, &v.SpO2, &v.BloodSugar, &v.Weight, &v.RecordedAt,
	)
	return v, err
}

func (r *repository) Insert(ctx context.Context, v *VitalSign) error {
	query := `
		INSERT INTO vital_signs
			(encounter_id, patient_id, source, client_id,
			 systolic_bp, diastolic_bp, pulse, respiratory_rate,
			 temperature, spo2, blood_sugar, weight, recorded_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
		RETURNING id`
	return r.db.QueryRowContext(ctx, query,
		v.EncounterID, v.PatientID, string(v.Source), v.ClientID,
		v.SystolicBP, v.DiastolicBP, v.Pulse, v.RespiratoryRate,
		v.Temperature, v.SpO2, v.BloodSugar, v.Weight, v.RecordedAt,
	).Scan(&v.ID)
}

func (r *repository) UpsertByClientID(ctx context.Context, v *VitalSign) (uuid.UUID, bool, error) {
	insertQuery := `
		INSERT INTO vital_signs
			(encounter_id, patient_id, source, client_id,
			 systolic_bp, diastolic_bp, pulse, respiratory_rate,
			 temperature, spo2, blood_sugar, weight, recorded_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
		ON CONFLICT (patient_id, client_id) WHERE client_id IS NOT NULL
		DO NOTHING
		RETURNING id`

	var id uuid.UUID
	err := r.db.QueryRowContext(ctx, insertQuery,
		v.EncounterID, v.PatientID, string(v.Source), v.ClientID,
		v.SystolicBP, v.DiastolicBP, v.Pulse, v.RespiratoryRate,
		v.Temperature, v.SpO2, v.BloodSugar, v.Weight, v.RecordedAt,
	).Scan(&id)

	if err == nil {
		return id, true, nil
	}
	if !errors.Is(err, sql.ErrNoRows) {
		return uuid.Nil, false, fmt.Errorf("upsert vital failed: %w", err)
	}

	err = r.db.QueryRowContext(ctx,
		`SELECT id FROM vital_signs WHERE patient_id = $1 AND client_id = $2`,
		v.PatientID, v.ClientID,
	).Scan(&id)
	if err != nil {
		return uuid.Nil, false, fmt.Errorf("lookup existing vital failed: %w", err)
	}
	return id, false, nil
}

func (r *repository) ListByPatient(ctx context.Context, patientID uuid.UUID, from, to *time.Time, source *VitalSource) ([]VitalSign, error) {
	q := fmt.Sprintf(`SELECT %s FROM vital_signs WHERE patient_id = $1`, vitalColumns)
	args := []interface{}{patientID}
	n := 2

	if from != nil {
		q += fmt.Sprintf(` AND recorded_at >= $%d`, n)
		args = append(args, *from)
		n++
	}
	if to != nil {
		q += fmt.Sprintf(` AND recorded_at <= $%d`, n)
		args = append(args, *to)
		n++
	}
	if source != nil {
		q += fmt.Sprintf(` AND source = $%d`, n)
		args = append(args, string(*source))
	}
	q += ` ORDER BY recorded_at DESC`

	rows, err := r.db.QueryContext(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var out []VitalSign
	for rows.Next() {
		v, err := scanVital(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, v)
	}
	if out == nil {
		return []VitalSign{}, nil
	}
	return out, nil
}

func (r *repository) ListUnackedClinicVitals(ctx context.Context, patientID uuid.UUID, since *time.Time) ([]VitalSign, error) {
	q := fmt.Sprintf(`
		SELECT %s
		FROM vital_signs vs
		LEFT JOIN vitals_sync_acks ack
		  ON ack.vital_id = vs.id AND ack.patient_id = vs.patient_id
		WHERE vs.patient_id = $1
		  AND vs.source = 'clinic'
		  AND ack.vital_id IS NULL`, vitalColumns)

	args := []interface{}{patientID}
	if since != nil {
		q += ` AND vs.recorded_at > $2`
		args = append(args, *since)
	}
	q += ` ORDER BY vs.recorded_at ASC`

	rows, err := r.db.QueryContext(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var out []VitalSign
	for rows.Next() {
		v, err := scanVital(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, v)
	}
	if out == nil {
		return []VitalSign{}, nil
	}
	return out, nil
}

func (r *repository) AckVitals(ctx context.Context, patientID uuid.UUID, vitalIDs []uuid.UUID) error {
	for _, vid := range vitalIDs {
		_, err := r.db.ExecContext(ctx,
			`INSERT INTO vitals_sync_acks (patient_id, vital_id)
			 VALUES ($1, $2)
			 ON CONFLICT (patient_id, vital_id) DO NOTHING`,
			patientID, vid,
		)
		if err != nil {
			return fmt.Errorf("ack vital %s: %w", vid, err)
		}
	}
	return nil
}

func (r *repository) FindPatientIDByEncounter(ctx context.Context, encounterID uuid.UUID) (uuid.UUID, error) {
	var pid uuid.UUID
	err := r.db.QueryRowContext(ctx,
		`SELECT patient_id FROM encounters WHERE id = $1`, encounterID,
	).Scan(&pid)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return uuid.Nil, ErrVitalNotFound
		}
		return uuid.Nil, err
	}
	return pid, nil
}
