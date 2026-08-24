package exercises

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/A2SV-ASTU/AfyaMind/backend/src/shared/middleware"
	"github.com/A2SV-ASTU/AfyaMind/backend/src/shared/response"
	"github.com/go-chi/chi/v5"
)

// PublicHandler handles public exercise endpoints.
type PublicHandler struct {
	service *Service
}

// NewPublicHandler creates a new PublicHandler.
func NewPublicHandler(service *Service) *PublicHandler {
	return &PublicHandler{service: service}
}

// ListExercises handles GET /exercises?language=en — Public.
func (h *PublicHandler) ListExercises(w http.ResponseWriter, r *http.Request) {
	language := r.URL.Query().Get("language")
	exercises, err := h.service.ListPublished(r.Context(), language)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to fetch exercises.")
		return
	}
	items := make([]ExerciseListItem, 0, len(exercises))
	for _, e := range exercises {
		items = append(items, ExerciseListItem{
			ExerciseID: e.ID, Slug: e.Slug, Title: e.Title, Language: e.Language,
		})
	}
	response.JSON(w, http.StatusOK, ExerciseListResponse{Exercises: items})
}

// GetExerciseBySlug handles GET /exercises/:slug — Public.
func (h *PublicHandler) GetExerciseBySlug(w http.ResponseWriter, r *http.Request) {
	slug := chi.URLParam(r, "slug")
	ex, steps, err := h.service.GetBySlug(r.Context(), slug)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Exercise not found.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to fetch exercise.")
		return
	}
	stepDTOs := make([]StepDTO, 0, len(steps))
	for _, s := range steps {
		stepDTOs = append(stepDTOs, StepDTO{
			StepID: s.ID, StepType: s.StepType, Title: s.Title,
			Instruction: s.Instruction, DurationSeconds: s.DurationSeconds, SortOrder: s.SortOrder,
		})
	}
	response.JSON(w, http.StatusOK, ExerciseDetailResponse{
		ExerciseID: ex.ID, Slug: ex.Slug, Title: ex.Title,
		Description: ex.Description, Language: ex.Language, Status: ex.Status, Steps: stepDTOs,
	})
}

// StartExercise handles POST /exercises/:exercise_id/start — Auth required.
func (h *PublicHandler) StartExercise(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Error(w, http.StatusUnauthorized, "unauthorized", "Missing or expired session cookie.")
		return
	}
	exerciseID := chi.URLParam(r, "exercise_id")
	comp, err := h.service.StartExercise(r.Context(), userID, exerciseID)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Exercise not found or not published.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to start exercise.")
		return
	}
	response.JSON(w, http.StatusCreated, StartResponse{
		CompletionID: comp.ID, ExerciseID: comp.ExerciseID, Progress: comp.Progress, Status: comp.Status,
	})
}

// UpdateProgress handles PATCH /exercises/:exercise_id/progress — Auth required.
func (h *PublicHandler) UpdateProgress(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Error(w, http.StatusUnauthorized, "unauthorized", "Missing or expired session cookie.")
		return
	}
	exerciseID := chi.URLParam(r, "exercise_id")
	var req ProgressRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid request body.")
		return
	}
	comp, err := h.service.UpdateProgress(r.Context(), userID, exerciseID, req.Progress)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "No in-progress completion found.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to update progress.")
		return
	}
	response.JSON(w, http.StatusOK, ProgressResponse{
		CompletionID: comp.ID, Progress: comp.Progress, Status: comp.Status,
	})
}

// CompleteExercise handles POST /exercises/:exercise_id/complete — Auth required.
func (h *PublicHandler) CompleteExercise(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Error(w, http.StatusUnauthorized, "unauthorized", "Missing or expired session cookie.")
		return
	}
	exerciseID := chi.URLParam(r, "exercise_id")
	comp, err := h.service.CompleteExercise(r.Context(), userID, exerciseID)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "No in-progress completion found.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to complete exercise.")
		return
	}
	completedAt := ""
	if comp.CompletedAt != nil {
		completedAt = comp.CompletedAt.Format("2006-01-02T15:04:05Z")
	}
	response.JSON(w, http.StatusOK, CompleteResponse{
		CompletionID: comp.ID, Status: comp.Status, CompletedAt: completedAt,
	})
}

// ListCompletionHistory handles GET /exercise-completions/history — Auth required.
func (h *PublicHandler) ListCompletionHistory(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Error(w, http.StatusUnauthorized, "unauthorized", "Missing or expired session cookie.")
		return
	}
	completions, err := h.service.ListCompletionHistory(r.Context(), userID)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to fetch completion history.")
		return
	}
	items := make([]CompletionHistoryItem, 0, len(completions))
	for _, c := range completions {
		item := CompletionHistoryItem{
			CompletionID: c.ID, ExerciseID: c.ExerciseID, Status: c.Status, Progress: c.Progress,
		}
		if c.CompletedAt != nil {
			t := c.CompletedAt.Format("2006-01-02T15:04:05Z")
			item.CompletedAt = &t
		}
		items = append(items, item)
	}
	response.JSON(w, http.StatusOK, CompletionHistoryResponse{Completions: items})
}
