package encounters

import (
	"time"

	"github.com/google/uuid"
)

type EncounterStatus string

const (
	StatusOpen   EncounterStatus = "open"
	StatusClosed EncounterStatus = "closed"
)

type Encounter struct {
	ID               uuid.UUID       `json:"id"`
	PatientID        uuid.UUID       `json:"patient_id"`
	ClinicID         uuid.UUID       `json:"clinic_id"`
	OpenedByDoctorID uuid.UUID       `json:"opened_by_doctor_id"`
	Status           EncounterStatus `json:"status"`
	StartedAt        time.Time       `json:"started_at"`
	EndedAt          *time.Time      `json:"ended_at"`
	CreatedAt        time.Time       `json:"created_at"`
}
