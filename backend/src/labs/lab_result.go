package labs

import (
	"time"

	"github.com/google/uuid"
)

type LabResult struct {
	ID           uuid.UUID              `json:"id"`
	EncounterID  uuid.UUID              `json:"encounter_id"`
	TestName     string                 `json:"test_name"`
	Category     string                 `json:"category"`
	SummaryNotes string                 `json:"summary_notes"`
	Measurements map[string]interface{} `json:"measurements"`
	Flag         *string                `json:"flag"`
	CreatedAt    time.Time              `json:"created_at"`
}
