package encounters

import (
	"net/http"
	"strconv"

	"afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/middleware"
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

func (h *Handler) CreateEncounter(c *gin.Context) {
	patientIDStr := c.Param("patientId")
	patientID, err := uuid.Parse(patientIDStr)
	if err != nil {
		response.SendError(c, errors.ErrValidationError("Invalid patient ID"))
		return
	}

	doctorID, ok := middleware.GetUserID(c)
	if !ok {
		response.SendError(c, errors.ErrUnauthenticated())
		return
	}

	res, appErr := h.service.OpenEncounter(c.Request.Context(), doctorID, patientID)
	if appErr != nil {
		response.SendError(c, appErr)
		return
	}

	c.JSON(http.StatusCreated, res)
}

func (h *Handler) ListEncounters(c *gin.Context) {
	patientIDStr := c.Param("patientId")
	patientID, err := uuid.Parse(patientIDStr)
	if err != nil {
		response.SendError(c, errors.ErrValidationError("Invalid patient ID"))
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	list, total, appErr := h.service.ListPatientEncounters(c.Request.Context(), patientID, page, limit)
	if appErr != nil {
		response.SendError(c, appErr)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"encounters": list,
		"page":       page,
		"limit":      limit,
		"total":      total,
	})
}

func (h *Handler) GetEncounter(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		response.SendError(c, errors.ErrValidationError("Invalid encounter ID"))
		return
	}

	agg, appErr := h.service.GetEncounterByID(c.Request.Context(), id)
	if appErr != nil {
		response.SendError(c, appErr)
		return
	}

	c.JSON(http.StatusOK, agg)
}

func (h *Handler) CloseEncounter(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		response.SendError(c, errors.ErrValidationError("Invalid encounter ID"))
		return
	}

	res, appErr := h.service.CloseEncounter(c.Request.Context(), id)
	if appErr != nil {
		response.SendError(c, appErr)
		return
	}

	c.JSON(http.StatusOK, res)
}

func (h *Handler) GetMedicalHistory(c *gin.Context) {
	encounterIDStr := c.Param("encounterId")
	if encounterIDStr == "" {
		encounterIDStr = c.Param("id")
	}
	encounterID, err := uuid.Parse(encounterIDStr)
	if err != nil {
		response.SendError(c, errors.ErrValidationError("Invalid encounter ID"))
		return
	}

	medHist, appErr := h.service.GetMedicalHistory(c.Request.Context(), encounterID)
	if appErr != nil {
		response.SendError(c, appErr)
		return
	}

	c.JSON(http.StatusOK, medHist)
}
