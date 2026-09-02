package prescriptions

import (
	"time"

	"github.com/google/uuid"
)

type Prescription struct {
	ID           uuid.UUID
	EncounterID  uuid.UUID
	Notes        *string
	PrescribedAt time.Time
}
