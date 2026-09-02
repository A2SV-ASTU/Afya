package appointments

import (
	"time"

	"github.com/google/uuid"
)

type AppointmentStatus string

const (
	StatusScheduled AppointmentStatus = "scheduled"
	StatusAttended  AppointmentStatus = "attended"
	StatusCancelled AppointmentStatus = "cancelled"
)

type Appointment struct {
	ID          uuid.UUID         `json:"id"`
	ClinicID    uuid.UUID         `json:"clinic_id"`
	DoctorID    uuid.UUID         `json:"doctor_id"`
	PatientID   uuid.UUID         `json:"patient_id"`
	ScheduledAt time.Time         `json:"scheduled_at"`
	Status      AppointmentStatus `json:"status"`
	Notes       *string           `json:"notes"`
	CreatedAt   time.Time         `json:"created_at"`
	UpdatedAt   time.Time         `json:"updated_at"`
}
