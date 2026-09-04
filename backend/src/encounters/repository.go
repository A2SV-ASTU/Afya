package encounters

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/google/uuid"
)

type Repository interface {
	Create(ctx context.Context, patientID, clinicID, doctorID uuid.UUID) (*Encounter, error)
	FindByID(ctx context.Context, id uuid.UUID) (*Encounter, error)
	HasOpenEncounter(ctx context.Context, patientID uuid.UUID) (bool, error)
	ListByPatientID(ctx context.Context, patientID uuid.UUID, limit, offset int) ([]Encounter, int, error)
	CloseEncounter(ctx context.Context, id uuid.UUID) (*Encounter, error)
	GetAggregatedEncounter(ctx context.Context, id uuid.UUID) (*AggregatedEncounterResponse, error)
	GetMedicalHistorySummary(ctx context.Context, encounterID uuid.UUID) (*MedicalHistoryResponse, error)
}

type repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) Repository {
	return &repository{db: db}
}

func (r *repository) Create(ctx context.Context, patientID, clinicID, doctorID uuid.UUID) (*Encounter, error) {
	query := `
		INSERT INTO encounters (patient_id, clinic_id, opened_by_doctor_id, status, started_at, created_at)
		VALUES ($1, $2, $3, $4, NOW(), NOW())
		RETURNING id, patient_id, clinic_id, opened_by_doctor_id, status, started_at, ended_at, created_at
	`
	var e Encounter
	err := r.db.QueryRowContext(ctx, query, patientID, clinicID, doctorID, StatusOpen).Scan(
		&e.ID, &e.PatientID, &e.ClinicID, &e.OpenedByDoctorID, &e.Status, &e.StartedAt, &e.EndedAt, &e.CreatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create encounter: %w", err)
	}
	return &e, nil
}

func (r *repository) FindByID(ctx context.Context, id uuid.UUID) (*Encounter, error) {
	query := `
		SELECT id, patient_id, clinic_id, opened_by_doctor_id, status, started_at, ended_at, created_at
		FROM encounters
		WHERE id = $1
	`
	var e Encounter
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&e.ID, &e.PatientID, &e.ClinicID, &e.OpenedByDoctorID, &e.Status, &e.StartedAt, &e.EndedAt, &e.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to find encounter by id: %w", err)
	}
	return &e, nil
}

func (r *repository) HasOpenEncounter(ctx context.Context, patientID uuid.UUID) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM encounters WHERE patient_id = $1 AND status = 'open')`
	var exists bool
	err := r.db.QueryRowContext(ctx, query, patientID).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("failed to check open encounter: %w", err)
	}
	return exists, nil
}

func (r *repository) ListByPatientID(ctx context.Context, patientID uuid.UUID, limit, offset int) ([]Encounter, int, error) {
	countQuery := `SELECT COUNT(*) FROM encounters WHERE patient_id = $1`
	var total int
	if err := r.db.QueryRowContext(ctx, countQuery, patientID).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("failed to count encounters: %w", err)
	}

	query := `
		SELECT id, patient_id, clinic_id, opened_by_doctor_id, status, started_at, ended_at, created_at
		FROM encounters
		WHERE patient_id = $1
		ORDER BY started_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.QueryContext(ctx, query, patientID, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list encounters: %w", err)
	}
	defer rows.Close()

	var result []Encounter
	for rows.Next() {
		var e Encounter
		if err := rows.Scan(&e.ID, &e.PatientID, &e.ClinicID, &e.OpenedByDoctorID, &e.Status, &e.StartedAt, &e.EndedAt, &e.CreatedAt); err != nil {
			return nil, 0, fmt.Errorf("failed to scan encounter: %w", err)
		}
		result = append(result, e)
	}
	if result == nil {
		result = []Encounter{}
	}
	return result, total, nil
}

