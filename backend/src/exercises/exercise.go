package exercises

import "time"

// Exercise represents a guided exercise (e.g., "Box Breathing").
// Only PUBLISHED exercises are visible to end users.
type Exercise struct {
	ID          string    `json:"exercise_id"`
	Slug        string    `json:"slug"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Language    string    `json:"language"`
	Status      string    `json:"status"` // "DRAFT" or "PUBLISHED"
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
