package diagnoses

import (
	"time"

	"github.com/google/uuid"
)

type Diagnosis struct {
	ID            uuid.UUID `json:"id"`
	EncounterID   uuid.UUID `json:"encounter_id"`
	DiagnosisText string    `json:"diagnosis_text"`
	ICDCode       *string   `json:"icd_code"`
	DiagnosisType string    `json:"diagnosis_type"`
	Notes         *string   `json:"notes"`
	DiagnosedAt   time.Time `json:"diagnosed_at"`
}
