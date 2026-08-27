package users

import (
	"time"

	"github.com/google/uuid"
)

type UserResponse struct {
	ID        uuid.UUID `json:"id"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
	Role      Role      `json:"role"`
	Phone     string    `json:"phone,omitempty"`
	Email     string    `json:"email"`

	// Patient specific fields (nullable)
	DateOfBirth           *time.Time `json:"date_of_birth,omitempty"`
	Sex                   *string    `json:"sex,omitempty"`
	BloodType             *string    `json:"blood_type,omitempty"`
	EmergencyContactName  *string    `json:"emergency_contact_name,omitempty"`
	EmergencyContactPhone *string    `json:"emergency_contact_phone,omitempty"`

	// Doctor specific fields (nullable)
	ClinicID       *uuid.UUID    `json:"clinic_id,omitempty"`
	Specialization *string       `json:"specialization,omitempty"`
	LicenseNumber  *string       `json:"license_number,omitempty"`
	DoctorStatus   *DoctorStatus `json:"doctor_status,omitempty"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type UpdateProfileRequest struct {
	FirstName             *string `json:"first_name,omitempty"`
	LastName              *string `json:"last_name,omitempty"`
	DateOfBirth           *string `json:"date_of_birth,omitempty"`
	Sex                   *string `json:"sex,omitempty"`
	BloodType             *string `json:"blood_type,omitempty"`
	EmergencyContactName  *string `json:"emergency_contact_name,omitempty"`
	EmergencyContactPhone *string `json:"emergency_contact_phone,omitempty"`
}

type ChangePasswordRequest struct {
	CurrentPassword string `json:"current_password" binding:"required"`
	NewPassword     string `json:"new_password" binding:"required"`
}

func ToUserResponse(u *User) *UserResponse {
	if u == nil {
		return nil
	}
	return &UserResponse{
		ID:                    u.ID,
		FirstName:             u.FirstName,
		LastName:              u.LastName,
		Role:                  u.Role,
		Phone:                 u.Phone,
		Email:                 u.Email,
		DateOfBirth:           u.DateOfBirth,
		Sex:                   u.Sex,
		BloodType:             u.BloodType,
		EmergencyContactName:  u.EmergencyContactName,
		EmergencyContactPhone: u.EmergencyContactPhone,
		ClinicID:              u.ClinicID,
		Specialization:        u.Specialization,
		LicenseNumber:         u.LicenseNumber,
		DoctorStatus:          u.DoctorStatus,
		CreatedAt:             u.CreatedAt,
		UpdatedAt:             u.UpdatedAt,
	}
}
