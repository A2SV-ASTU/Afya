package appointments

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type Repository interface {
	Create(ctx context.Context, appt *Appointment) error
	FindByPatientID(ctx context.Context, patientID uuid.UUID, status *AppointmentStatus) ([]Appointment, error)
	FindByID(ctx context.Context, id uuid.UUID) (*Appointment, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status AppointmentStatus, updatedAt time.Time) error
}

type postgresRepository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Create(ctx context.Context, appt *Appointment) error {
	query := `
		INSERT INTO appointments (id, clinic_id, doctor_id, patient_id, scheduled_at, status, notes, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`

	_, err := r.db.ExecContext(ctx, query,
		appt.ID, appt.ClinicID, appt.DoctorID, appt.PatientID,
		appt.ScheduledAt, appt.Status, appt.Notes, appt.CreatedAt, appt.UpdatedAt,
	)
	return err
}

func (r *postgresRepository) FindByPatientID(ctx context.Context, patientID uuid.UUID, status *AppointmentStatus) ([]Appointment, error) {
	query := `
		SELECT id, clinic_id, doctor_id, patient_id, scheduled_at, status, notes, created_at, updated_at
		FROM appointments
		WHERE patient_id = $1`

	args := []interface{}{patientID}
	if status != nil {
		query += ` AND status = $2`
		args = append(args, *status)
	}

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var appointments []Appointment
	for rows.Next() {
		var a Appointment
		err := rows.Scan(
			&a.ID, &a.ClinicID, &a.DoctorID, &a.PatientID,
			&a.ScheduledAt, &a.Status, &a.Notes, &a.CreatedAt, &a.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		appointments = append(appointments, a)
	}

	if appointments == nil {
		return []Appointment{}, nil
	}
	return appointments, nil
}

func (r *postgresRepository) FindByID(ctx context.Context, id uuid.UUID) (*Appointment, error) {
	query := `
		SELECT id, clinic_id, doctor_id, patient_id, scheduled_at, status, notes, created_at, updated_at
		FROM appointments
		WHERE id = $1`

	var a Appointment
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&a.ID, &a.ClinicID, &a.DoctorID, &a.PatientID,
		&a.ScheduledAt, &a.Status, &a.Notes, &a.CreatedAt, &a.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &a, nil
}

func (r *postgresRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status AppointmentStatus, updatedAt time.Time) error {
	query := `
		UPDATE appointments
		SET status = $1, updated_at = $2
		WHERE id = $3`

	_, err := r.db.ExecContext(ctx, query, status, updatedAt, id)
	return err
}
