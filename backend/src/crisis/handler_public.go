package crisis

import (
	"encoding/json"
	"net/http"

	"github.com/A2SV-ASTU/AfyaMind/backend/src/shared/middleware"
	"github.com/A2SV-ASTU/AfyaMind/backend/src/shared/response"
)

// PublicHandler handles public crisis endpoints.
type PublicHandler struct {
	service *Service
}

// NewPublicHandler creates a new PublicHandler.
func NewPublicHandler(service *Service) *PublicHandler {
	return &PublicHandler{service: service}
}

// ListCrisisResources handles GET /crisis-resources — Public.
func (h *PublicHandler) ListCrisisResources(w http.ResponseWriter, r *http.Request) {
	resources, err := h.service.ListPublishedResources(r.Context())
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to fetch crisis resources.")
		return
	}

	dtos := make([]CrisisResourcePublicDTO, 0, len(resources))
	for _, cr := range resources {
		dtos = append(dtos, CrisisResourcePublicDTO{ID: cr.ID, Label: cr.Label, Phone: cr.Phone})
	}
	response.JSON(w, http.StatusOK, CrisisResourceListResponse{CrisisResources: dtos})
}

// CreateCrisisEvent handles POST /crisis-events — Auth required.
// Source must be "CRISIS_BUTTON".
func (h *PublicHandler) CreateCrisisEvent(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Error(w, http.StatusUnauthorized, "unauthorized", "Missing or expired session cookie.")
		return
	}

	var req CreateCrisisEventRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "validation_error", "Invalid request body.")
		return
	}

	if req.Source != SourceCrisisButton {
		response.Error(w, http.StatusBadRequest, "validation_error", "Source must be \"CRISIS_BUTTON\".")
		return
	}

	event, err := h.service.CreateEvent(r.Context(), userID, req.Source)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "internal_error", "Failed to create crisis event.")
		return
	}

	resources, _ := h.service.ListPublishedResources(r.Context())
	resourceDTOs := make([]CrisisResourcePublicDTO, 0, len(resources))
	for _, cr := range resources {
		resourceDTOs = append(resourceDTOs, CrisisResourcePublicDTO{ID: cr.ID, Label: cr.Label, Phone: cr.Phone})
	}

	response.JSON(w, http.StatusCreated, CrisisEventResponse{
		CrisisEventID:   event.ID,
		Source:          event.Source,
		CreatedAt:       event.CreatedAt.Format("2006-01-02T15:04:05Z"),
		CrisisResources: resourceDTOs,
	})
}
