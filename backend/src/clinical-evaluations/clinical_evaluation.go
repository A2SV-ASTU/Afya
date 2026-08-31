package clinicalevaluations

import (
	"time"

	"github.com/google/uuid"
)

type ClinicalEvaluation struct {
	ID                      uuid.UUID   `json:"id"`
	EncounterID             uuid.UUID   `json:"encounter_id"`
	ChiefComplaint          string      `json:"chief_complaint"`
	HistoryOfPresentIllness string      `json:"history_of_present_illness"`
	PastAdmissions          *string     `json:"past_admissions"`
	FamilyHistory           *string     `json:"family_history"`
	AllergiesNotes          *string     `json:"allergies_notes"`
	GeneralAppearance       *string     `json:"general_appearance"`
	SystemExamination       interface{} `json:"system_examination"`
	CreatedAt               time.Time   `json:"created_at"`
}
