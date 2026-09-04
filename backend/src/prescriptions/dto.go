package prescriptions

type CreatePrescriptionItemRequest struct {
	MedicationName string                `json:"medication_name" binding:"required"`
	Dose           string                `json:"dose"            binding:"required"`
	Route          PrescriptionRoute     `json:"route"           binding:"required"`
	Frequency      PrescriptionFrequency `json:"frequency"       binding:"required"`
	DurationValue  int                   `json:"duration_value" binding:"required,gt=0"`
	DurationUnit   DurationUnit          `json:"duration_unit"  binding:"required,oneof=day week month year"`
	Instructions   *string               `json:"instructions"`
}

type CreatePrescriptionRequest struct {
	Notes *string                         `json:"notes"`
	Items []CreatePrescriptionItemRequest `json:"items" binding:"required,min=1"`
}

type UpdatePrescriptionItemRequest struct {
	MedicationName string                `json:"medication_name" binding:"required"`
	Dose           string                `json:"dose"            binding:"required"`
	Route          PrescriptionRoute     `json:"route"           binding:"required"`
	Frequency      PrescriptionFrequency `json:"frequency"       binding:"required"`
	DurationValue  int                   `json:"duration_value" binding:"required,gt=0"`
	DurationUnit   DurationUnit          `json:"duration_unit"  binding:"required,oneof=day week month year"`
	Instructions   *string               `json:"instructions"`
}

type UpdatePrescriptionRequest struct {
	Notes *string                         `json:"notes"`
	Items []UpdatePrescriptionItemRequest `json:"items"`
}

type CompletePrescriptionRequest struct {
	ItemIDs []string `json:"item_ids"`
}

type PrescriptionResponse struct {
	Prescription
	Items []PrescriptionItem `json:"items"`
}
