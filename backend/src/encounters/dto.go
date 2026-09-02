package encounters

import (
	"time"

	"github.com/google/uuid"
)

// CreateEncounterRequest is the request body for POST /patients/:patientId/encounters.
type CreateEncounterRequest struct {
	// Optional consultation notes/reason
	Notes *string `json:"notes,omitempty" example:"Routine cardiovascular follow-up"`
}

// EncounterResponse wraps the encounter model.
type EncounterResponse struct {
	Encounter Encounter `json:"encounter"`
}

// VitalSignDTO represents a vital sign reading.
type VitalSignDTO struct {
	ID              uuid.UUID  `json:"id" example:"550e8400-e29b-41d4-a716-446655440004"`
	EncounterID     *uuid.UUID `json:"encounter_id,omitempty" example:"550e8400-e29b-41d4-a716-446655440005"`
	PatientID       *uuid.UUID `json:"patient_id,omitempty" example:"550e8400-e29b-41d4-a716-446655440000"`
	Source          string     `json:"source" example:"clinic"`
	SystolicBP      *int       `json:"systolic_bp" example:"120"`
	DiastolicBP     *int       `json:"diastolic_bp" example:"80"`
	Pulse           *int       `json:"pulse" example:"72"`
	RespiratoryRate *int       `json:"respiratory_rate" example:"16"`
	Temperature     *float64   `json:"temperature" example:"36.6"`
	Spo2            *float64   `json:"spo2" example:"98.0"`
	BloodSugar      *float64   `json:"blood_sugar" example:"5.5"`
	Weight          *float64   `json:"weight" example:"70.2"`
	RecordedAt      time.Time  `json:"recorded_at"`
}

// LabResultDTO represents laboratory test details.
type LabResultDTO struct {
	ID           uuid.UUID   `json:"id" example:"550e8400-e29b-41d4-a716-446655440006"`
	EncounterID  uuid.UUID   `json:"encounter_id" example:"550e8400-e29b-41d4-a716-446655440005"`
	TestName     string      `json:"test_name" example:"Lipid Profile"`
	Category     string      `json:"category" example:"Biochemistry"`
	SummaryNotes string      `json:"summary_notes" example:"Borderline high LDL cholesterol"`
	Measurements interface{} `json:"measurements"`
	Flag         *string     `json:"flag" example:"high"`
	CreatedAt    time.Time   `json:"created_at"`
}

// DiagnosisDTO represents a clinical diagnosis record.
type DiagnosisDTO struct {
	ID            uuid.UUID `json:"id" example:"550e8400-e29b-41d4-a716-446655440007"`
	EncounterID   uuid.UUID `json:"encounter_id" example:"550e8400-e29b-41d4-a716-446655440005"`
	DiagnosisText string    `json:"diagnosis_text" example:"Essential Hypertension"`
	ICDCode       *string   `json:"icd_code" example:"I10"`
	DiagnosisType string    `json:"diagnosis_type" example:"primary"`
	Notes         *string   `json:"notes" example:"Patient to monitor BP at home"`
	DiagnosedAt   time.Time `json:"diagnosed_at"`
}

// PrescriptionItemDTO represents an individual medication prescribed.
type PrescriptionItemDTO struct {
	ID             uuid.UUID `json:"id" example:"550e8400-e29b-41d4-a716-446655440008"`
	PrescriptionID uuid.UUID `json:"prescription_id" example:"550e8400-e29b-41d4-a716-446655440009"`
	MedicationName string    `json:"medication_name" example:"Lisinopril 10mg"`
	Dose           string    `json:"dose" example:"1 tablet"`
	Route          string    `json:"route" example:"oral"`
	Frequency      string    `json:"frequency" example:"once daily"`
	Duration       string    `json:"duration" example:"30 days"`
	Status         string    `json:"status" example:"active"`
	Instructions   *string   `json:"instructions" example:"Take in the morning with water"`
	StartedAt      time.Time `json:"started_at"`
}

// PrescriptionDTO represents the full prescription details.
type PrescriptionDTO struct {
	ID           uuid.UUID             `json:"id" example:"550e8400-e29b-41d4-a716-446655440009"`
	EncounterID  uuid.UUID             `json:"encounter_id" example:"550e8400-e29b-41d4-a716-446655440005"`
	Notes        *string               `json:"notes" example:"Refill for blood pressure management"`
	PrescribedAt time.Time             `json:"prescribed_at"`
	Items        []PrescriptionItemDTO `json:"items"`
}

// AggregatedEncounterResponse wraps all encounter-related records (vitals, labs, diagnoses, prescriptions).
type AggregatedEncounterResponse struct {
	Encounter     Encounter         `json:"encounter"`
	Vitals        []VitalSignDTO    `json:"vitals"`
	Labs          []LabResultDTO    `json:"labs"`
	Diagnoses     []DiagnosisDTO    `json:"diagnoses"`
	Prescriptions []PrescriptionDTO `json:"prescriptions"`
}

// MedicalHistoryPrescriptionItem represents prescription item details in medical history.
type MedicalHistoryPrescriptionItem struct {
	MedicationName string `json:"medication_name" example:"Lisinopril 10mg"`
	Dose           string `json:"dose" example:"1 tablet"`
	Route          string `json:"route" example:"oral"`
	Frequency      string `json:"frequency" example:"once daily"`
	Duration       string `json:"duration" example:"30 days"`
}

// MedicalHistoryVitals represents vitals details in medical history.
type MedicalHistoryVitals struct {
	SystolicBP      *int     `json:"systolic_bp" example:"120"`
	DiastolicBP     *int     `json:"diastolic_bp" example:"80"`
	Pulse           *int     `json:"pulse" example:"72"`
	// Respiratory rate (breaths per minute)
	RespiratoryRate *int     `json:"respiratory_rate" example:"16"`
	// Body temperature in Celsius
	Temperature     *float64 `json:"temperature" example:"36.6"`
	// Pulse oximetry (%)
	Spo2            *float64 `json:"spo2" example:"98.0"`
	// Blood sugar level (mmol/L)
	BloodSugar      *float64 `json:"blood_sugar" example:"5.5"`
	// Body weight in kilograms
	Weight          *float64 `json:"weight" example:"70.2"`
}

// MedicalHistoryResponse is the summary structure for past medical records.
type MedicalHistoryResponse struct {
	EncounterID    uuid.UUID                        `json:"encounter_id" example:"550e8400-e29b-41d4-a716-446655440005"`
	Date           time.Time                        `json:"date"`
	ChiefComplaint string                           `json:"chief_complaint" example:"Mild chest pain"`
	Diagnosis      *string                          `json:"diagnosis" example:"Essential Hypertension"`
	Prescription   []MedicalHistoryPrescriptionItem `json:"prescription"`
	Vitals         *MedicalHistoryVitals            `json:"vitals"`
}
