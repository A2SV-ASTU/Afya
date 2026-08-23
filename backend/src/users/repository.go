package users

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"afyamind-backend/src/database"
)

var ErrUserNotFound = errors.New("user not found")

type Repository interface {
	FindByID(ctx context.Context, id int64) (*User, error)
	FindByEmail(ctx context.Context, email string) (*User, error)
	Create(ctx context.Context, user *User) error
	UpdateProfile(ctx context.Context, id int64, name *string, email *string, passwordHash *string) (*User, error)
	AcceptDisclaimer(ctx context.Context, id int64) (*User, error)
}

type repository struct {
	db database.DBTX
}

func NewRepository(db database.DBTX) Repository {
	return &repository{db: db}
}

func (r *repository) FindByID(ctx context.Context, id int64) (*User, error) {
	query := `
		SELECT id, email, name, password_hash, role, age_attested_18, disclaimer_accepted_at, created_at, updated_at
		FROM users
		WHERE id = $1
	`
	user := &User{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&user.ID,
		&user.Email,
		&user.Name,
		&user.PasswordHash,
		&user.Role,
		&user.AgeAttested18,
		&user.DisclaimerAcceptedAt,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrUserNotFound
		}
		return nil, fmt.Errorf("failed to find user by id: %w", err)
	}

	return user, nil
}

func (r *repository) FindByEmail(ctx context.Context, email string) (*User, error) {
	query := `
		SELECT id, email, name, password_hash, role, age_attested_18, disclaimer_accepted_at, created_at, updated_at
		FROM users
		WHERE email = $1
	`
	user := &User{}
	err := r.db.QueryRowContext(ctx, query, email).Scan(
		&user.ID,
		&user.Email,
		&user.Name,
		&user.PasswordHash,
		&user.Role,
		&user.AgeAttested18,
		&user.DisclaimerAcceptedAt,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrUserNotFound
		}
		return nil, fmt.Errorf("failed to find user by email: %w", err)
	}

	return user, nil
}

func (r *repository) Create(ctx context.Context, user *User) error {
	query := `
		INSERT INTO users (email, name, password_hash, role, age_attested_18, disclaimer_accepted_at, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
		RETURNING id, created_at, updated_at
	`
	role := user.Role
	if role == "" {
		role = RolePerson
	}

	err := r.db.QueryRowContext(
		ctx,
		query,
		user.Email,
		user.Name,
		user.PasswordHash,
		role,
		user.AgeAttested18,
		user.DisclaimerAcceptedAt,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		return fmt.Errorf("failed to insert user: %w", err)
	}

	user.Role = role
	return nil
}

func (r *repository) UpdateProfile(ctx context.Context, id int64, name *string, email *string, passwordHash *string) (*User, error) {
	// First fetch current user
	currentUser, err := r.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}

	updatedName := currentUser.Name
	if name != nil && *name != "" {
		updatedName = *name
	}

	updatedEmail := currentUser.Email
	if email != nil && *email != "" {
		updatedEmail = *email
	}

	updatedPasswordHash := currentUser.PasswordHash
	if passwordHash != nil && *passwordHash != "" {
		updatedPasswordHash = *passwordHash
	}

	query := `
		UPDATE users
		SET name = $1, email = $2, password_hash = $3, updated_at = NOW()
		WHERE id = $4
		RETURNING id, email, name, password_hash, role, age_attested_18, disclaimer_accepted_at, created_at, updated_at
	`
	user := &User{}
	err = r.db.QueryRowContext(ctx, query, updatedName, updatedEmail, updatedPasswordHash, id).Scan(
		&user.ID,
		&user.Email,
		&user.Name,
		&user.PasswordHash,
		&user.Role,
		&user.AgeAttested18,
		&user.DisclaimerAcceptedAt,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrUserNotFound
		}
		return nil, fmt.Errorf("failed to update user profile: %w", err)
	}

	return user, nil
}

func (r *repository) AcceptDisclaimer(ctx context.Context, id int64) (*User, error) {
	now := time.Now()
	query := `
		UPDATE users
		SET age_attested_18 = true, disclaimer_accepted_at = $1, updated_at = $1
		WHERE id = $2
		RETURNING id, email, name, password_hash, role, age_attested_18, disclaimer_accepted_at, created_at, updated_at
	`
	user := &User{}
	err := r.db.QueryRowContext(ctx, query, now, id).Scan(
		&user.ID,
		&user.Email,
		&user.Name,
		&user.PasswordHash,
		&user.Role,
		&user.AgeAttested18,
		&user.DisclaimerAcceptedAt,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrUserNotFound
		}
		return nil, fmt.Errorf("failed to record disclaimer acceptance: %w", err)
	}

	return user, nil
}
