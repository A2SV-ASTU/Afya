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

func (h *Handler) CreateDiagnosis(c *gin.Context) {
	encounterIDStr := c.Param("encounterId")
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

func (h *Handler) GetDiagnoses(c *gin.Context) {
	encounterIDStr := c.Param("encounterId")
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
