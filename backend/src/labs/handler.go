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

func (h *Handler) CreateLabResult(c *gin.Context) {
	encounterIDStr := c.Param("encounterId")
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

func (h *Handler) GetLabResults(c *gin.Context) {
	encounterIDStr := c.Param("encounterId")
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
