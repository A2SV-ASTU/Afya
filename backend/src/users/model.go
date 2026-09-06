package users

import (
	"time"

	"github.com/google/uuid"
)

type Role string

const (
	RolePatient     Role = "patient"
	RoleDoctor      Role = "doctor"
	RoleClinicAdmin Role = "clinic_admin"
	RoleSuperAdmin  Role = "super_admin"
)

type DoctorStatus string

const (
	DoctorStatusActive      DoctorStatus = "active"
	DoctorStatusDeactivated DoctorStatus = "deactivated"
)

type User struct {
	ID           uuid.UUID `json:"id"`
	FirstName    string    `json:"first_name"`
	LastName     string    `json:"last_name"`
	Role         Role      `json:"role"`
	Phone        string    `json:"phone"`
	Email        string    `json:"email"`
	PasswordHash string    `json:"-"`

	// Patient specific fields (nullable)
	DateOfBirth           *time.Time `json:"date_of_birth,omitempty"`
	Sex                   *string    `json:"sex,omitempty"`
	BloodType             *string    `json:"blood_type,omitempty"`
	EmergencyContactName  *string    `json:"emergency_contact_name,omitempty"`
	EmergencyContactPhone *string    `json:"emergency_contact_phone,omitempty"`

	// Doctor / Clinic Admin specific fields (nullable)
	ClinicID       *uuid.UUID    `json:"clinic_id,omitempty"`
	ClinicStatus   *string       `json:"clinic_status,omitempty"`
	Specialization *string       `json:"specialization,omitempty"`
	LicenseNumber  *string       `json:"license_number,omitempty"`
	DoctorStatus   *DoctorStatus `json:"doctor_status,omitempty"`
	InvitedBy      *uuid.UUID    `json:"invited_by,omitempty"`
	// Email verification status
	IsEmailVerified bool       `json:"is_email_verified"`
	EmailVerifiedAt *time.Time `json:"email_verified_at,omitempty"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}


