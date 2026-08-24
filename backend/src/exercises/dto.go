package exercises

// --- Public DTOs ---

// ExerciseListItem is the public list representation (no steps, no description).
type ExerciseListItem struct {
	ExerciseID string `json:"exercise_id"`
	Slug       string `json:"slug"`
	Title      string `json:"title"`
	Language   string `json:"language"`
}

// ExerciseListResponse wraps the list of exercises.
type ExerciseListResponse struct {
	Exercises []ExerciseListItem `json:"exercises"`
}

// StepDTO is a step as returned within an exercise detail response.
type StepDTO struct {
	StepID          string  `json:"step_id"`
	StepType        string  `json:"step_type"`
	Title           string  `json:"title"`
	Instruction     *string `json:"instruction"`
	DurationSeconds int     `json:"duration_seconds"`
	SortOrder       int     `json:"sort_order"`
}

// ExerciseDetailResponse is the full exercise with steps.
type ExerciseDetailResponse struct {
	ExerciseID  string    `json:"exercise_id"`
	Slug        string    `json:"slug"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Language    string    `json:"language"`
	Status      string    `json:"status"`
	Steps       []StepDTO `json:"steps"`
}

// StartResponse is the response for POST /exercises/:exercise_id/start.
type StartResponse struct {
	CompletionID string `json:"completion_id"`
	ExerciseID   string `json:"exercise_id"`
	Progress     int    `json:"progress"`
	Status       string `json:"status"`
}

// ProgressRequest is the request for PATCH /exercises/:exercise_id/progress.
type ProgressRequest struct {
	Progress int `json:"progress"`
}

// ProgressResponse is the response for PATCH /exercises/:exercise_id/progress.
type ProgressResponse struct {
	CompletionID string `json:"completion_id"`
	Progress     int    `json:"progress"`
	Status       string `json:"status"`
}

// CompleteResponse is the response for POST /exercises/:exercise_id/complete.
type CompleteResponse struct {
	CompletionID string `json:"completion_id"`
	Status       string `json:"status"`
	CompletedAt  string `json:"completed_at"`
}

// CompletionHistoryItem is a single item in the completion history.
type CompletionHistoryItem struct {
	CompletionID string  `json:"completion_id"`
	ExerciseID   string  `json:"exercise_id"`
	Status       string  `json:"status"`
	Progress     int     `json:"progress"`
	CompletedAt  *string `json:"completed_at,omitempty"`
}

// CompletionHistoryResponse wraps the list of completions.
type CompletionHistoryResponse struct {
	Completions []CompletionHistoryItem `json:"completions"`
}

// --- Admin DTOs ---

// AdminExerciseListItem is the admin list item (includes status).
type AdminExerciseListItem struct {
	ExerciseID string `json:"exercise_id"`
	Slug       string `json:"slug"`
	Title      string `json:"title"`
	Language   string `json:"language"`
	Status     string `json:"status"`
}

// AdminExerciseListResponse wraps the admin exercise list.
type AdminExerciseListResponse struct {
	Exercises []AdminExerciseListItem `json:"exercises"`
}

// CreateExerciseRequest is the request for POST /admin/exercises.
type CreateExerciseRequest struct {
	Slug        string `json:"slug"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Language    string `json:"language"`
}

// UpdateExerciseRequest is the request for PATCH /admin/exercises/:id.
type UpdateExerciseRequest struct {
	Slug        *string `json:"slug,omitempty"`
	Title       *string `json:"title,omitempty"`
	Description *string `json:"description,omitempty"`
	Language    *string `json:"language,omitempty"`
}

// UpdateExerciseStatusRequest is the request for PATCH /admin/exercises/:id/status.
type UpdateExerciseStatusRequest struct {
	Status string `json:"status"`
}

// UpdateExerciseStatusResponse is the response for status changes.
type UpdateExerciseStatusResponse struct {
	ExerciseID string `json:"exercise_id"`
	Status     string `json:"status"`
}

// CreateStepRequest is the request for POST /admin/exercises/:id/steps.
type CreateStepRequest struct {
	StepType        string  `json:"step_type"`
	Title           string  `json:"title"`
	Instruction     *string `json:"instruction,omitempty"`
	DurationSeconds int     `json:"duration_seconds"`
	SortOrder       int     `json:"sort_order"`
}

// UpdateStepRequest is the request for PATCH /admin/exercise-steps/:id.
type UpdateStepRequest struct {
	StepType        *string `json:"step_type,omitempty"`
	Title           *string `json:"title,omitempty"`
	Instruction     *string `json:"instruction,omitempty"`
	DurationSeconds *int    `json:"duration_seconds,omitempty"`
	SortOrder       *int    `json:"sort_order,omitempty"`
}
