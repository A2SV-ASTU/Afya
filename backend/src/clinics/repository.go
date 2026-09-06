package clinics

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"afyamind-backend/src/database"

	"github.com/google/uuid"
)

var ErrClinicNotFound = errors.New("clinic not found")

type Repository interface {
	Create(ctx context.Context, clinic *Clinic) error
	FindByID(ctx context.Context, id uuid.UUID) (*Clinic, error)
	FindByEmail(ctx context.Context, email string) (*Clinic, error)
	ListAll(ctx context.Context) ([]*Clinic, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status string) error
	DeactivateDoctor(ctx context.Context, clinicID, doctorID uuid.UUID) error
	ActivateDoctor(ctx context.Context, clinicID, doctorID uuid.UUID) error
	UpdateDoctorProfile(ctx context.Context, clinicID, doctorID uuid.UUID, specialization, licenseNumber *string) (*DoctorResponse, error)

	FindDoctorsByClinicID(ctx context.Context, clinicID uuid.UUID) ([]DoctorResponse, error)
	FindInvitationsByClinicID(ctx context.Context, clinicID uuid.UUID) ([]InvitationResponse, error)


}

type repository struct {
	db database.DBTX
}

func NewRepository(db database.DBTX) Repository {
	return &repository{db: db}
}

const clinicColumns = `id, name, email, phone, address, status, created_at, updated_at`

type scanner interface {
	Scan(dest ...interface{}) error
}

func scanClinic(s scanner) (*Clinic, error) {
	c := &Clinic{}
	var phone sql.NullString
	var address sql.NullString

	err := s.Scan(
		&c.ID,
		&c.Name,
		&c.Email,
		&phone,
		&address,
		&c.Status,
		&c.CreatedAt,
		&c.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrClinicNotFound
		}
		return nil, err
	}
	if phone.Valid {
		c.Phone = phone.String
	}
	if address.Valid {
		c.Address = address.String
	}
	return c, nil
}

func (r *repository) Create(ctx context.Context, clinic *Clinic) error {
	query := `
		INSERT INTO clinics (name, email, phone, address, status, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
		RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRowContext(
		ctx,
		query,
		clinic.Name,
		clinic.Email,
		clinic.Phone,
		clinic.Address,
		clinic.Status,
	).Scan(&clinic.ID, &clinic.CreatedAt, &clinic.UpdatedAt)

	if err != nil {
		return fmt.Errorf("failed to insert clinic: %w", err)
	}

	return nil
}

func (r *repository) FindByID(ctx context.Context, id uuid.UUID) (*Clinic, error) {
	query := fmt.Sprintf(`SELECT %s FROM clinics WHERE id = $1`, clinicColumns)
	return scanClinic(r.db.QueryRowContext(ctx, query, id))
}

func (r *repository) FindByEmail(ctx context.Context, email string) (*Clinic, error) {
	query := fmt.Sprintf(`SELECT %s FROM clinics WHERE email = $1`, clinicColumns)
	return scanClinic(r.db.QueryRowContext(ctx, query, email))
}

func (r *repository) ListAll(ctx context.Context) ([]*Clinic, error) {
	query := fmt.Sprintf(`SELECT %s FROM clinics ORDER BY created_at DESC`, clinicColumns)
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("failed to list clinics: %w", err)
	}
	defer rows.Close()

	var clinics []*Clinic
	for rows.Next() {
		c, err := scanClinic(rows)
		if err != nil {
			return nil, err
		}
		clinics = append(clinics, c)
	}
	return clinics, nil
}

func (r *repository) UpdateStatus(ctx context.Context, id uuid.UUID, status string) error {
	query := `
		UPDATE clinics
		SET status = $1, updated_at = NOW()
		WHERE id = $2
	`
	res, err := r.db.ExecContext(ctx, query, status, id)
	if err != nil {
		return fmt.Errorf("failed to update clinic status: %w", err)
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return ErrClinicNotFound
	}
	return nil
}

func (r *repository) DeactivateDoctor(ctx context.Context, clinicID, doctorID uuid.UUID) error {
	query := `
		UPDATE users
		SET doctor_status = 'deactivated', updated_at = NOW()
		WHERE id = $1 AND clinic_id = $2 AND role = 'doctor'
	`
	res, err := r.db.ExecContext(ctx, query, doctorID, clinicID)
	if err != nil {
		return fmt.Errorf("failed to deactivate doctor: %w", err)
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return errors.New("doctor not found in this clinic")
	}
	return nil
}

func (r *repository) ActivateDoctor(ctx context.Context, clinicID, doctorID uuid.UUID) error {
	query := `
		UPDATE users
		SET doctor_status = 'active', updated_at = NOW()
		WHERE id = $1 AND clinic_id = $2 AND role = 'doctor'
	`
	res, err := r.db.ExecContext(ctx, query, doctorID, clinicID)
	if err != nil {
		return fmt.Errorf("failed to activate doctor: %w", err)
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return errors.New("doctor not found in this clinic")
	}
	return nil
}

func (r *repository) UpdateDoctorProfile(ctx context.Context, clinicID, doctorID uuid.UUID, specialization, licenseNumber *string) (*DoctorResponse, error) {
	query := `
		UPDATE users
		SET specialization = COALESCE($1, specialization),
		    license_number = COALESCE($2, license_number),
		    updated_at = NOW()
		WHERE id = $3 AND clinic_id = $4 AND role = 'doctor'
		RETURNING id, first_name, last_name, role, phone, email, specialization, license_number, doctor_status, invited_by, created_at
	`
	var d DoctorResponse
	err := r.db.QueryRowContext(ctx, query, specialization, licenseNumber, doctorID, clinicID).Scan(
		&d.ID, &d.FirstName, &d.LastName, &d.Role, &d.Phone,
		&d.Email, &d.Specialization, &d.LicenseNumber, &d.DoctorStatus,
		&d.InvitedBy, &d.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, errors.New("doctor not found in this clinic")
		}
		return nil, fmt.Errorf("failed to update doctor profile: %w", err)
	}
	return &d, nil
}


func (r *repository) FindDoctorsByClinicID(ctx context.Context, clinicID uuid.UUID) ([]DoctorResponse, error) {
	query := `
		SELECT id, first_name, last_name, role, phone, email, specialization, license_number, doctor_status, invited_by, created_at
		FROM users
		WHERE role = 'doctor' AND clinic_id = $1`

	rows, err := r.db.QueryContext(ctx, query, clinicID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var doctors []DoctorResponse
	for rows.Next() {
		var d DoctorResponse
		err := rows.Scan(
			&d.ID, &d.FirstName, &d.LastName, &d.Role, &d.Phone,
			&d.Email, &d.Specialization, &d.LicenseNumber, &d.DoctorStatus,
			&d.InvitedBy, &d.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		doctors = append(doctors, d)
	}
	return doctors, nil
}

func (r *repository) FindInvitationsByClinicID(ctx context.Context, clinicID uuid.UUID) ([]InvitationResponse, error) {
	query := `
		SELECT id, clinic_id, email, status, expires_at, accepted_at, created_at
		FROM doctor_invitations
		WHERE clinic_id = $1`

	rows, err := r.db.QueryContext(ctx, query, clinicID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var invitations []InvitationResponse
	for rows.Next() {
		var i InvitationResponse
		err := rows.Scan(
			&i.ID, &i.ClinicID, &i.Email, &i.Status,
			&i.ExpiresAt, &i.AcceptedAt, &i.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		invitations = append(invitations, i)
	}
	return invitations, nil
}

