package crisis

// --- Public DTOs ---

// CreateCrisisEventRequest is the request body for POST /crisis-events.
// Source must be "CRISIS_BUTTON" — "CRISIS_MOOD" is only set server-side by POST /mood-entries.
type CreateCrisisEventRequest struct {
	Source string `json:"source"`
}

// CrisisEventResponse is the response for POST /crisis-events.
type CrisisEventResponse struct {
	CrisisEventID   string                    `json:"crisis_event_id"`
	Source          string                    `json:"source"`
	CreatedAt       string                    `json:"created_at"`
	CrisisResources []CrisisResourcePublicDTO `json:"crisis_resources"`
}

// CrisisResourcePublicDTO is the public-facing representation of a crisis resource.
type CrisisResourcePublicDTO struct {
	ID    int    `json:"id"`
	Label string `json:"label"`
	Phone string `json:"phone"`
}

// CrisisResourceListResponse wraps the list of public crisis resources.
type CrisisResourceListResponse struct {
	CrisisResources []CrisisResourcePublicDTO `json:"crisis_resources"`
}

// --- Admin DTOs ---

// AdminCrisisResourceDTO is the admin-facing representation including status.
type AdminCrisisResourceDTO struct {
	ID        int    `json:"id"`
	Label     string `json:"label"`
	Phone     string `json:"phone"`
	SortOrder int    `json:"sort_order"`
	Status    string `json:"status"`
	CreatedAt string `json:"created_at,omitempty"`
	UpdatedAt string `json:"updated_at,omitempty"`
}

// AdminCrisisResourceListResponse wraps the admin list of crisis resources.
type AdminCrisisResourceListResponse struct {
	CrisisResources []AdminCrisisResourceDTO `json:"crisis_resources"`
}

// CreateCrisisResourceRequest is the request body for POST /admin/crisis-resources.
type CreateCrisisResourceRequest struct {
	Label     string `json:"label"`
	Phone     string `json:"phone"`
	SortOrder int    `json:"sort_order"`
}

// CreateCrisisResourceResponse is the response for POST /admin/crisis-resources.
type CreateCrisisResourceResponse struct {
	ID     int    `json:"id"`
	Label  string `json:"label"`
	Status string `json:"status"`
}

// UpdateCrisisResourceRequest is the request body for PATCH /admin/crisis-resources/:id.
type UpdateCrisisResourceRequest struct {
	Label     *string `json:"label,omitempty"`
	Phone     *string `json:"phone,omitempty"`
	SortOrder *int    `json:"sort_order,omitempty"`
}

// UpdateStatusRequest is the request body for PATCH /admin/crisis-resources/:id/status.
type UpdateStatusRequest struct {
	Status string `json:"status"`
}

// AdminCrisisEventDTO is the admin-facing representation of a crisis event.
type AdminCrisisEventDTO struct {
	ID        string `json:"id"`
	UserID    string `json:"user_id"`
	Source    string `json:"source"`
	CreatedAt string `json:"created_at"`
}

// AdminCrisisEventListResponse wraps the admin list of crisis events.
type AdminCrisisEventListResponse struct {
	CrisisEvents []AdminCrisisEventDTO `json:"crisis_events"`
}
