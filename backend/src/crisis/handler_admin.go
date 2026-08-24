package crisis

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/A2SV-ASTU/AfyaMind/backend/src/shared/middleware"
	"github.com/A2SV-ASTU/AfyaMind/backend/src/shared/response"
	"github.com/go-chi/chi/v5"
)

// AdminHandler handles admin crisis endpoints.
type AdminHandler struct {
	service *Service
}

// NewAdminHandler creates a new AdminHandler.
func NewAdminHandler(service *Service) *AdminHandler {
	return &AdminHandler{service: service}
}

// ListResources handles GET /admin/crisis-resources — all statuses.
func (h *AdminHandler) ListResources(w http.ResponseWriter, r *http.Request) {
	resources, err := h.service.ListAllResources(r.Context())
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to fetch crisis resources.")
		return
	}
	dtos := make([]AdminCrisisResourceDTO, 0, len(resources))
	for _, cr := range resources {
		dtos = append(dtos, toAdminResourceDTO(cr))
	}
	response.JSON(w, http.StatusOK, AdminCrisisResourceListResponse{CrisisResources: dtos})
}

// GetResource handles GET /admin/crisis-resources/:id.
func (h *AdminHandler) GetResource(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid resource ID.")
		return
	}
	resource, err := h.service.GetResourceByID(r.Context(), id)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Crisis resource not found.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to fetch crisis resource.")
		return
	}
	response.JSON(w, http.StatusOK, toAdminResourceDTO(*resource))
}

// CreateResource handles POST /admin/crisis-resources — status defaults to DRAFT.
func (h *AdminHandler) CreateResource(w http.ResponseWriter, r *http.Request) {
	actorID := middleware.GetUserID(r.Context())
	var req CreateCrisisResourceRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid request body.")
		return
	}
	if req.Label == "" || req.Phone == "" {
		response.Error(w, http.StatusBadRequest, "validation_error", "Label and phone are required.")
		return
	}
	resource, err := h.service.CreateResource(r.Context(), actorID, req.Label, req.Phone, req.SortOrder)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to create crisis resource.")
		return
	}
	response.JSON(w, http.StatusCreated, CreateCrisisResourceResponse{
		ID: resource.ID, Label: resource.Label, Status: resource.Status,
	})
}

// UpdateResource handles PATCH /admin/crisis-resources/:id.
func (h *AdminHandler) UpdateResource(w http.ResponseWriter, r *http.Request) {
	actorID := middleware.GetUserID(r.Context())
	id, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid resource ID.")
		return
	}
	var req UpdateCrisisResourceRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid request body.")
		return
	}
	resource, err := h.service.UpdateResource(r.Context(), actorID, id, req.Label, req.Phone, req.SortOrder)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Crisis resource not found.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to update crisis resource.")
		return
	}
	response.JSON(w, http.StatusOK, toAdminResourceDTO(*resource))
}

// UpdateResourceStatus handles PATCH /admin/crisis-resources/:id/status.
func (h *AdminHandler) UpdateResourceStatus(w http.ResponseWriter, r *http.Request) {
	actorID := middleware.GetUserID(r.Context())
	id, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid resource ID.")
		return
	}
	var req UpdateStatusRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid request body.")
		return
	}
	resource, err := h.service.UpdateResourceStatus(r.Context(), actorID, id, req.Status)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Crisis resource not found.")
			return
		}
		if strings.Contains(err.Error(), "validation_error") {
			response.Error(w, http.StatusBadRequest, "validation_error", "Status must be DRAFT or PUBLISHED.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to update status.")
		return
	}
	response.JSON(w, http.StatusOK, AdminCrisisResourceDTO{
		ID: resource.ID, Label: resource.Label, Status: resource.Status,
	})
}

// DeleteResource handles DELETE /admin/crisis-resources/:id.
func (h *AdminHandler) DeleteResource(w http.ResponseWriter, r *http.Request) {
	actorID := middleware.GetUserID(r.Context())
	id, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid resource ID.")
		return
	}
	if err := h.service.DeleteResource(r.Context(), actorID, id); err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Crisis resource not found.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to delete crisis resource.")
		return
	}
	response.NoContent(w)
}

// ListEvents handles GET /admin/crisis-events with optional ?source= and ?user_id= filters.
func (h *AdminHandler) ListEvents(w http.ResponseWriter, r *http.Request) {
	source := r.URL.Query().Get("source")
	userID := r.URL.Query().Get("user_id")
	events, err := h.service.ListEvents(r.Context(), source, userID)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to fetch crisis events.")
		return
	}
	dtos := make([]AdminCrisisEventDTO, 0, len(events))
	for _, e := range events {
		dtos = append(dtos, AdminCrisisEventDTO{
			ID: e.ID, UserID: e.UserID, Source: e.Source,
			CreatedAt: e.CreatedAt.Format("2006-01-02T15:04:05Z"),
		})
	}
	response.JSON(w, http.StatusOK, AdminCrisisEventListResponse{CrisisEvents: dtos})
}

// GetEvent handles GET /admin/crisis-events/:id.
func (h *AdminHandler) GetEvent(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	event, err := h.service.GetEventByID(r.Context(), id)
	if err != nil {
		if strings.Contains(err.Error(), "not_found") {
			response.Error(w, http.StatusNotFound, "not_found", "Crisis event not found.")
			return
		}
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to fetch crisis event.")
		return
	}
	response.JSON(w, http.StatusOK, AdminCrisisEventDTO{
		ID: event.ID, UserID: event.UserID, Source: event.Source,
		CreatedAt: event.CreatedAt.Format("2006-01-02T15:04:05Z"),
	})
}

func toAdminResourceDTO(cr CrisisResource) AdminCrisisResourceDTO {
	return AdminCrisisResourceDTO{
		ID: cr.ID, Label: cr.Label, Phone: cr.Phone, SortOrder: cr.SortOrder,
		Status: cr.Status, CreatedAt: cr.CreatedAt.Format("2006-01-02T15:04:05Z"),
		UpdatedAt: cr.UpdatedAt.Format("2006-01-02T15:04:05Z"),
	}
}

// Ensure fmt is used (for potential future error formatting).
var _ = fmt.Sprintf
