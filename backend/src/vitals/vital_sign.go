package vitals

import (
	"time"

	"github.com/google/uuid"
)

type VitalSource string

const (
	SourceClinic  VitalSource = "clinic"
	SourcePatient VitalSource = "patient"
)

type VitalSign struct {
	ID              uuid.UUID
	EncounterID     *uuid.UUID // nullable, nil for patient self-logs
	PatientID       uuid.UUID
	Source          VitalSource
	ClientID        *uuid.UUID // nullable client-generated dedup token
	SystolicBP      *int
	DiastolicBP     *int
	Pulse           *int
	RespiratoryRate *int
	Temperature     *float64
	SpO2            *float64
	BloodSugar      *float64
	Weight          *float64
	RecordedAt      time.Time
}
