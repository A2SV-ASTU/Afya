package clinics


import (
	"time"

	"github.com/google/uuid"
)

type CreateClinicRequest struct {
	Name           string `json:"name" binding:"required"`
	Email          string `json:"email" binding:"required,email"`
	Phone          string `json:"phone"`
	Address        string `json:"address"`
	AdminFirstName string `json:"admin_first_name" binding:"required"`
	AdminLastName  string `json:"admin_last_name" binding:"required"`
}



type DoctorResponse struct {
	ID             uuid.UUID  `json:"id"`
	FirstName      string     `json:"first_name"`
	LastName       string     `json:"last_name"`
	Role           string     `json:"role"`
	Phone          string     `json:"phone"`
	Email          *string    `json:"email"`
	Specialization *string    `json:"specialization"`
	LicenseNumber  *string    `json:"license_number"`
	DoctorStatus   string     `json:"doctor_status"`
	InvitedBy      *uuid.UUID `json:"invited_by"`
	CreatedAt      time.Time  `json:"created_at"`
}

type InvitationResponse struct {
	ID         uuid.UUID  `json:"id"`
	ClinicID   uuid.UUID  `json:"clinic_id"`
	Email      string     `json:"email"`
	Status     string     `json:"status"`
	ExpiresAt  time.Time  `json:"expires_at"`
	AcceptedAt *time.Time `json:"accepted_at"`
	CreatedAt  time.Time  `json:"created_at"`
}

