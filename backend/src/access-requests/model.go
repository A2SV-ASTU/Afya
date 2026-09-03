package accessrequests

import (
	"time"

	"github.com/google/uuid"
)

const (
	StatusPending  = "pending"
	StatusApproved = "approved"
	StatusDenied   = "denied"
	StatusExpired  = "expired"
)

type PatientInfo struct {
	ID        uuid.UUID `json:"id"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
	Email     string    `json:"email"`
}

type AccessRequest struct {
	ID                  uuid.UUID    `json:"id"`
	PatientID           uuid.UUID    `json:"patient_id"`
	Patient             *PatientInfo `json:"patient,omitempty"`
	RequestingClinicID  uuid.UUID    `json:"requesting_clinic_id"`
	Reason              string       `json:"reason,omitempty"`
	SubmittedByDoctorID *uuid.UUID   `json:"submitted_by_doctor_id,omitempty"`
	Status              string       `json:"status"`
	ExpiresAt           time.Time    `json:"expires_at"`
	RevokedAt           *time.Time   `json:"revoked_at,omitempty"`
	CreatedAt           time.Time    `json:"created_at"`
	UpdatedAt           time.Time    `json:"updated_at"`
	TokenHash           string       `json:"-"`
}
