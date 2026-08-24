package exercises

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/A2SV-ASTU/AfyaMind/backend/src/shared/middleware"
	"github.com/A2SV-ASTU/AfyaMind/backend/src/shared/response"
	"github.com/go-chi/chi/v5"
)

// AdminHandler handles admin exercise endpoints.
type AdminHandler struct {
	service *Service
}

// NewAdminHandler creates a new AdminHandler.
func NewAdminHandler(service *Service) *AdminHandler {
	return &AdminHandler{service: service}
}

// ListExercises handles GET /admin/exercises — all statuses.
func (h *AdminHandler) ListExercises(w http.ResponseWriter, r *http.Request) {
	exercises, err := h.service.ListAll(r.Context())
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to fetch exercises.")
		return
	}
	items := make([]AdminExerciseListItem, 0, len(exercises))
	for _, e := range exercises {
		items = append(items, AdminExerciseListItem{
			ExerciseID: e.ID, Slug: e.Slug, Title: e.Title, Language: e.Language, Status: e.Status,
		})
	}
	response.JSON(w, http.StatusOK, AdminExerciseListResponse{Exercises: items})
}

// GetExercise handles GET /admin/exercises/:id — single, any status, with steps.
func (h *AdminHandler) GetExercise(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	ex, steps, err := h.service.GetByIDAdmin(r.Context(), id)
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

// CreateExercise handles POST /admin/exercises — status defaults to DRAFT.
func (h *AdminHandler) CreateExercise(w http.ResponseWriter, r *http.Request) {
	actorID := middleware.GetUserID(r.Context())
	var req CreateExerciseRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid request body.")
		return
	}
	if req.Slug == "" || req.Title == "" || req.Language == "" {
		response.Error(w, http.StatusBadRequest, "validation_error", "Slug, title, and language are required.")
		return
	}
	ex, err := h.service.CreateExercise(r.Context(), actorID, req.Slug, req.Title, req.Description, req.Language)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to create exercise.")
		return
	}
	response.JSON(w, http.StatusCreated, ExerciseDetailResponse{
		ExerciseID: ex.ID, Slug: ex.Slug, Title: ex.Title,
		Description: ex.Description, Language: ex.Language, Status: ex.Status, Steps: []StepDTO{},
	})
}

// UpdateExercise handles PATCH /admin/exercises/:id.
func (h *AdminHandler) UpdateExercise(w http.ResponseWriter, r *http.Request) {
	actorID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")
	var req UpdateExerciseRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid request body.")
		return
	}
	ex, err := h.service.UpdateExercise(r.Context(), actorID, id, req.Slug, req.Title, req.Description, req.Language)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Exercise not found.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to update exercise.")
		return
	}
	response.JSON(w, http.StatusOK, AdminExerciseListItem{
		ExerciseID: ex.ID, Slug: ex.Slug, Title: ex.Title, Language: ex.Language, Status: ex.Status,
	})
}

// UpdateExerciseStatus handles PATCH /admin/exercises/:id/status — DRAFT ↔ PUBLISHED.
func (h *AdminHandler) UpdateExerciseStatus(w http.ResponseWriter, r *http.Request) {
	actorID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")
	var req UpdateExerciseStatusRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid request body.")
		return
	}
	ex, err := h.service.UpdateExerciseStatus(r.Context(), actorID, id, req.Status)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Exercise not found.")
			return
		}
		if strings.Contains(err.Error(), "validation_error") {
			response.Error(w, http.StatusBadRequest, "validation_error", "Status must be DRAFT or PUBLISHED.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to update status.")
		return
	}
	response.JSON(w, http.StatusOK, UpdateExerciseStatusResponse{ExerciseID: ex.ID, Status: ex.Status})
}

// CreateStep handles POST /admin/exercises/:id/steps.
func (h *AdminHandler) CreateStep(w http.ResponseWriter, r *http.Request) {
	actorID := middleware.GetUserID(r.Context())
	exerciseID := chi.URLParam(r, "id")
	var req CreateStepRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid request body.")
		return
	}
	if req.StepType == "" || req.Title == "" {
		response.Error(w, http.StatusBadRequest, "validation_error", "Step type and title are required.")
		return
	}
	step, err := h.service.CreateStep(r.Context(), actorID, exerciseID, req.StepType, req.Title, req.Instruction, req.DurationSeconds, req.SortOrder)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Exercise not found.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to create step.")
		return
	}
	response.JSON(w, http.StatusCreated, StepDTO{
		StepID: step.ID, StepType: step.StepType, Title: step.Title,
		Instruction: step.Instruction, DurationSeconds: step.DurationSeconds, SortOrder: step.SortOrder,
	})
}

// UpdateStep handles PATCH /admin/exercise-steps/:id.
func (h *AdminHandler) UpdateStep(w http.ResponseWriter, r *http.Request) {
	actorID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")
	var req UpdateStepRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid request body.")
		return
	}
	step, err := h.service.UpdateStep(r.Context(), actorID, id, req.StepType, req.Title, req.Instruction, req.DurationSeconds, req.SortOrder)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Exercise step not found.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to update step.")
		return
	}
	response.JSON(w, http.StatusOK, StepDTO{
		StepID: step.ID, StepType: step.StepType, Title: step.Title,
		Instruction: step.Instruction, DurationSeconds: step.DurationSeconds, SortOrder: step.SortOrder,
	})
}

// DeleteStep handles DELETE /admin/exercise-steps/:id.
func (h *AdminHandler) DeleteStep(w http.ResponseWriter, r *http.Request) {
	actorID := middleware.GetUserID(r.Context())
	id := chi.URLParam(r, "id")
	if err := h.service.DeleteStep(r.Context(), actorID, id); err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Exercise step not found.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to delete step.")
		return
	}
	response.NoContent(w)
}
