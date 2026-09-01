package labs

type CreateLabResultRequest struct {
	TestName     string                 `json:"test_name" binding:"required"`
	Category     string                 `json:"category" binding:"required,oneof=laboratory imaging pathology other"`
	SummaryNotes string                 `json:"summary_notes"`
	Measurements map[string]interface{} `json:"measurements"`
	Flag         string                 `json:"flag" binding:"omitempty,oneof=normal abnormal critical"`
}
