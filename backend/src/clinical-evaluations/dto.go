package clinicalevaluations

type CreateClinicalEvaluationRequest struct {
	ChiefComplaint          string      `json:"chief_complaint" binding:"required"`
	HistoryOfPresentIllness string      `json:"history_of_present_illness" binding:"required"`
	PastAdmissions          *string     `json:"past_admissions"`
	FamilyHistory           *string     `json:"family_history"`
	AllergiesNotes          *string     `json:"allergies_notes"`
	GeneralAppearance       *string     `json:"general_appearance"`
	SystemExamination       interface{} `json:"system_examination"`
}

type ClinicalEvaluationResponse struct {
	ClinicalEvaluation ClinicalEvaluation `json:"clinical_evaluation"`
}
