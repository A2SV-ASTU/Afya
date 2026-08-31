package clinics

import (
	"time"

	"github.com/google/uuid"
)

// CreateClinicRequest is the request body for POST /clinics.
type CreateClinicRequest struct {
	// Name of the clinic
	Name string `json:"name" binding:"required" example:"St. Luke Health Center"`
	// Main contact email address
	Email string `json:"email" binding:"required,email" example:"contact@stlukes.com"`
	// Telephone contact number
	Phone string `json:"phone" binding:"required" example:"+254711223344"`
	// Street address of the clinic
	Address string `json:"address" example:"123 Medical Plaza, Nairobi"`
	// First name of the designated clinic administrator
	AdminFirstName string `json:"admin_first_name" binding:"required" example:"Alice"`
	// Last name of the designated clinic administrator
	AdminLastName string `json:"admin_last_name" binding:"required" example:"Smith"`
}

// DoctorResponse is the response model for doctor details.
type DoctorResponse struct {
	ID             uuid.UUID  `json:"id" example:"550e8400-e29b-41d4-a716-446655440002"`
	FirstName      string     `json:"first_name" example:"Jane"`
	LastName       string     `json:"last_name" example:"Doe"`
	Role           string     `json:"role" example:"doctor"`
	Phone          *string    `json:"phone" example:"+254712345678"`
	Email          *string    `json:"email" example:"jane.doe@example.com"`
	Specialization *string    `json:"specialization" example:"Pediatrics"`
	LicenseNumber  *string    `json:"license_number" example:"LIC-12345"`
	DoctorStatus   string     `json:"doctor_status" example:"active"`
	InvitedBy      *uuid.UUID `json:"invited_by" example:"550e8400-e29b-41d4-a716-446655440001"`
	CreatedAt      time.Time  `json:"created_at"`
}

// InvitationResponse is the response model for clinic invitation details.
type InvitationResponse struct {
	ID         uuid.UUID  `json:"id" example:"550e8400-e29b-41d4-a716-446655440003"`
	ClinicID   uuid.UUID  `json:"clinic_id" example:"550e8400-e29b-41d4-a716-446655440001"`
	Email      string     `json:"email" example:"doctor@hospital.com"`
	Status     string     `json:"status" example:"pending"`
	ExpiresAt  time.Time  `json:"expires_at"`
	AcceptedAt *time.Time `json:"accepted_at"`
	CreatedAt  time.Time  `json:"created_at"`
}
