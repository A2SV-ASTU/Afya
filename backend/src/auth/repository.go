package auth

import (
	"context"
	"time"

	"afyamind-backend/src/database"
	"afyamind-backend/src/users"

	"github.com/google/uuid"
)

type EmailVerification struct {
	ID        uuid.UUID
	UserID    uuid.UUID
	Email     string
	OTPHash   string
	Attempts  int
	ExpiresAt time.Time
	CreatedAt time.Time
	UpdatedAt time.Time
}

type Repository interface {
	FindByEmail(ctx context.Context, email string) (*users.User, error)
	FindByPhone(ctx context.Context, phone string) (*users.User, error)
	FindByLogin(ctx context.Context, login string) (*users.User, error)
	FindByID(ctx context.Context, id uuid.UUID) (*users.User, error)
	Create(ctx context.Context, user *users.User) error
	CreatePasswordReset(ctx context.Context, userID uuid.UUID, tokenHash string, expiresAt time.Time) error
	FindPasswordResetByTokenHash(ctx context.Context, tokenHash string) (uuid.UUID, uuid.UUID, bool, error)
	MarkPasswordResetUsed(ctx context.Context, id uuid.UUID) error
	UpdateUserPassword(ctx context.Context, userID uuid.UUID, newHash string) error
	CreateEmailVerification(ctx context.Context, userID uuid.UUID, email, otpHash string, expiresAt time.Time) error
	FindEmailVerificationByEmail(ctx context.Context, email string) (*EmailVerification, error)
	IncrementVerificationAttempts(ctx context.Context, id uuid.UUID) error
	DeleteEmailVerification(ctx context.Context, id uuid.UUID) error
	MarkEmailVerified(ctx context.Context, userID uuid.UUID) error
}

type repository struct {
	db       database.DBTX
	userRepo users.Repository
}

func NewRepository(db database.DBTX) Repository {
	return &repository{
		db:       db,
		userRepo: users.NewRepository(db),
	}
}

func NewRepositoryWithUserRepo(userRepo users.Repository) Repository {
	return &repository{
		userRepo: userRepo,
	}
}

func (r *repository) FindByEmail(ctx context.Context, email string) (*users.User, error) {
	return r.userRepo.FindByEmail(ctx, email)
}

func (r *repository) FindByPhone(ctx context.Context, phone string) (*users.User, error) {
	return r.userRepo.FindByPhone(ctx, phone)
}

func (r *repository) FindByLogin(ctx context.Context, login string) (*users.User, error) {
	return r.userRepo.FindByLogin(ctx, login)
}

func (r *repository) FindByID(ctx context.Context, id uuid.UUID) (*users.User, error) {
	return r.userRepo.FindByID(ctx, id)
}

func (r *repository) Create(ctx context.Context, user *users.User) error {
	return r.userRepo.Create(ctx, user)
}

func (r *repository) CreatePasswordReset(ctx context.Context, userID uuid.UUID, tokenHash string, expiresAt time.Time) error {
	query := `INSERT INTO password_resets (user_id, token_hash, expires_at) VALUES ($1, $2, $3)`
	_, err := r.db.ExecContext(ctx, query, userID, tokenHash, expiresAt)
	return err
}

func (r *repository) FindPasswordResetByTokenHash(ctx context.Context, tokenHash string) (uuid.UUID, uuid.UUID, bool, error) {
	query := `SELECT id, user_id, used_at IS NOT NULL as is_used FROM password_resets WHERE token_hash = $1 AND expires_at > NOW()`
	var id, userID uuid.UUID
	var isUsed bool
	err := r.db.QueryRowContext(ctx, query, tokenHash).Scan(&id, &userID, &isUsed)
	return id, userID, isUsed, err
}

func (r *repository) MarkPasswordResetUsed(ctx context.Context, id uuid.UUID) error {
	query := `UPDATE password_resets SET used_at = NOW() WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id)
	return err
}

func (r *repository) UpdateUserPassword(ctx context.Context, userID uuid.UUID, newHash string) error {
	query := `UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2`
	_, err := r.db.ExecContext(ctx, query, newHash, userID)
	return err
}

func (r *repository) CreateEmailVerification(ctx context.Context, userID uuid.UUID, email, otpHash string, expiresAt time.Time) error {
	query := `
		WITH deleted AS (
			DELETE FROM email_verifications WHERE user_id = $1 OR email = $2
		)
		INSERT INTO email_verifications (user_id, email, otp_hash, attempts, expires_at, created_at, updated_at)
		VALUES ($1, $2, $3, 0, $4, NOW(), NOW())
	`
	_, err := r.db.ExecContext(ctx, query, userID, email, otpHash, expiresAt)
	return err
}


func (r *repository) FindEmailVerificationByEmail(ctx context.Context, email string) (*EmailVerification, error) {
	query := `
		SELECT id, user_id, email, otp_hash, attempts, expires_at, created_at, updated_at
		FROM email_verifications
		WHERE email = $1
		ORDER BY created_at DESC
		LIMIT 1
	`
	var ev EmailVerification
	err := r.db.QueryRowContext(ctx, query, email).Scan(
		&ev.ID,
		&ev.UserID,
		&ev.Email,
		&ev.OTPHash,
		&ev.Attempts,
		&ev.ExpiresAt,
		&ev.CreatedAt,
		&ev.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &ev, nil
}

func (r *repository) IncrementVerificationAttempts(ctx context.Context, id uuid.UUID) error {
	query := `UPDATE email_verifications SET attempts = attempts + 1, updated_at = NOW() WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id)
	return err
}

func (r *repository) DeleteEmailVerification(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM email_verifications WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id)
	return err
}

func (r *repository) MarkEmailVerified(ctx context.Context, userID uuid.UUID) error {
	return r.userRepo.MarkEmailVerified(ctx, userID)
}