func (r *repository) CloseEncounter(ctx context.Context, id uuid.UUID) (*Encounter, error) {
	query := `
		UPDATE encounters
		SET status = 'closed', ended_at = NOW()
		WHERE id = $1
		RETURNING id, patient_id, clinic_id, opened_by_doctor_id, status, started_at, ended_at, created_at
	`
	var e Encounter
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&e.ID, &e.PatientID, &e.ClinicID, &e.OpenedByDoctorID, &e.Status, &e.StartedAt, &e.EndedAt, &e.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to close encounter: %w", err)
	}
	return &e, nil
}

func (r *repository) GetAggregatedEncounter(ctx context.Context, id uuid.UUID) (*AggregatedEncounterResponse, error) {
	enc, err := r.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if enc == nil {
		return nil, nil
	}

	res := &AggregatedEncounterResponse{
		Encounter:     *enc,
		Vitals:        []VitalSignDTO{},
		Labs:          []LabResultDTO{},
		Diagnoses:     []DiagnosisDTO{},
		Prescriptions: []PrescriptionDTO{},
	}

	// Fetch Vitals
	vitalsQuery := `
		SELECT id, encounter_id, patient_id, source, systolic_bp, diastolic_bp, pulse, respiratory_rate, temperature, spo2, blood_sugar, weight, recorded_at
		FROM vital_signs WHERE encounter_id = $1 ORDER BY recorded_at ASC
	`
	vRows, err := r.db.QueryContext(ctx, vitalsQuery, id)
	if err == nil {
		defer vRows.Close()
		for vRows.Next() {
			var v VitalSignDTO
			if err := vRows.Scan(&v.ID, &v.EncounterID, &v.PatientID, &v.Source, &v.SystolicBP, &v.DiastolicBP, &v.Pulse, &v.RespiratoryRate, &v.Temperature, &v.Spo2, &v.BloodSugar, &v.Weight, &v.RecordedAt); err == nil {
				res.Vitals = append(res.Vitals, v)
			}
		}
	}

	// Fetch Labs
	labsQuery := `
		SELECT id, encounter_id, test_name, category, summary_notes, measurements, flag, created_at
		FROM lab_results WHERE encounter_id = $1 ORDER BY created_at ASC
	`
	lRows, err := r.db.QueryContext(ctx, labsQuery, id)
	if err == nil {
		defer lRows.Close()
		for lRows.Next() {
			var l LabResultDTO
			var rawMeasurements []byte
			var summary sql.NullString
			var flag sql.NullString
			if err := lRows.Scan(&l.ID, &l.EncounterID, &l.TestName, &l.Category, &summary, &rawMeasurements, &flag, &l.CreatedAt); err == nil {
				l.SummaryNotes = summary.String
				if flag.Valid {
					l.Flag = &flag.String
				}
				if len(rawMeasurements) > 0 {
					var parsed interface{}
					_ = json.Unmarshal(rawMeasurements, &parsed)
					l.Measurements = parsed
				}
				res.Labs = append(res.Labs, l)
			}
		}
	}

	// Fetch Diagnoses
	diagQuery := `
		SELECT id, encounter_id, diagnosis_text, icd_code, diagnosis_type, notes, diagnosed_at
		FROM diagnoses WHERE encounter_id = $1 ORDER BY diagnosed_at ASC
	`
	dRows, err := r.db.QueryContext(ctx, diagQuery, id)
	if err == nil {
		defer dRows.Close()
		for dRows.Next() {
			var d DiagnosisDTO
			var icd, notes sql.NullString
			if err := dRows.Scan(&d.ID, &d.EncounterID, &d.DiagnosisText, &icd, &d.DiagnosisType, &notes, &d.DiagnosedAt); err == nil {
				if icd.Valid {
					d.ICDCode = &icd.String
				}
				if notes.Valid {
					d.Notes = &notes.String
				}
				res.Diagnoses = append(res.Diagnoses, d)
			}
		}
	}

	// Fetch Prescriptions
	pQuery := `
		SELECT id, encounter_id, notes, prescribed_at
		FROM prescriptions WHERE encounter_id = $1 ORDER BY prescribed_at ASC
	`
	pRows, err := r.db.QueryContext(ctx, pQuery, id)
	if err == nil {
		defer pRows.Close()
		for pRows.Next() {
			var p PrescriptionDTO
			var notes sql.NullString
			if err := pRows.Scan(&p.ID, &p.EncounterID, &notes, &p.PrescribedAt); err == nil {
				if notes.Valid {
					p.Notes = &notes.String
				}
				p.Items = []PrescriptionItemDTO{}

				// Fetch prescription items
				itemQuery := `
					SELECT id, prescription_id, medication_name, dose, route, frequency, duration_value, duration_unit, status, instructions, started_at
					FROM prescription_items WHERE prescription_id = $1 ORDER BY started_at ASC
				`
				iRows, itemErr := r.db.QueryContext(ctx, itemQuery, p.ID)
				if itemErr == nil {
					for iRows.Next() {
						var item PrescriptionItemDTO
						var instr sql.NullString
						if err := iRows.Scan(&item.ID, &item.PrescriptionID, &item.MedicationName, &item.Dose, &item.Route, &item.Frequency, &item.DurationValue, &item.DurationUnit, &item.Status, &instr, &item.StartedAt); err == nil {
							if instr.Valid {
								item.Instructions = &instr.String
							}
							p.Items = append(p.Items, item)
						}
					}
					iRows.Close()
				}

				res.Prescriptions = append(res.Prescriptions, p)
			}
		}
	}

	return res, nil
}

