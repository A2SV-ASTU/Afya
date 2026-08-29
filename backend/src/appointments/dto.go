package appointments

import (
	"time"

	"github.com/google/uuid"
)

type CreateAppointmentRequest struct {
	PatientID   uuid.UUID `json:"patient_id" binding:"required"`
	ScheduledAt time.Time `json:"scheduled_at" binding:"required"`
	Notes       *string   `json:"notes"`
}
