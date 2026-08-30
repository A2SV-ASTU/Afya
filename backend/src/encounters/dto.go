package encounters

import (
	"time"

	"github.com/google/uuid"
)

type CreateEncounterRequest struct {
	Notes *string `json:"notes,omitempty"`
}

type EncounterResponse struct {
	Encounter Encounter `json:"encounter"`
}

type VitalSignDTO struct {
	ID              uuid.UUID  `json:"id"`
	EncounterID     *uuid.UUID `json:"encounter_id,omitempty"`
	PatientID       *uuid.UUID `json:"patient_id,omitempty"`
	Source          string     `json:"source"`
	SystolicBP      *int       `json:"systolic_bp"`
	DiastolicBP     *int       `json:"diastolic_bp"`
	Pulse           *int       `json:"pulse"`
	RespiratoryRate *int       `json:"respiratory_rate"`
	Temperature     *float64   `json:"temperature"`
	Spo2            *float64   `json:"spo2"`
	BloodSugar      *float64   `json:"blood_sugar"`
	Weight          *float64   `json:"weight"`
	RecordedAt      time.Time  `json:"recorded_at"`
}

type LabResultDTO struct {
	ID           uuid.UUID   `json:"id"`
	EncounterID  uuid.UUID   `json:"encounter_id"`
	TestName     string      `json:"test_name"`
	Category     string      `json:"category"`
	SummaryNotes string      `json:"summary_notes"`
	Measurements interface{} `json:"measurements"`
	Flag         *string     `json:"flag"`
	CreatedAt    time.Time   `json:"created_at"`
}

type DiagnosisDTO struct {
	ID            uuid.UUID `json:"id"`
	EncounterID   uuid.UUID `json:"encounter_id"`
	DiagnosisText string    `json:"diagnosis_text"`
	ICDCode       *string   `json:"icd_code"`
	DiagnosisType string    `json:"diagnosis_type"`
	Notes         *string   `json:"notes"`
	DiagnosedAt   time.Time `json:"diagnosed_at"`
}

type PrescriptionItemDTO struct {
	ID             uuid.UUID `json:"id"`
	PrescriptionID uuid.UUID `json:"prescription_id"`
	MedicationName string    `json:"medication_name"`
	Dose           string    `json:"dose"`
	Route          string    `json:"route"`
	Frequency      string    `json:"frequency"`
	Duration       string    `json:"duration"`
	Status         string    `json:"status"`
	Instructions   *string   `json:"instructions"`
	StartedAt      time.Time `json:"started_at"`
}

type PrescriptionDTO struct {
	ID           uuid.UUID             `json:"id"`
	EncounterID  uuid.UUID             `json:"encounter_id"`
	Notes        *string               `json:"notes"`
	PrescribedAt time.Time             `json:"prescribed_at"`
	Items        []PrescriptionItemDTO `json:"items"`
}

type AggregatedEncounterResponse struct {
	Encounter     Encounter         `json:"encounter"`
	Vitals        []VitalSignDTO    `json:"vitals"`
	Labs          []LabResultDTO    `json:"labs"`
	Diagnoses     []DiagnosisDTO    `json:"diagnoses"`
	Prescriptions []PrescriptionDTO `json:"prescriptions"`
}

type MedicalHistoryPrescriptionItem struct {
	MedicationName string `json:"medication_name"`
	Dose           string `json:"dose"`
	Route          string `json:"route"`
	Frequency      string `json:"frequency"`
	Duration       string `json:"duration"`
}

type MedicalHistoryVitals struct {
	SystolicBP      *int     `json:"systolic_bp"`
	DiastolicBP     *int     `json:"diastolic_bp"`
	Pulse           *int     `json:"pulse"`
	RespiratoryRate *int     `json:"respiratory_rate"`
	Temperature     *float64 `json:"temperature"`
	Spo2            *float64 `json:"spo2"`
	BloodSugar      *float64 `json:"blood_sugar"`
	Weight          *float64 `json:"weight"`
}

type MedicalHistoryResponse struct {
	EncounterID    uuid.UUID                        `json:"encounter_id"`
	Date           time.Time                        `json:"date"`
	ChiefComplaint string                           `json:"chief_complaint"`
	Diagnosis      *string                          `json:"diagnosis"`
	Prescription   []MedicalHistoryPrescriptionItem `json:"prescription"`
	Vitals         *MedicalHistoryVitals            `json:"vitals"`
}