func (r *repository) GetMedicalHistorySummary(ctx context.Context, encounterID uuid.UUID) (*MedicalHistoryResponse, error) {
	enc, err := r.FindByID(ctx, encounterID)
	if err != nil {
		return nil, err
	}
	if enc == nil {
		return nil, nil
	}

	res := &MedicalHistoryResponse{
		EncounterID:  enc.ID,
		Date:         enc.StartedAt,
		Prescription: []MedicalHistoryPrescriptionItem{},
	}

	// Chief Complaint from clinical_evaluations
	ccQuery := `SELECT chief_complaint FROM clinical_evaluations WHERE encounter_id = $1`
	var cc string
	err = r.db.QueryRowContext(ctx, ccQuery, encounterID).Scan(&cc)
	if err == nil {
		res.ChiefComplaint = cc
	}

	// Latest diagnosis text from diagnoses
	diagQuery := `SELECT diagnosis_text FROM diagnoses WHERE encounter_id = $1 ORDER BY diagnosed_at DESC LIMIT 1`
	var diag string
	err = r.db.QueryRowContext(ctx, diagQuery, encounterID).Scan(&diag)
	if err == nil {
		res.Diagnosis = &diag
	}

	// Prescription items
	rxQuery := `
		SELECT pi.medication_name, pi.dose, pi.route, pi.frequency, pi.duration_value, pi.duration_unit
		FROM prescription_items pi
		JOIN prescriptions p ON pi.prescription_id = p.id
		WHERE p.encounter_id = $1
		ORDER BY pi.started_at ASC
	`
	rxRows, err := r.db.QueryContext(ctx, rxQuery, encounterID)
	if err == nil {
		defer rxRows.Close()
		for rxRows.Next() {
			var item MedicalHistoryPrescriptionItem
			if err := rxRows.Scan(&item.MedicationName, &item.Dose, &item.Route, &item.Frequency, &item.DurationValue, &item.DurationUnit); err == nil {
				res.Prescription = append(res.Prescription, item)
			}
		}
	}

	// Vitals
	vitalsQuery := `
		SELECT systolic_bp, diastolic_bp, pulse, respiratory_rate, temperature, spo2, blood_sugar, weight
		FROM vital_signs
		WHERE encounter_id = $1
		ORDER BY recorded_at DESC LIMIT 1
	`
	var v MedicalHistoryVitals
	err = r.db.QueryRowContext(ctx, vitalsQuery, encounterID).Scan(
		&v.SystolicBP, &v.DiastolicBP, &v.Pulse, &v.RespiratoryRate, &v.Temperature, &v.Spo2, &v.BloodSugar, &v.Weight,
	)
	if err == nil {
		res.Vitals = &v
	}

	return res, nil
}
