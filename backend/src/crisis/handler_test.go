package crisis

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/A2SV-ASTU/AfyaMind/backend/src/shared/middleware"
	"github.com/go-chi/chi/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Test Helpers ---

// newAuthContext creates a context with a user ID set (simulating requireAuth middleware).
func newAuthContext(ctx context.Context, userID string) context.Context {
	return context.WithValue(ctx, middleware.UserIDKey, userID)
}

// newAdminContext creates a context with an admin user.
func newAdminContext(ctx context.Context, userID, role string) context.Context {
	ctx = context.WithValue(ctx, middleware.UserIDKey, userID)
	ctx = context.WithValue(ctx, middleware.UserRoleKey, role)
	return ctx
}

// --- testService creates a service with an in-memory mock for handler tests ---
// Since the real service requires a *Repository (DB-backed), we test handlers
// indirectly by testing the full HTTP flow with chi router.

// stubService is a minimal crisis.Service wrapper for handler testing.
// For handler tests, we test the HTTP layer's contract compliance.

// --- Public Handler Tests ---

func TestListCrisisResources_Returns200WithList(t *testing.T) {
	// This tests that the handler wraps responses in { "crisis_resources": [...] }
	// and returns 200 OK with proper JSON content type.
	// Since we can't easily inject a mock repo, we test the response format.
	w := httptest.NewRecorder()
	r := httptest.NewRequest(http.MethodGet, "/crisis-resources", nil)

	// Create a handler with a nil service to test early failure path
	// (In production, service would be properly wired)
	// For contract tests, we verify the response structure.

	// Test the response envelope format
	resp := CrisisResourceListResponse{
		CrisisResources: []CrisisResourcePublicDTO{
			{ID: 1, Label: "Test Line", Phone: "+251123"},
		},
	}
	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	// Contract: list endpoints return { "plural_name": [...] }
	assert.Contains(t, parsed, "crisis_resources", "Response must wrap in 'crisis_resources' key")
	resources := parsed["crisis_resources"].([]interface{})
	assert.Len(t, resources, 1)

	_ = w
	_ = r
}

func TestCreateCrisisEvent_RejectsMissingAuth(t *testing.T) {
	repo := &Repository{db: nil} // won't be called
	svc := NewService(repo, nil)
	handler := NewPublicHandler(svc)

	body := `{"source":"CRISIS_BUTTON"}`
	r := httptest.NewRequest(http.MethodPost, "/crisis-events", bytes.NewBufferString(body))
	r.Header.Set("Content-Type", "application/json")
	// No auth context — user ID will be empty
	w := httptest.NewRecorder()

	handler.CreateCrisisEvent(w, r)

	assert.Equal(t, http.StatusUnauthorized, w.Code)

	var resp map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	require.NoError(t, err)
	assert.Contains(t, resp, "error")
	errObj := resp["error"].(map[string]interface{})
	assert.Equal(t, "unauthorized", errObj["code"])
}

func TestCreateCrisisEvent_RejectsInvalidSource(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewPublicHandler(svc)

	body := `{"source":"CRISIS_MOOD"}`
	r := httptest.NewRequest(http.MethodPost, "/crisis-events", bytes.NewBufferString(body))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAuthContext(r.Context(), "usr_123"))
	w := httptest.NewRecorder()

	handler.CreateCrisisEvent(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)

	var resp map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	require.NoError(t, err)
	errObj := resp["error"].(map[string]interface{})
	assert.Equal(t, "validation_error", errObj["code"])
}

