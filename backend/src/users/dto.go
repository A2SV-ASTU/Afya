package users

import (
	"time"

	"github.com/google/uuid"
)

type UserResponse struct {
	ID        uuid.UUID `json:"id" example:"550e8400-e29b-41d4-a716-446655440000"`
	FirstName string    `json:"first_name" example:"Jane"`
	LastName  string    `json:"last_name" example:"Doe"`
	Role      Role      `json:"role" example:"patient"`
	Phone     string    `json:"phone,omitempty" example:"+254712345678"`
	Email     string    `json:"email" example:"jane.doe@example.com"`

	// Patient specific fields (nullable)
	DateOfBirth           *time.Time `json:"date_of_birth,omitempty"`
	Sex                   *string    `json:"sex,omitempty" example:"female"`
	BloodType             *string    `json:"blood_type,omitempty" example:"O+"`
	EmergencyContactName  *string    `json:"emergency_contact_name,omitempty" example:"John Doe"`
	EmergencyContactPhone *string    `json:"emergency_contact_phone,omitempty" example:"+254700000000"`

	// Doctor / Clinic Admin specific fields (nullable)
	ClinicID       *uuid.UUID    `json:"clinic_id,omitempty" example:"550e8400-e29b-41d4-a716-446655440001"`
	ClinicStatus   *string       `json:"clinic_status,omitempty" example:"active"`
	Specialization *string       `json:"specialization,omitempty" example:"Cardiology"`
	LicenseNumber  *string       `json:"license_number,omitempty" example:"LIC-12345"`
	DoctorStatus   *DoctorStatus `json:"doctor_status,omitempty" example:"active"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type UpdateProfileRequest struct {
	// First name
	FirstName *string `json:"first_name,omitempty" example:"Jane"`
	// Last name
	LastName *string `json:"last_name,omitempty" example:"Doe"`
	// Email address
	Email *string `json:"email,omitempty" example:"jane.doe@example.com"`
	// Phone number in E.164 format
	Phone *string `json:"phone,omitempty" example:"+254712345678"`
	// Date of birth in YYYY-MM-DD format
	DateOfBirth *string `json:"date_of_birth,omitempty" example:"1990-05-15"`
	// Biological sex: "male" or "female"
	Sex *string `json:"sex,omitempty" example:"female"`
	// Blood type e.g. "A+", "O-"
	BloodType *string `json:"blood_type,omitempty" example:"O+"`
	// Emergency contact full name
	EmergencyContactName *string `json:"emergency_contact_name,omitempty" example:"John Doe"`
	// Emergency contact phone number
	EmergencyContactPhone *string `json:"emergency_contact_phone,omitempty" example:"+254700000000"`
}

// ChangePasswordRequest is the request body for PUT/PATCH /users/me/password.
type ChangePasswordRequest struct {
	// The user's current password
	CurrentPassword string `json:"current_password" binding:"required" example:"OldPass123!"`
	// The desired new password
	NewPassword string `json:"new_password" binding:"required" example:"NewPass456!"`
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
		ClinicStatus:          u.ClinicStatus,
		Specialization:        u.Specialization,
		LicenseNumber:         u.LicenseNumber,
		DoctorStatus:          u.DoctorStatus,
		CreatedAt:             u.CreatedAt,
		UpdatedAt:             u.UpdatedAt,
	}
}
