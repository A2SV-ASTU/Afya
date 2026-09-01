package labs

import (
	"net/http"

	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{service: service}
}

// CreateLabResult godoc
//
//	@Summary		Add a lab result
//	@Description	Adds a new lab result to a specific encounter.
//	@Tags			Labs
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string						true	"Encounter ID"
//	@Param			body	body		labs.CreateLabResultRequest	true	"Lab Result details"
//	@Success		201		{object}	labs.LabResult				"Lab Result created successfully"
//	@Failure		400		{object}	response.ErrorEnvelope		"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope		"Not authenticated"
//	@Failure		403		{object}	response.ErrorEnvelope		"Forbidden"
//	@Failure		404		{object}	response.ErrorEnvelope		"Encounter not found"
//	@Failure		409		{object}	response.ErrorEnvelope		"Encounter is closed"
//	@Router			/encounters/{id}/labs [post]
func (h *Handler) CreateLabResult(c *gin.Context) {
	encounterIDStr := c.Param("id")
	if encounterIDStr == "" {
		encounterIDStr = c.Param("encounterId")
	}
	encounterID, err := uuid.Parse(encounterIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid encounter ID format"))
		return
	}

	var req CreateLabResultRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError(err.Error()))
		return
	}

	labResult, appErr := h.service.CreateLabResult(c.Request.Context(), encounterID, req)
	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	c.JSON(http.StatusCreated, gin.H{"lab_result": labResult})
}

// GetLabResults godoc
//
//	@Summary		Get lab results
//	@Description	Retrieves all lab results for a specific encounter.
//	@Tags			Labs
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string						true	"Encounter ID"
//	@Success		200		{array}		labs.LabResult				"List of lab results"
//	@Failure		400		{object}	response.ErrorEnvelope		"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope		"Not authenticated"
//	@Failure		403		{object}	response.ErrorEnvelope		"Forbidden"
//	@Failure		404		{object}	response.ErrorEnvelope		"Encounter not found"
//	@Router			/encounters/{id}/labs [get]
func (h *Handler) GetLabResults(c *gin.Context) {
	encounterIDStr := c.Param("id")
	if encounterIDStr == "" {
		encounterIDStr = c.Param("encounterId")
	}
	encounterID, err := uuid.Parse(encounterIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid encounter ID format"))
		return
	}

	results, appErr := h.service.GetEncounterLabResults(c.Request.Context(), encounterID)
	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	c.JSON(http.StatusOK, results)
}
