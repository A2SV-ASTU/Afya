package diagnoses

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

// CreateDiagnosis godoc
//
//	@Summary		Add a diagnosis
//	@Description	Adds a new diagnosis to a specific encounter.
//	@Tags			Diagnoses
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string								true	"Encounter ID"
//	@Param			body	body		diagnoses.CreateDiagnosisRequest	true	"Diagnosis details"
//	@Success		201		{object}	diagnoses.Diagnosis					"Diagnosis created successfully"
//	@Failure		400		{object}	response.ErrorEnvelope				"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope				"Not authenticated"
//	@Failure		403		{object}	response.ErrorEnvelope				"Forbidden"
//	@Failure		404		{object}	response.ErrorEnvelope				"Encounter not found"
//	@Failure		409		{object}	response.ErrorEnvelope				"Encounter is closed"
//	@Router			/encounters/{id}/diagnoses [post]
func (h *Handler) CreateDiagnosis(c *gin.Context) {
	encounterIDStr := c.Param("id")
	if encounterIDStr == "" {
		encounterIDStr = c.Param("encounterId")
	}
	encounterID, err := uuid.Parse(encounterIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid encounter ID format"))
		return
	}

	var req CreateDiagnosisRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError(err.Error()))
		return
	}

	diagnosis, appErr := h.service.CreateDiagnosis(c.Request.Context(), encounterID, req)
	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	c.JSON(http.StatusCreated, gin.H{"diagnosis": diagnosis})
}

// GetDiagnoses godoc
//
//	@Summary		Get diagnoses
//	@Description	Retrieves all diagnoses for a specific encounter.
//	@Tags			Diagnoses
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string						true	"Encounter ID"
//	@Success		200		{array}		diagnoses.Diagnosis			"List of diagnoses"
//	@Failure		400		{object}	response.ErrorEnvelope		"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope		"Not authenticated"
//	@Failure		403		{object}	response.ErrorEnvelope		"Forbidden"
//	@Failure		404		{object}	response.ErrorEnvelope		"Encounter not found"
//	@Router			/encounters/{id}/diagnoses [get]
func (h *Handler) GetDiagnoses(c *gin.Context) {
	encounterIDStr := c.Param("id")
	if encounterIDStr == "" {
		encounterIDStr = c.Param("encounterId")
	}
	encounterID, err := uuid.Parse(encounterIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid encounter ID format"))
		return
	}

	diagnoses, appErr := h.service.GetEncounterDiagnoses(c.Request.Context(), encounterID)
	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	c.JSON(http.StatusOK, diagnoses)
}
