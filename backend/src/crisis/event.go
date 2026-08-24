package crisis

import "time"

// CrisisEvent records that a user entered the crisis flow.
// Per the ERD, this entity NEVER stores free-text or model-generated content —
// only source, user_id, and created_at.
type CrisisEvent struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Source    string    `json:"source"` // "CRISIS_BUTTON" or "CRISIS_MOOD"
	CreatedAt time.Time `json:"created_at"`
}

// Valid sources for CrisisEvent.
const (
	SourceCrisisButton = "CRISIS_BUTTON"
	SourceCrisisMood   = "CRISIS_MOOD"
)
