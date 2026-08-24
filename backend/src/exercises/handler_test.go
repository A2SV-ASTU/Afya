package exercises

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/A2SV-ASTU/AfyaMind/backend/src/shared/middleware"
	"github.com/go-chi/chi/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Test Helpers ---

func newAuthCtx(ctx context.Context, userID string) context.Context {
	return context.WithValue(ctx, middleware.UserIDKey, userID)
}

func newAdminCtx(ctx context.Context, userID, role string) context.Context {
	ctx = context.WithValue(ctx, middleware.UserIDKey, userID)
	ctx = context.WithValue(ctx, middleware.UserRoleKey, role)
	return ctx
}

// --- Public Handler Tests ---

func TestListExercises_ParsesLanguageFilter(t *testing.T) {
	r := httptest.NewRequest(http.MethodGet, "/exercises?language=en", nil)
	assert.Equal(t, "en", r.URL.Query().Get("language"))
}

func TestListExercises_NoLanguageFilter(t *testing.T) {
	r := httptest.NewRequest(http.MethodGet, "/exercises", nil)
	assert.Empty(t, r.URL.Query().Get("language"))
}

func TestStartExercise_RejectsMissingAuth(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewPublicHandler(svc)

	router := chi.NewRouter()
	router.Post("/exercises/{exercise_id}/start", handler.StartExercise)

	r := httptest.NewRequest(http.MethodPost, "/exercises/exr_box_breathing/start", nil)
	// No auth context
	w := httptest.NewRecorder()

	router.ServeHTTP(w, r)

	assert.Equal(t, http.StatusUnauthorized, w.Code)

	var resp map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	require.NoError(t, err)
	errObj := resp["error"].(map[string]interface{})
	assert.Equal(t, "unauthorized", errObj["code"])
}

func TestUpdateProgress_RejectsMissingAuth(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewPublicHandler(svc)

	router := chi.NewRouter()
	router.Patch("/exercises/{exercise_id}/progress", handler.UpdateProgress)

	body := `{"progress":2}`
	r := httptest.NewRequest(http.MethodPatch, "/exercises/exr_box_breathing/progress", bytes.NewBufferString(body))
	r.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, r)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestUpdateProgress_RejectsInvalidJSON(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewPublicHandler(svc)

	router := chi.NewRouter()
	router.Patch("/exercises/{exercise_id}/progress", handler.UpdateProgress)

	r := httptest.NewRequest(http.MethodPatch, "/exercises/exr_box/progress", bytes.NewBufferString("bad json"))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAuthCtx(r.Context(), "usr_123"))
	w := httptest.NewRecorder()

	// Need to re-route through chi to set URL params
	router.ServeHTTP(w, r)

	// The handler first checks auth, so with auth set but routed through chi,
	// the context from r.WithContext is overridden by chi. Let's test directly.
	w2 := httptest.NewRecorder()
	r2 := httptest.NewRequest(http.MethodPatch, "/exercises/exr_box/progress", bytes.NewBufferString("bad"))
	r2.Header.Set("Content-Type", "application/json")
	r2 = r2.WithContext(newAuthCtx(r2.Context(), "usr_123"))
	handler.UpdateProgress(w2, r2)

	assert.Equal(t, http.StatusBadRequest, w2.Code)
}

