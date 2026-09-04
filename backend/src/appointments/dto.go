package appointments

import (
	"time"

	"github.com/google/uuid"
)

// CreateAppointmentRequest is the request body for POST /appointments.
type CreateAppointmentRequest struct {
	// The unique ID of the patient
	PatientID uuid.UUID `json:"patient_id" binding:"required" example:"550e8400-e29b-41d4-a716-446655440000"`
	// Scheduled date and time for the appointment
	ScheduledAt time.Time `json:"scheduled_at" binding:"required" example:"2026-09-15T10:00:00Z"`
	// Optional consultation notes/purpose
	Notes *string `json:"notes" example:"Annual cardiac checkup"`
}

// UpdateAppointmentStatusRequest is the request body for PATCH /appointments/:id/status.
type UpdateAppointmentStatusRequest struct {
	// New status for the appointment (attended or missed)
	Status AppointmentStatus `json:"status" binding:"required" example:"attended"`
}
