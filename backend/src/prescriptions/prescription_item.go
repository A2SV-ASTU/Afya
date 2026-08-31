package prescriptions

import (
	"time"

	"github.com/google/uuid"
)

type PrescriptionRoute string

const (
	RouteOral         PrescriptionRoute = "oral"
	RouteIV           PrescriptionRoute = "iv"
	RouteIM           PrescriptionRoute = "im"
	RouteSubcutaneous PrescriptionRoute = "subcutaneous"
	RouteTopical      PrescriptionRoute = "topical"
	RouteOther        PrescriptionRoute = "other"
)

type PrescriptionFrequency string

const (
	FreqOD   PrescriptionFrequency = "OD"
	FreqBD   PrescriptionFrequency = "BD"
	FreqTDS  PrescriptionFrequency = "TDS"
	FreqQID  PrescriptionFrequency = "QID"
	FreqQHS  PrescriptionFrequency = "QHS"
	FreqPRN  PrescriptionFrequency = "PRN"
	FreqSTAT PrescriptionFrequency = "STAT"
	FreqQ4H  PrescriptionFrequency = "Q4H"
	FreqQ6H  PrescriptionFrequency = "Q6H"
	FreqQ8H  PrescriptionFrequency = "Q8H"
	FreqQ12H PrescriptionFrequency = "Q12H"
)

type PrescriptionItemStatus string

const (
	ItemStatusActive      PrescriptionItemStatus = "active"
	ItemStatusDeactivated PrescriptionItemStatus = "deactivated"
	ItemStatusCompleted   PrescriptionItemStatus = "completed"
)

type PrescriptionItem struct {
	ID             uuid.UUID
	PrescriptionID uuid.UUID
	MedicationName string
	Dose           string
	Route          PrescriptionRoute
	Frequency      PrescriptionFrequency
	Duration       string
	Status         PrescriptionItemStatus
	Instructions   *string
	StartedAt      time.Time
}
