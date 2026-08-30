package vitals

import (
	"time"

	"github.com/google/uuid"
)

type RecordEncounterVitalsRequest struct {
	SystolicBP      *int       `json:"systolic_bp"`
	DiastolicBP     *int       `json:"diastolic_bp"`
	Pulse           *int       `json:"pulse"`
	RespiratoryRate *int       `json:"respiratory_rate"`
	Temperature     *float64   `json:"temperature"`
	SpO2            *float64   `json:"spo2"`
	BloodSugar      *float64   `json:"blood_sugar"`
	Weight          *float64   `json:"weight"`
	RecordedAt      *time.Time `json:"recorded_at"`
}

type LogPatientVitalRequest struct {
	SystolicBP      *int       `json:"systolic_bp"`
	DiastolicBP     *int       `json:"diastolic_bp"`
	Pulse           *int       `json:"pulse"`
	RespiratoryRate *int       `json:"respiratory_rate"`
	Temperature     *float64   `json:"temperature"`
	SpO2            *float64   `json:"spo2"`
	BloodSugar      *float64   `json:"blood_sugar"`
	Weight          *float64   `json:"weight"`
	RecordedAt      *time.Time `json:"recorded_at"`
}

type SyncVitalEntry struct {
	ClientID        uuid.UUID  `json:"client_id" binding:"required"`
	SystolicBP      *int       `json:"systolic_bp"`
	DiastolicBP     *int       `json:"diastolic_bp"`
	Pulse           *int       `json:"pulse"`
	RespiratoryRate *int       `json:"respiratory_rate"`
	Temperature     *float64   `json:"temperature"`
	SpO2            *float64   `json:"spo2"`
	BloodSugar      *float64   `json:"blood_sugar"`
	Weight          *float64   `json:"weight"`
	RecordedAt      *time.Time `json:"recorded_at"`
}

type SyncVitalsRequest struct {
	Vitals []SyncVitalEntry `json:"vitals" binding:"required,min=1"`
}

type SyncVitalResult struct {
	ClientID uuid.UUID `json:"client_id"`
	ID       uuid.UUID `json:"id"`
	Created  bool      `json:"created"`
}

type SyncVitalsResponse struct {
	Results []SyncVitalResult `json:"results"`
}

type DoctorSyncQuery struct {
	Since *time.Time `form:"since" time_format:"2006-01-02T15:04:05Z07:00"`
}

type AckVitalsRequest struct {
	SyncedIDs []uuid.UUID `json:"synced_ids" binding:"required,min=1"`
}

type ListVitalsQuery struct {
	From   *time.Time   `form:"from"   time_format:"2006-01-02T15:04:05Z07:00"`
	To     *time.Time   `form:"to"     time_format:"2006-01-02T15:04:05Z07:00"`
	Source *VitalSource `form:"source"`
}