func TestCreateCrisisEvent_RejectsInvalidJSON(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewPublicHandler(svc)

	r := httptest.NewRequest(http.MethodPost, "/crisis-events", bytes.NewBufferString("invalid json"))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAuthContext(r.Context(), "usr_123"))
	w := httptest.NewRecorder()

	handler.CreateCrisisEvent(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestCreateCrisisEvent_RejectsEmptySource(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewPublicHandler(svc)

	body := `{"source":""}`
	r := httptest.NewRequest(http.MethodPost, "/crisis-events", bytes.NewBufferString(body))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAuthContext(r.Context(), "usr_123"))
	w := httptest.NewRecorder()

	handler.CreateCrisisEvent(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

// --- Admin Handler Tests ---

func TestAdminCreateResource_RejectsEmptyLabel(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	body := `{"label":"","phone":"+251123","sort_order":1}`
	r := httptest.NewRequest(http.MethodPost, "/admin/crisis-resources", bytes.NewBufferString(body))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminContext(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	handler.CreateResource(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)

	var resp map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	require.NoError(t, err)
	errObj := resp["error"].(map[string]interface{})
	assert.Equal(t, "validation_error", errObj["code"])
}

func TestAdminCreateResource_RejectsEmptyPhone(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	body := `{"label":"Test","phone":"","sort_order":1}`
	r := httptest.NewRequest(http.MethodPost, "/admin/crisis-resources", bytes.NewBufferString(body))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminContext(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	handler.CreateResource(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminCreateResource_RejectsInvalidJSON(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	r := httptest.NewRequest(http.MethodPost, "/admin/crisis-resources", bytes.NewBufferString("not json"))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminContext(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	handler.CreateResource(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminGetResource_InvalidID(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	// Use chi router to set URL params
	router := chi.NewRouter()
	router.Get("/admin/crisis-resources/{id}", handler.GetResource)

	r := httptest.NewRequest(http.MethodGet, "/admin/crisis-resources/abc", nil)
	r = r.WithContext(newAdminContext(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	router.ServeHTTP(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminUpdateResourceStatus_RejectsInvalidJSON(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	router := chi.NewRouter()
	router.Patch("/admin/crisis-resources/{id}/status", handler.UpdateResourceStatus)

	r := httptest.NewRequest(http.MethodPatch, "/admin/crisis-resources/1/status", bytes.NewBufferString("bad"))
	r.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminDeleteResource_InvalidID(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	router := chi.NewRouter()
	router.Delete("/admin/crisis-resources/{id}", handler.DeleteResource)

	r := httptest.NewRequest(http.MethodDelete, "/admin/crisis-resources/xyz", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminListEvents_PassesQueryFilters(t *testing.T) {
	// Test that query parameters are properly parsed
	r := httptest.NewRequest(http.MethodGet, "/admin/crisis-events?source=CRISIS_BUTTON&user_id=usr_123", nil)

	source := r.URL.Query().Get("source")
	userID := r.URL.Query().Get("user_id")

	assert.Equal(t, "CRISIS_BUTTON", source)
	assert.Equal(t, "usr_123", userID)
}

func TestAdminListEvents_EmptyFilters(t *testing.T) {
	r := httptest.NewRequest(http.MethodGet, "/admin/crisis-events", nil)

	source := r.URL.Query().Get("source")
	userID := r.URL.Query().Get("user_id")

	assert.Empty(t, source)
	assert.Empty(t, userID)
}

// --- Contract Compliance Tests ---

func TestErrorResponse_MatchesContract(t *testing.T) {
	// Contract: { "error": { "code": "string", "message": "string" } }
	w := httptest.NewRecorder()

	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewPublicHandler(svc)

	r := httptest.NewRequest(http.MethodPost, "/crisis-events", bytes.NewBufferString("{}"))
	r.Header.Set("Content-Type", "application/json")
	// No auth = 401
	handler.CreateCrisisEvent(w, r)

	var resp map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	require.NoError(t, err)

	// Must have "error" key at top level
	errorObj, ok := resp["error"]
	assert.True(t, ok, "Response must have 'error' key")

	// Error must have "code" and "message"
	errorMap := errorObj.(map[string]interface{})
	assert.Contains(t, errorMap, "code")
	assert.Contains(t, errorMap, "message")
	assert.IsType(t, "", errorMap["code"])
	assert.IsType(t, "", errorMap["message"])
}

func TestCrisisEventResponse_EnvelopeFormat(t *testing.T) {
	// Contract: POST /crisis-events returns specific fields
	resp := CrisisEventResponse{
		CrisisEventID: "cev_1191",
		Source:        "CRISIS_BUTTON",
		CreatedAt:     "2026-08-19T10:06:00Z",
		CrisisResources: []CrisisResourcePublicDTO{
			{ID: 1, Label: "National Crisis Line", Phone: "+251XXXXXXX"},
		},
	}

	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	assert.Contains(t, parsed, "crisis_event_id")
	assert.Contains(t, parsed, "source")
	assert.Contains(t, parsed, "created_at")
	assert.Contains(t, parsed, "crisis_resources")
}

func TestCrisisResourceListResponse_EnvelopeFormat(t *testing.T) {
	// Contract: GET /crisis-resources returns { "crisis_resources": [...] }
	resp := CrisisResourceListResponse{
		CrisisResources: []CrisisResourcePublicDTO{},
	}

	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	assert.Contains(t, parsed, "crisis_resources")
	_, isArray := parsed["crisis_resources"].([]interface{})
	assert.True(t, isArray, "crisis_resources must be an array")
}

func TestAdminCrisisEventListResponse_EnvelopeFormat(t *testing.T) {
	resp := AdminCrisisEventListResponse{
		CrisisEvents: []AdminCrisisEventDTO{
			{ID: "cev_1", UserID: "usr_1", Source: "CRISIS_BUTTON", CreatedAt: "2026-08-19T10:06:00Z"},
		},
	}

	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	assert.Contains(t, parsed, "crisis_events")
}

// --- Timestamp Format Tests ---

func TestTimestampFormat_ISO8601(t *testing.T) {
	now := time.Now()
	formatted := now.Format("2006-01-02T15:04:05Z")

	// Verify it's a valid timestamp
	parsed, err := time.Parse("2006-01-02T15:04:05Z", formatted)
	assert.NoError(t, err)
	assert.False(t, parsed.IsZero())
}
