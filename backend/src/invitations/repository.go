package invitations

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"afyamind-backend/src/database"

	"github.com/google/uuid"
)

var ErrInvitationNotFound = errors.New("invitation not found")

type Repository interface {
	Create(ctx context.Context, inv *DoctorInvitation) error
	FindByTokenHash(ctx context.Context, tokenHash string) (*DoctorInvitation, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status string) error
	MarkExpired(ctx context.Context) (int64, error)
}

type repository struct {
	db database.DBTX
}

func NewRepository(db database.DBTX) Repository {
	return &repository{db: db}
}

const invColumns = `id, clinic_id, email, token_hash, status, expires_at, accepted_at, created_at, invited_by`

func scanInvitation(row *sql.Row) (*DoctorInvitation, error) {
	var inv DoctorInvitation
	err := row.Scan(
		&inv.ID,
		&inv.ClinicID,
		&inv.Email,
		&inv.TokenHash,
		&inv.Status,
		&inv.ExpiresAt,
		&inv.AcceptedAt,
		&inv.CreatedAt,
		&inv.InvitedBy,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrInvitationNotFound
		}
		return nil, err
	}
	return &inv, nil
}

func (r *repository) Create(ctx context.Context, inv *DoctorInvitation) error {
	query := `
		INSERT INTO doctor_invitations (clinic_id, email, token_hash, status, expires_at, created_at, invited_by)
		VALUES ($1, $2, $3, $4, $5, NOW(), $6)
		RETURNING id, created_at
	`
	err := r.db.QueryRowContext(
		ctx, query,
		inv.ClinicID, inv.Email, inv.TokenHash, inv.Status, inv.ExpiresAt, inv.InvitedBy,
	).Scan(&inv.ID, &inv.CreatedAt)

	if err != nil {
		return fmt.Errorf("failed to create invitation: %w", err)
	}
	return nil
}

func (r *repository) FindByTokenHash(ctx context.Context, tokenHash string) (*DoctorInvitation, error) {
	query := fmt.Sprintf(`SELECT %s FROM doctor_invitations WHERE token_hash = $1`, invColumns)
	return scanInvitation(r.db.QueryRowContext(ctx, query, tokenHash))
}

func (r *repository) UpdateStatus(ctx context.Context, id uuid.UUID, status string) error {
	query := `
		UPDATE doctor_invitations
		SET status = $1
	`
	if status == StatusAccepted {
		query += `, accepted_at = NOW()`
	}
	query += ` WHERE id = $2`

	res, err := r.db.ExecContext(ctx, query, status, id)
	if err != nil {
		return fmt.Errorf("failed to update invitation status: %w", err)
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return ErrInvitationNotFound
	}
	return nil
}

func (r *repository) MarkExpired(ctx context.Context) (int64, error) {
	query := `
		UPDATE doctor_invitations
		SET status = 'expired'
		WHERE status = 'pending' AND expires_at < NOW()
	`
	res, err := r.db.ExecContext(ctx, query)
	if err != nil {
		return 0, fmt.Errorf("failed to mark expired invitations: %w", err)
	}
	return res.RowsAffected()
}
