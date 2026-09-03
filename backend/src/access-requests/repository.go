package accessrequests

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"afyamind-backend/src/database"

	"github.com/google/uuid"
)

var ErrRequestNotFound = errors.New("access request not found")

type Repository interface {
	Create(ctx context.Context, req *AccessRequest) error
	FindByID(ctx context.Context, id uuid.UUID) (*AccessRequest, error)
	FindByTokenHash(ctx context.Context, tokenHash string) (*AccessRequest, error)
	ListByClinicID(ctx context.Context, clinicID uuid.UUID, status string) ([]*AccessRequest, error)
	ListPendingByPatientID(ctx context.Context, patientID uuid.UUID) ([]*AccessRequest, error)
	ListActiveGrantsByPatientID(ctx context.Context, patientID uuid.UUID) ([]*AccessRequest, error)
	RevokeByPatientAndClinic(ctx context.Context, patientID, clinicID uuid.UUID) error
	UpdateStatus(ctx context.Context, id uuid.UUID, status string) error
	Revoke(ctx context.Context, id uuid.UUID) error
	FindActiveGrant(ctx context.Context, clinicID, patientID uuid.UUID) (*AccessRequest, error)
	MarkExpired(ctx context.Context) (int64, error)
}

type repository struct {
	db database.DBTX
}

func NewRepository(db database.DBTX) Repository {
	return &repository{db: db}
}

const reqColumns = `id, patient_id, requesting_clinic_id, reason, submitted_by_doctor_id, status, expires_at, revoked_at, created_at, updated_at, token_hash`

func scanAccessRequest(row *sql.Row) (*AccessRequest, error) {
	var ar AccessRequest
	var tokenHash sql.NullString
	err := row.Scan(
		&ar.ID,
		&ar.PatientID,
		&ar.RequestingClinicID,
		&ar.Reason,
		&ar.SubmittedByDoctorID,
		&ar.Status,
		&ar.ExpiresAt,
		&ar.RevokedAt,
		&ar.CreatedAt,
		&ar.UpdatedAt,
		&tokenHash,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrRequestNotFound
		}
		return nil, err
	}
	if tokenHash.Valid {
		ar.TokenHash = tokenHash.String
	}
	return &ar, nil
}

func (r *repository) Create(ctx context.Context, req *AccessRequest) error {
	query := `
		INSERT INTO access_requests (patient_id, requesting_clinic_id, reason, submitted_by_doctor_id, status, expires_at, token_hash, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
		RETURNING id, created_at, updated_at
	`
	var tokenHashParam interface{}
	if req.TokenHash != "" {
		tokenHashParam = req.TokenHash
	}
	err := r.db.QueryRowContext(
		ctx, query,
		req.PatientID, req.RequestingClinicID, req.Reason, req.SubmittedByDoctorID, req.Status, req.ExpiresAt, tokenHashParam,
	).Scan(&req.ID, &req.CreatedAt, &req.UpdatedAt)

	if err != nil {
		return fmt.Errorf("failed to create access request: %w", err)
	}
	return nil
}

func (r *repository) FindByTokenHash(ctx context.Context, tokenHash string) (*AccessRequest, error) {
	query := fmt.Sprintf(`SELECT %s FROM access_requests WHERE token_hash = $1`, reqColumns)
	return scanAccessRequest(r.db.QueryRowContext(ctx, query, tokenHash))
}

func (r *repository) FindByID(ctx context.Context, id uuid.UUID) (*AccessRequest, error) {
	query := fmt.Sprintf(`SELECT %s FROM access_requests WHERE id = $1`, reqColumns)
	return scanAccessRequest(r.db.QueryRowContext(ctx, query, id))
}

func (r *repository) ListByClinicID(ctx context.Context, clinicID uuid.UUID, status string) ([]*AccessRequest, error) {
	var query string
	var args []any
	if status != "" {
		query = fmt.Sprintf(`SELECT %s FROM access_requests WHERE requesting_clinic_id = $1 AND status = $2 ORDER BY created_at DESC`, reqColumns)
		args = []any{clinicID, status}
	} else {
		query = fmt.Sprintf(`SELECT %s FROM access_requests WHERE requesting_clinic_id = $1 ORDER BY created_at DESC`, reqColumns)
		args = []any{clinicID}
	}

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to list access requests: %w", err)
	}
	defer rows.Close()

	var reqs []*AccessRequest
	for rows.Next() {
		var ar AccessRequest
		var tokenHash sql.NullString
		if err := rows.Scan(
			&ar.ID, &ar.PatientID, &ar.RequestingClinicID, &ar.Reason, &ar.SubmittedByDoctorID,
			&ar.Status, &ar.ExpiresAt, &ar.RevokedAt, &ar.CreatedAt, &ar.UpdatedAt, &tokenHash,
		); err != nil {
			return nil, err
		}
		if tokenHash.Valid {
			ar.TokenHash = tokenHash.String
		}
		reqs = append(reqs, &ar)
	}
	return reqs, nil
}

func (r *repository) UpdateStatus(ctx context.Context, id uuid.UUID, status string) error {
	query := `
		UPDATE access_requests
		SET status = $1, updated_at = NOW()
		WHERE id = $2
	`
	res, err := r.db.ExecContext(ctx, query, status, id)
	if err != nil {
		return fmt.Errorf("failed to update access request status: %w", err)
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return ErrRequestNotFound
	}
	return nil
}

