package accessrequests

import (
	"github.com/google/uuid"
)

type CreateAccessRequestRequest struct {
	PatientID uuid.UUID `json:"patient_id" binding:"required"`
	Reason    string    `json:"reason" binding:"required"`
}

type PatientLookupResponse struct {
	ID        uuid.UUID `json:"id"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
	Email     string    `json:"email"`
}
