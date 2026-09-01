package clinicalevaluations

import (
	"net/http"

	"afyamind-backend/src/shared/errors"
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

// CreateClinicalEvaluation godoc
//
//	@Summary		Create a clinical evaluation for an encounter
//	@Description	Records symptoms, past history, allergies and physical examination details. Enforces doctor access.
//	@Tags			ClinicalEvaluations
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string									true	"Encounter ID"
//	@Param			body	body		clinicalevaluations.CreateClinicalEvaluationRequest	true	"Evaluation details"
//	@Success		201		{object}	clinicalevaluations.ClinicalEvaluationResponse		"Clinical evaluation created"
//	@Failure		400		{object}	response.ErrorEnvelope								"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope								"Not authenticated"
//	@Router			/encounters/{id}/clinical-evaluation [post]
func (h *Handler) CreateClinicalEvaluation(c *gin.Context) {
	encounterIDStr := c.Param("encounterId")
	if encounterIDStr == "" {
		encounterIDStr = c.Param("id")
	}
	encounterID, err := uuid.Parse(encounterIDStr)
	if err != nil {
		response.SendError(c, errors.ErrValidationError("Invalid encounter ID"))
		return
	}

	var req CreateClinicalEvaluationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, errors.ErrValidationError("Chief complaint and history of present illness are required"))
		return
	}

	res, appErr := h.service.CreateEvaluation(c.Request.Context(), encounterID, req)
	if appErr != nil {
		response.SendError(c, appErr)
		return
	}

	c.JSON(http.StatusCreated, res)
}

// GetClinicalEvaluation godoc
//
//	@Summary		Get clinical evaluation for an encounter
//	@Description	Retrieves the clinical evaluation details associated with a clinical encounter.
//	@Tags			ClinicalEvaluations
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id	path		string											true	"Encounter ID"
//	@Success		200	{object}	clinicalevaluations.ClinicalEvaluationResponse	"Clinical evaluation details"
//	@Failure		400	{object}	response.ErrorEnvelope							"Validation/ID error"
//	@Failure		401	{object}	response.ErrorEnvelope							"Not authenticated"
//	@Router			/encounters/{id}/clinical-evaluation [get]
func (h *Handler) GetClinicalEvaluation(c *gin.Context) {
	encounterIDStr := c.Param("encounterId")
	if encounterIDStr == "" {
		encounterIDStr = c.Param("id")
	}
	encounterID, err := uuid.Parse(encounterIDStr)
	if err != nil {
		response.SendError(c, errors.ErrValidationError("Invalid encounter ID"))
		return
	}

	res, appErr := h.service.GetEvaluation(c.Request.Context(), encounterID)
	if appErr != nil {
		response.SendError(c, appErr)
		return
	}

	c.JSON(http.StatusOK, res)
}
