package crisis

import "time"

// CrisisResource represents a crisis contact resource managed by admins.
// Only PUBLISHED resources are visible to end users.
type CrisisResource struct {
	ID        int       `json:"id"`
	Label     string    `json:"label"`
	Phone     string    `json:"phone"`
	SortOrder int       `json:"sort_order"`
	Status    string    `json:"status"` // "DRAFT" or "PUBLISHED"
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
