package clinicalevaluations

// CreateClinicalEvaluationRequest is the request body for POST /encounters/:id/clinical-evaluation.
type CreateClinicalEvaluationRequest struct {
	// Primary reason for the medical visit
	ChiefComplaint string `json:"chief_complaint" binding:"required" example:"Mild chest pain and shortness of breath"`
	// Detailed chronological account of the patient's current illness/symptoms
	HistoryOfPresentIllness string `json:"history_of_present_illness" binding:"required" example:"Symptom started 2 days ago after exercise, radiates to left shoulder"`
	// Notes on any past hospital admissions/surgeries
	PastAdmissions *string `json:"past_admissions" example:"Appendectomy in 2018"`
	// Summary of heredofamilial diseases
	FamilyHistory *string `json:"family_history" example:"Father has history of coronary artery disease"`
	// Details of drug, food, or environmental allergies
	AllergiesNotes *string `json:"allergies_notes" example:"Allergic to penicillin"`
	// General physical assessment notes
	GeneralAppearance *string `json:"general_appearance" example:"Alert, cooperative, in no acute distress"`
	// Results of systems review (JSON structured object)
	SystemExamination interface{} `json:"system_examination"`
}

// ClinicalEvaluationResponse wraps the clinical evaluation result.
type ClinicalEvaluationResponse struct {
	ClinicalEvaluation ClinicalEvaluation `json:"clinical_evaluation"`
}
