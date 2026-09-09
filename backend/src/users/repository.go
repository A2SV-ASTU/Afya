package users

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"afyamind-backend/src/database"

	"github.com/google/uuid"
)

var ErrUserNotFound = errors.New("user not found")

type Repository interface {
	FindByID(ctx context.Context, id uuid.UUID) (*User, error)
	FindByEmail(ctx context.Context, email string) (*User, error)
	FindByPhone(ctx context.Context, phone string) (*User, error)
	FindByLogin(ctx context.Context, login string) (*User, error)
	Create(ctx context.Context, user *User) error
	UpdateProfile(ctx context.Context, id uuid.UUID, req UpdateProfileRequest) (*User, error)
	UpdatePassword(ctx context.Context, id uuid.UUID, passwordHash string) error
	DeleteAccount(ctx context.Context, id uuid.UUID) error
}

type repository struct {
	db database.DBTX
}

func NewRepository(db database.DBTX) Repository {
	return &repository{db: db}
}

const selectUserWithClinic = `
	SELECT 
		u.id, u.first_name, u.last_name, u.role, u.phone, u.email, u.password_hash,
		u.date_of_birth, u.sex, u.blood_type, u.emergency_contact_name, u.emergency_contact_phone,
		u.clinic_id, u.specialization, u.license_number, u.doctor_status, u.invited_by,
		u.created_at, u.updated_at,
		c.id, c.name, c.email, c.phone, c.address, c.status
	FROM users u
	LEFT JOIN clinics c ON u.clinic_id = c.id
`

type scanner interface {
	Scan(dest ...interface{}) error
}

func scanUser(s scanner) (*User, error) {
	u := &User{}
	var cID uuid.NullUUID
	var cName, cEmail, cPhone, cAddress, cStatus sql.NullString

	err := s.Scan(
		&u.ID,
		&u.FirstName,
		&u.LastName,
		&u.Role,
		&u.Phone,
		&u.Email,
		&u.PasswordHash,
		&u.DateOfBirth,
		&u.Sex,
		&u.BloodType,
		&u.EmergencyContactName,
		&u.EmergencyContactPhone,
		&u.ClinicID,
		&u.Specialization,
		&u.LicenseNumber,
		&u.DoctorStatus,
		&u.InvitedBy,
		&u.CreatedAt,
		&u.UpdatedAt,
		&cID,
		&cName,
		&cEmail,
		&cPhone,
		&cAddress,
		&cStatus,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrUserNotFound
		}
		return nil, err
	}

	if cID.Valid {
		u.Clinic = &ClinicSummary{
			ID:      cID.UUID,
			Name:    cName.String,
			Email:   cEmail.String,
			Phone:   cPhone.String,
			Address: cAddress.String,
			Status:  cStatus.String,
		}
	}

	return u, nil
}

func (r *repository) FindByID(ctx context.Context, id uuid.UUID) (*User, error) {
	query := selectUserWithClinic + ` WHERE u.id = $1`
	return scanUser(r.db.QueryRowContext(ctx, query, id))
}

func (r *repository) FindByEmail(ctx context.Context, email string) (*User, error) {
	query := selectUserWithClinic + ` WHERE u.email = $1`
	return scanUser(r.db.QueryRowContext(ctx, query, email))
}

func (r *repository) FindByPhone(ctx context.Context, phone string) (*User, error) {
	query := selectUserWithClinic + ` WHERE u.phone = $1`
	return scanUser(r.db.QueryRowContext(ctx, query, phone))
}

func (r *repository) FindByLogin(ctx context.Context, login string) (*User, error) {
	query := selectUserWithClinic + ` WHERE u.email = $1 OR u.phone = $1`
	return scanUser(r.db.QueryRowContext(ctx, query, login))
}

func (r *repository) Create(ctx context.Context, user *User) error {
	query := `
		INSERT INTO users (
			first_name, last_name, role, phone, email, password_hash,
			date_of_birth, sex, blood_type, emergency_contact_name, emergency_contact_phone,
			clinic_id, specialization, license_number, doctor_status, invited_by,
			created_at, updated_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, NOW(), NOW())
		RETURNING id, created_at, updated_at
	`
	role := user.Role
	if role == "" {
		role = RolePatient
	}

	err := r.db.QueryRowContext(
		ctx,
		query,
		user.FirstName,
		user.LastName,
		role,
		user.Phone,
		user.Email,
		user.PasswordHash,
		user.DateOfBirth,
		user.Sex,
		user.BloodType,
		user.EmergencyContactName,
		user.EmergencyContactPhone,
		user.ClinicID,
		user.Specialization,
		user.LicenseNumber,
		user.DoctorStatus,
		user.InvitedBy,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		return fmt.Errorf("failed to insert user: %w", err)
	}

	user.Role = role
	return nil
}

func (r *repository) UpdateProfile(ctx context.Context, id uuid.UUID, req UpdateProfileRequest) (*User, error) {
	currentUser, err := r.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}

	if req.FirstName != nil && *req.FirstName != "" {
		currentUser.FirstName = *req.FirstName
	}
	if req.LastName != nil && *req.LastName != "" {
		currentUser.LastName = *req.LastName
	}
	if req.Email != nil && *req.Email != "" {
		currentUser.Email = *req.Email
	}
	if req.Phone != nil && *req.Phone != "" {
		currentUser.Phone = *req.Phone
	}
	if req.DateOfBirth != nil && *req.DateOfBirth != "" {
		if parsedDOB, err := time.Parse("2006-01-02", *req.DateOfBirth); err == nil {
			currentUser.DateOfBirth = &parsedDOB
		}
	}
	if req.Sex != nil {
		currentUser.Sex = req.Sex
	}
	if req.BloodType != nil {
		currentUser.BloodType = req.BloodType
	}
	if req.EmergencyContactName != nil {
		currentUser.EmergencyContactName = req.EmergencyContactName
	}
	if req.EmergencyContactPhone != nil {
		currentUser.EmergencyContactPhone = req.EmergencyContactPhone
	}

	query := `
		UPDATE users
		SET first_name = $1, last_name = $2, email = $3, phone = $4, date_of_birth = $5, sex = $6,
		    blood_type = $7, emergency_contact_name = $8, emergency_contact_phone = $9,
		    updated_at = NOW()
		WHERE id = $10
	`

	_, err = r.db.ExecContext(
		ctx,
		query,
		currentUser.FirstName,
		currentUser.LastName,
		currentUser.Email,
		currentUser.Phone,
		currentUser.DateOfBirth,
		currentUser.Sex,
		currentUser.BloodType,
		currentUser.EmergencyContactName,
		currentUser.EmergencyContactPhone,
		id,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to update user profile: %w", err)
	}

	return r.FindByID(ctx, id)
}

func (r *repository) UpdatePassword(ctx context.Context, id uuid.UUID, passwordHash string) error {
	query := `
		UPDATE users
		SET password_hash = $1, updated_at = NOW()
		WHERE id = $2
	`
	res, err := r.db.ExecContext(ctx, query, passwordHash, id)
	if err != nil {
		return fmt.Errorf("failed to update user password: %w", err)
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %w", err)
	}
	if rows == 0 {
		return ErrUserNotFound
	}
	return nil
}

func (r *repository) DeleteAccount(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM users WHERE id = $1`
	res, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user account: %w", err)
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %w", err)
	}
	if rows == 0 {
		return ErrUserNotFound
	}
	return nil
}
