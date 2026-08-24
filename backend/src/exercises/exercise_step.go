package exercises

// ExerciseStep represents a single step within an exercise.
type ExerciseStep struct {
	ID              string  `json:"step_id"`
	ExerciseID      string  `json:"exercise_id"`
	StepType        string  `json:"step_type"` // "TASK" or "BREAK"
	Title           string  `json:"title"`
	Instruction     *string `json:"instruction"` // nullable
	DurationSeconds int     `json:"duration_seconds"`
	SortOrder       int     `json:"sort_order"`
}
