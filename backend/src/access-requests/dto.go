package accessrequests

import (
	"github.com/google/uuid"
)

// CreateAccessRequestRequest is the request body for POST /clinics/:clinicId/access-requests.
type CreateAccessRequestRequest struct {
	// The unique ID of the target patient
	PatientID uuid.UUID `json:"patient_id" binding:"required" example:"550e8400-e29b-41d4-a716-446655440000"`
	// Rationale for requesting clinical record access
	Reason string `json:"reason" binding:"required" example:"Patient scheduled for cardiovascular follow-up"`
}

// PatientLookupResponse is the response body for GET /patients/lookup.
type PatientLookupResponse struct {
	ID        uuid.UUID `json:"id" example:"550e8400-e29b-41d4-a716-446655440000"`
	FirstName string    `json:"first_name" example:"Jane"`
	LastName  string    `json:"last_name" example:"Doe"`
	Email     string    `json:"email" example:"jane.doe@example.com"`
}
