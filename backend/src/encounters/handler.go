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

// CreateEncounter godoc
//
//	@Summary		Open a new clinical encounter
//	@Description	Opens a clinical encounter session for a patient. Enforces doctor access.
//	@Tags			Encounters
//	@Produce		json
//	@Security		BearerAuth
//	@Param			patientId	path		string								true	"Patient UUID"
//	@Success		201			{object}	encounters.EncounterResponse		"Encounter created successfully"
//	@Failure		400			{object}	response.ErrorEnvelope				"Invalid Patient ID"
//	@Failure		401			{object}	response.ErrorEnvelope				"Not authenticated"
//	@Router			/patients/{patientId}/encounters [post]
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

// ListEncounters godoc
//
//	@Summary		List encounters for a patient
//	@Description	Retrieves all encounters recorded for a specific patient. Supports pagination.
//	@Tags			Encounters
//	@Produce		json
//	@Security		BearerAuth
//	@Param			patientId	path		string	true	"Patient ID"
//	@Param			page		query		int		false	"Page number (default: 1)"
//	@Param			limit		query		int		false	"Items per page (default: 20)"
//	@Success		200			{object}	object{encounters=[]encounters.Encounter,page=int,limit=int,total=int}	"List of encounters"
//	@Failure		400			{object}	response.ErrorEnvelope	"Invalid Patient ID"
//	@Failure		401			{object}	response.ErrorEnvelope	"Not authenticated"
//	@Router			/patients/{patientId}/encounters [get]
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

// GetEncounter godoc
//
//	@Summary		Get details of an encounter
//	@Description	Returns full details of an encounter including vitals, lab results, diagnoses and prescriptions.
//	@Tags			Encounters
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id	path		string										true	"Encounter ID"
//	@Success		200	{object}	encounters.AggregatedEncounterResponse		"Encounter details"
//	@Failure		400	{object}	response.ErrorEnvelope						"Invalid Encounter ID"
//	@Failure		401	{object}	response.ErrorEnvelope						"Not authenticated"
//	@Router			/encounters/{id} [get]
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

// CloseEncounter godoc
//
//	@Summary		Close an open encounter
//	@Description	Marks a clinical encounter session as closed/finalized. Doctor only.
//	@Tags			Encounters
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id	path		string								true	"Encounter ID"
//	@Success		200	{object}	encounters.EncounterResponse		"Encounter marked closed"
//	@Failure		400	{object}	response.ErrorEnvelope				"Invalid Encounter ID"
//	@Failure		401	{object}	response.ErrorEnvelope				"Not authenticated"
//	@Router			/encounters/{id}/close [patch]
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

// GetMedicalHistory godoc
//
//	@Summary		Get patient medical history summary
//	@Description	Returns a summary of the patient's medical history from the vantage point of this encounter.
//	@Tags			Encounters
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id	path		string										true	"Encounter ID"
//	@Success		200	{object}	[]encounters.MedicalHistoryResponse			"Medical history summary list"
//	@Failure		400	{object}	response.ErrorEnvelope						"Invalid Encounter ID"
//	@Failure		401	{object}	response.ErrorEnvelope						"Not authenticated"
//	@Router			/encounters/{id}/medical-history [get]
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
