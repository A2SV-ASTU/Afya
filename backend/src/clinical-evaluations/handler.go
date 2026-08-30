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
