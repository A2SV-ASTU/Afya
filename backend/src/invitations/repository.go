package invitations

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"afyamind-backend/src/database"
)

var (
	ErrInvitationNotFound = errors.New("invitation not found")
)

type Repository interface {
	// CreateInvitedUser inserts a user row with role=ADMIN, status=INVITED, and a placeholder password hash
	CreateInvitedUser(ctx context.Context, email string, name string, passwordHash string) (int64, error)
	// FindUserByEmail checks if a user with the given email already exists
	FindUserByEmail(ctx context.Context, email string) (userID int64, exists bool, err error)
	// CreateInvitation inserts a new admin_invitations row
	CreateInvitation(ctx context.Context, inv *AdminInvitation) error
	// FindPendingInvitationByUserID finds an unused, non-expired invitation for the given user
	FindPendingInvitationByUserID(ctx context.Context, userID int64) (*AdminInvitation, error)
	// FindInvitationByTokenHash looks up an invitation by its hashed token
	FindInvitationByTokenHash(ctx context.Context, tokenHash string) (*AdminInvitation, error)
	// MarkInvitationUsed sets used_at on the invitation
	MarkInvitationUsed(ctx context.Context, invitationID int64) error
	// ActivateUser sets password hash and status=ACTIVE on the user
	ActivateUser(ctx context.Context, userID int64, passwordHash string) error
}

type repository struct {
	db database.DBTX
}

func NewRepository(db database.DBTX) Repository {
	return &repository{db: db}
}

func (r *repository) CreateInvitedUser(ctx context.Context, email string, name string, passwordHash string) (int64, error) {
	query := `
		INSERT INTO users (email, name, password_hash, role, status, age_attested_18, created_at, updated_at)
		VALUES ($1, $2, $3, 'ADMIN', 'INVITED', false, NOW(), NOW())
		RETURNING id
	`
	var userID int64
	err := r.db.QueryRowContext(ctx, query, email, name, passwordHash).Scan(&userID)
	if err != nil {
		return 0, fmt.Errorf("failed to create invited user: %w", err)
	}
	return userID, nil
}

func (r *repository) FindUserByEmail(ctx context.Context, email string) (int64, bool, error) {
	query := `SELECT id FROM users WHERE email = $1`
	var userID int64
	err := r.db.QueryRowContext(ctx, query, email).Scan(&userID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return 0, false, nil
		}
		return 0, false, fmt.Errorf("failed to find user by email: %w", err)
	}
	return userID, true, nil
}

func (r *repository) CreateInvitation(ctx context.Context, inv *AdminInvitation) error {
	query := `
		INSERT INTO admin_invitations (user_id, token_hash, expires_at, created_at)
		VALUES ($1, $2, $3, NOW())
		RETURNING id, created_at
	`
	err := r.db.QueryRowContext(ctx, query, inv.UserID, inv.TokenHash, inv.ExpiresAt).Scan(&inv.ID, &inv.CreatedAt)
	if err != nil {
		return fmt.Errorf("failed to create invitation: %w", err)
	}
	return nil
}

func (r *repository) FindPendingInvitationByUserID(ctx context.Context, userID int64) (*AdminInvitation, error) {
	query := `
		SELECT id, user_id, token_hash, expires_at, used_at, created_at
		FROM admin_invitations
		WHERE user_id = $1 AND used_at IS NULL AND expires_at > NOW()
		ORDER BY created_at DESC
		LIMIT 1
	`
	inv := &AdminInvitation{}
	err := r.db.QueryRowContext(ctx, query, userID).Scan(
		&inv.ID, &inv.UserID, &inv.TokenHash, &inv.ExpiresAt, &inv.UsedAt, &inv.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrInvitationNotFound
		}
		return nil, fmt.Errorf("failed to find pending invitation: %w", err)
	}
	return inv, nil
}

func (r *repository) FindInvitationByTokenHash(ctx context.Context, tokenHash string) (*AdminInvitation, error) {
	query := `
		SELECT id, user_id, token_hash, expires_at, used_at, created_at
		FROM admin_invitations
		WHERE token_hash = $1
	`
	inv := &AdminInvitation{}
	err := r.db.QueryRowContext(ctx, query, tokenHash).Scan(
		&inv.ID, &inv.UserID, &inv.TokenHash, &inv.ExpiresAt, &inv.UsedAt, &inv.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrInvitationNotFound
		}
		return nil, fmt.Errorf("failed to find invitation by token hash: %w", err)
	}
	return inv, nil
}

func (r *repository) MarkInvitationUsed(ctx context.Context, invitationID int64) error {
	query := `UPDATE admin_invitations SET used_at = NOW() WHERE id = $1`
	res, err := r.db.ExecContext(ctx, query, invitationID)
	if err != nil {
		return fmt.Errorf("failed to mark invitation as used: %w", err)
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %w", err)
	}
	if rows == 0 {
		return ErrInvitationNotFound
	}
	return nil
}

func (r *repository) ActivateUser(ctx context.Context, userID int64, passwordHash string) error {
	query := `
		UPDATE users
		SET password_hash = $1, status = 'ACTIVE', updated_at = NOW()
		WHERE id = $2
	`
	res, err := r.db.ExecContext(ctx, query, passwordHash, userID)
	if err != nil {
		return fmt.Errorf("failed to activate user: %w", err)
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %w", err)
	}
	if rows == 0 {
		return fmt.Errorf("user not found for activation")
	}
	return nil
}