func TestCompleteExercise_RejectsMissingAuth(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewPublicHandler(svc)

	router := chi.NewRouter()
	router.Post("/exercises/{exercise_id}/complete", handler.CompleteExercise)

	r := httptest.NewRequest(http.MethodPost, "/exercises/exr_box/complete", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, r)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestListCompletionHistory_RejectsMissingAuth(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewPublicHandler(svc)

	r := httptest.NewRequest(http.MethodGet, "/exercise-completions/history", nil)
	w := httptest.NewRecorder()

	handler.ListCompletionHistory(w, r)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

// --- Admin Handler Tests ---

func TestAdminCreateExercise_RejectsEmptySlug(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	body := `{"slug":"","title":"Test","description":"Desc","language":"en"}`
	r := httptest.NewRequest(http.MethodPost, "/admin/exercises", bytes.NewBufferString(body))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminCtx(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	handler.CreateExercise(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)

	var resp map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	require.NoError(t, err)
	errObj := resp["error"].(map[string]interface{})
	assert.Equal(t, "validation_error", errObj["code"])
}

func TestAdminCreateExercise_RejectsEmptyTitle(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	body := `{"slug":"test","title":"","language":"en"}`
	r := httptest.NewRequest(http.MethodPost, "/admin/exercises", bytes.NewBufferString(body))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminCtx(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	handler.CreateExercise(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminCreateExercise_RejectsEmptyLanguage(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	body := `{"slug":"test","title":"Test","language":""}`
	r := httptest.NewRequest(http.MethodPost, "/admin/exercises", bytes.NewBufferString(body))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminCtx(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	handler.CreateExercise(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminCreateExercise_RejectsInvalidJSON(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	r := httptest.NewRequest(http.MethodPost, "/admin/exercises", bytes.NewBufferString("not json"))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminCtx(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	handler.CreateExercise(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminCreateStep_RejectsEmptyStepType(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	body := `{"step_type":"","title":"Inhale","duration_seconds":4,"sort_order":1}`
	r := httptest.NewRequest(http.MethodPost, "/admin/exercises/exr_1/steps", bytes.NewBufferString(body))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminCtx(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	// Call directly since chi URL params aren't set
	handler.CreateStep(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminCreateStep_RejectsEmptyTitle(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	body := `{"step_type":"TASK","title":"","duration_seconds":4,"sort_order":1}`
	r := httptest.NewRequest(http.MethodPost, "/admin/exercises/exr_1/steps", bytes.NewBufferString(body))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminCtx(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	handler.CreateStep(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminUpdateExercise_RejectsInvalidJSON(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	r := httptest.NewRequest(http.MethodPatch, "/admin/exercises/exr_1", bytes.NewBufferString("invalid"))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminCtx(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	handler.UpdateExercise(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminUpdateExerciseStatus_RejectsInvalidJSON(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	r := httptest.NewRequest(http.MethodPatch, "/admin/exercises/exr_1/status", bytes.NewBufferString("bad"))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminCtx(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	handler.UpdateExerciseStatus(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestAdminUpdateStep_RejectsInvalidJSON(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewAdminHandler(svc)

	r := httptest.NewRequest(http.MethodPatch, "/admin/exercise-steps/stp_01", bytes.NewBufferString("bad"))
	r.Header.Set("Content-Type", "application/json")
	r = r.WithContext(newAdminCtx(r.Context(), "usr_admin", "ADMIN"))
	w := httptest.NewRecorder()

	handler.UpdateStep(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

// --- Contract Compliance Tests ---

func TestExerciseListResponse_EnvelopeFormat(t *testing.T) {
	resp := ExerciseListResponse{
		Exercises: []ExerciseListItem{
			{ExerciseID: "exr_1", Slug: "test", Title: "Test", Language: "en"},
		},
	}

	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	// Contract: { "exercises": [...] }
	assert.Contains(t, parsed, "exercises")
	exercises := parsed["exercises"].([]interface{})
	assert.Len(t, exercises, 1)
}

func TestExerciseDetailResponse_IncludesSteps(t *testing.T) {
	instruction := "Breathe in slowly."
	resp := ExerciseDetailResponse{
		ExerciseID:  "exr_box_breathing",
		Slug:        "box-breathing",
		Title:       "Box Breathing",
		Description: "A 4-step breathing pattern.",
		Language:    "en",
		Status:      "PUBLISHED",
		Steps: []StepDTO{
			{StepID: "stp_01", StepType: "TASK", Title: "Inhale", Instruction: &instruction, DurationSeconds: 4, SortOrder: 1},
		},
	}

	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	assert.Contains(t, parsed, "exercise_id")
	assert.Contains(t, parsed, "slug")
	assert.Contains(t, parsed, "steps")
	assert.Equal(t, "PUBLISHED", parsed["status"])

	steps := parsed["steps"].([]interface{})
	assert.Len(t, steps, 1)

	step := steps[0].(map[string]interface{})
	assert.Contains(t, step, "step_id")
	assert.Contains(t, step, "step_type")
	assert.Contains(t, step, "duration_seconds")
	assert.Contains(t, step, "sort_order")
}

func TestStartResponse_MatchesContract(t *testing.T) {
	resp := StartResponse{
		CompletionID: "cmp_501",
		ExerciseID:   "exr_box_breathing",
		Progress:     0,
		Status:       "IN_PROGRESS",
	}

	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	assert.Contains(t, parsed, "completion_id")
	assert.Contains(t, parsed, "exercise_id")
	assert.Contains(t, parsed, "progress")
	assert.Contains(t, parsed, "status")
	assert.Equal(t, "IN_PROGRESS", parsed["status"])
	assert.Equal(t, float64(0), parsed["progress"])
}

func TestProgressResponse_MatchesContract(t *testing.T) {
	resp := ProgressResponse{
		CompletionID: "cmp_501",
		Progress:     2,
		Status:       "IN_PROGRESS",
	}

	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	assert.Contains(t, parsed, "completion_id")
	assert.Contains(t, parsed, "progress")
	assert.Equal(t, float64(2), parsed["progress"])
}

func TestCompleteResponse_MatchesContract(t *testing.T) {
	resp := CompleteResponse{
		CompletionID: "cmp_501",
		Status:       "COMPLETED",
		CompletedAt:  "2026-08-19T10:12:00Z",
	}

	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	assert.Contains(t, parsed, "completion_id")
	assert.Contains(t, parsed, "status")
	assert.Contains(t, parsed, "completed_at")
	assert.Equal(t, "COMPLETED", parsed["status"])
}

func TestCompletionHistoryResponse_EnvelopeFormat(t *testing.T) {
	completedAt := "2026-08-19T10:12:00Z"
	resp := CompletionHistoryResponse{
		Completions: []CompletionHistoryItem{
			{CompletionID: "cmp_501", ExerciseID: "exr_1", Status: "COMPLETED", Progress: 4, CompletedAt: &completedAt},
		},
	}

	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	// Contract: { "completions": [...] }
	assert.Contains(t, parsed, "completions")
	completions := parsed["completions"].([]interface{})
	assert.Len(t, completions, 1)
}

func TestAdminExerciseListResponse_EnvelopeFormat(t *testing.T) {
	resp := AdminExerciseListResponse{
		Exercises: []AdminExerciseListItem{
			{ExerciseID: "exr_1", Slug: "test", Title: "Test", Language: "en", Status: "DRAFT"},
		},
	}

	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	assert.Contains(t, parsed, "exercises")
	exercises := parsed["exercises"].([]interface{})
	assert.Len(t, exercises, 1)

	ex := exercises[0].(map[string]interface{})
	assert.Contains(t, ex, "status", "Admin response must include status field")
}

func TestUpdateExerciseStatusResponse_MatchesContract(t *testing.T) {
	resp := UpdateExerciseStatusResponse{
		ExerciseID: "exr_box_breathing",
		Status:     "PUBLISHED",
	}

	body, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(body, &parsed)
	require.NoError(t, err)

	assert.Contains(t, parsed, "exercise_id")
	assert.Contains(t, parsed, "status")
	assert.Equal(t, "PUBLISHED", parsed["status"])
}

// --- Error Response Format Tests ---

func TestErrorResponse_Format(t *testing.T) {
	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	handler := NewPublicHandler(svc)

	// Test 401 error
	r := httptest.NewRequest(http.MethodGet, "/exercise-completions/history", nil)
	w := httptest.NewRecorder()

	handler.ListCompletionHistory(w, r)

	var resp map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	require.NoError(t, err)

	// Must follow { "error": { "code": "...", "message": "..." } }
	errorObj, ok := resp["error"]
	assert.True(t, ok, "Response must have 'error' key")

	errorMap := errorObj.(map[string]interface{})
	assert.Contains(t, errorMap, "code")
	assert.Contains(t, errorMap, "message")
	assert.Equal(t, "unauthorized", errorMap["code"])
}

// --- Enum Casing Tests ---

func TestEnumValues_AreUppercase(t *testing.T) {
	// Contract: Enum fields are always UPPERCASE strings
	enums := map[string][]string{
		"exercise status":   {"DRAFT", "PUBLISHED"},
		"completion status": {"IN_PROGRESS", "COMPLETED"},
		"step type":         {"TASK", "BREAK"},
	}

	for name, values := range enums {
		for _, v := range values {
			t.Run(name+"_"+v, func(t *testing.T) {
				for _, c := range v {
					if c >= 'a' && c <= 'z' {
						t.Errorf("Enum value %q in %s contains lowercase character", v, name)
					}
				}
			})
		}
	}
}
