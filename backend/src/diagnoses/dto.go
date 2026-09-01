package diagnoses

type CreateDiagnosisRequest struct {
	DiagnosisText string `json:"diagnosis_text" binding:"required"`
	ICDCode       string `json:"icd_code"`
	DiagnosisType string `json:"diagnosis_type" binding:"required,oneof=provisional final"`
	Notes         string `json:"notes"`
}