func (r *repository) Revoke(ctx context.Context, id uuid.UUID) error {
	query := `
		UPDATE access_requests
		SET revoked_at = NOW(), updated_at = NOW()
		WHERE id = $1
	`
	res, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to revoke access request: %w", err)
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return ErrRequestNotFound
	}
	return nil
}

func (r *repository) FindActiveGrant(ctx context.Context, clinicID, patientID uuid.UUID) (*AccessRequest, error) {
	query := fmt.Sprintf(`
		SELECT %s FROM access_requests
		WHERE requesting_clinic_id = $1 AND patient_id = $2
		AND status = 'approved' AND revoked_at IS NULL
		ORDER BY created_at DESC LIMIT 1
	`, reqColumns)
	return scanAccessRequest(r.db.QueryRowContext(ctx, query, clinicID, patientID))
}

func (r *repository) MarkExpired(ctx context.Context) (int64, error) {
	query := `
		UPDATE access_requests
		SET status = 'expired', updated_at = NOW()
		WHERE status = 'pending' AND expires_at < NOW()
	`
	res, err := r.db.ExecContext(ctx, query)
	if err != nil {
		return 0, fmt.Errorf("failed to mark expired access requests: %w", err)
	}
	return res.RowsAffected()
}

func (r *repository) ListPendingByPatientID(ctx context.Context, patientID uuid.UUID) ([]*AccessRequest, error) {
	query := `
		SELECT ar.id, ar.patient_id, ar.requesting_clinic_id, ar.reason, ar.submitted_by_doctor_id,
		       ar.status, ar.expires_at, ar.revoked_at, ar.created_at, ar.updated_at,
		       COALESCE(c.name, 'Unknown Clinic'),
		       COALESCE(u.first_name || ' ' || u.last_name, 'Unknown Doctor')
		FROM access_requests ar
		LEFT JOIN clinics c ON c.id = ar.requesting_clinic_id
		LEFT JOIN users u ON u.id = ar.submitted_by_doctor_id
		WHERE ar.patient_id = $1 AND ar.status = 'pending'
		AND ar.expires_at > NOW()
		ORDER BY ar.created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, patientID)
	if err != nil {
		return nil, fmt.Errorf("failed to list pending access requests by patient: %w", err)
	}
	defer rows.Close()

	var reqs []*AccessRequest
	for rows.Next() {
		var ar AccessRequest
		if err := rows.Scan(
			&ar.ID, &ar.PatientID, &ar.RequestingClinicID, &ar.Reason, &ar.SubmittedByDoctorID,
			&ar.Status, &ar.ExpiresAt, &ar.RevokedAt, &ar.CreatedAt, &ar.UpdatedAt,
			&ar.ClinicName, &ar.DoctorName,
		); err != nil {
			return nil, err
		}
		reqs = append(reqs, &ar)
	}
	return reqs, nil
}

func (r *repository) ListActiveGrantsByPatientID(ctx context.Context, patientID uuid.UUID) ([]*AccessRequest, error) {
	query := `
		SELECT ar.id, ar.patient_id, ar.requesting_clinic_id, ar.reason, ar.submitted_by_doctor_id,
		       ar.status, ar.expires_at, ar.revoked_at, ar.created_at, ar.updated_at,
		       COALESCE(c.name, 'Unknown Clinic'),
		       COALESCE(u.first_name || ' ' || u.last_name, 'Unknown Doctor')
		FROM access_requests ar
		LEFT JOIN clinics c ON c.id = ar.requesting_clinic_id
		LEFT JOIN users u ON u.id = ar.submitted_by_doctor_id
		WHERE ar.patient_id = $1 AND ar.status = 'approved' AND ar.revoked_at IS NULL
		ORDER BY ar.created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, patientID)
	if err != nil {
		return nil, fmt.Errorf("failed to list active grants by patient: %w", err)
	}
	defer rows.Close()

	var reqs []*AccessRequest
	for rows.Next() {
		var ar AccessRequest
		if err := rows.Scan(
			&ar.ID, &ar.PatientID, &ar.RequestingClinicID, &ar.Reason, &ar.SubmittedByDoctorID,
			&ar.Status, &ar.ExpiresAt, &ar.RevokedAt, &ar.CreatedAt, &ar.UpdatedAt,
			&ar.ClinicName, &ar.DoctorName,
		); err != nil {
			return nil, err
		}
		reqs = append(reqs, &ar)
	}
	return reqs, nil
}

func (r *repository) RevokeByPatientAndClinic(ctx context.Context, patientID, clinicID uuid.UUID) error {
	query := `
		UPDATE access_requests
		SET revoked_at = NOW(), updated_at = NOW()
		WHERE patient_id = $1 AND requesting_clinic_id = $2
		AND status = 'approved' AND revoked_at IS NULL
	`
	res, err := r.db.ExecContext(ctx, query, patientID, clinicID)
	if err != nil {
		return fmt.Errorf("failed to revoke access request by patient and clinic: %w", err)
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return ErrRequestNotFound
	}
	return nil
}
