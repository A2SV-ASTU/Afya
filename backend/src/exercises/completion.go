package exercises

import "time"

// ExerciseCompletion tracks a user's progress through an exercise.
type ExerciseCompletion struct {
	ID          string     `json:"completion_id"`
	ExerciseID  string     `json:"exercise_id"`
	UserID      string     `json:"user_id"`
	Progress    int        `json:"progress"`
	Status      string     `json:"status"` // "IN_PROGRESS" or "COMPLETED"
	CompletedAt *time.Time `json:"completed_at,omitempty"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
}

// Completion statuses.
const (
	StatusInProgress = "IN_PROGRESS"
	StatusCompleted  = "COMPLETED"
)
