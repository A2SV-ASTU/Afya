package vitals

import (
	"net/http"

	"afyamind-backend/src/shared/auth"
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct{ svc Service }

func NewHandler(svc Service) *Handler { return &Handler{svc: svc} }

// RecordEncounterVitals godoc
//
//	@Summary		Record vitals for an encounter
//	@Description	Records vital signs recorded during a clinical encounter. Enforces doctor access.
//	@Tags			Vitals
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string									true	"Encounter ID"
//	@Param			body	body		vitals.RecordEncounterVitalsRequest		true	"Vital signs details"
//	@Success		201		{object}	vitals.VitalSign						"Vital signs recorded successfully"
//	@Failure		400		{object}	response.ErrorEnvelope					"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope					"Not authenticated"
//	@Failure		403		{object}	response.ErrorEnvelope					"Forbidden role / Access denied"
//	@Router			/encounters/{id}/vitals [post]
func (h *Handler) RecordEncounterVitals(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}
	encounterIDStr := c.Param("encounterId")
	if encounterIDStr == "" {
		encounterIDStr = c.Param("id")
	}
	encounterID, err := uuid.Parse(encounterIDStr)
	if err != nil {
		response.SendError(c, appErrors.ErrValidationError("invalid encounter id"))
		return
	}
	var req RecordEncounterVitalsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, appErrors.ErrValidationError(err.Error()))
		return
	}
	v, err := h.svc.RecordEncounterVitals(c.Request.Context(), user, encounterID, req)
	if err != nil {
		response.SendError(c, err)
		return
	}
	response.JSON(c, http.StatusCreated, gin.H{"vital_sign": v})
}

// LogPatientVital godoc
//
//	@Summary		Log patient vital signs self-entry
//	@Description	Logs patient vital signs as a self-entry. Enforces patient access.
//	@Tags			Vitals
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			body	body		vitals.LogPatientVitalRequest		true	"Vital signs details"
//	@Success		201		{object}	vitals.VitalSign					"Vital signs logged successfully"
//	@Failure		400		{object}	response.ErrorEnvelope				"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope				"Not authenticated"
//	@Router			/vitals [post]
func (h *Handler) LogPatientVital(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}
	var req LogPatientVitalRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, appErrors.ErrValidationError(err.Error()))
		return
	}
	v, err := h.svc.LogPatientVital(c.Request.Context(), user, req)
	if err != nil {
		response.SendError(c, err)
		return
	}
	response.JSON(c, http.StatusCreated, gin.H{"vital_sign": v})
}

// ListPatientVitals godoc
//
//	@Summary		List patient vitals
//	@Description	Lists vital signs history for a patient. Patient or Doctor with active access grant only.
//	@Tags			Vitals
//	@Produce		json
//	@Security		BearerAuth
//	@Param			patientId	path		string						true	"Patient ID"
//	@Param			from		query		string						false	"Filter start time (RFC3339 format)"
//	@Param			to			query		string						false	"Filter end time (RFC3339 format)"
//	@Param			source		query		string						false	"Filter by source (clinic or patient)"
//	@Success		200			{array}		vitals.VitalSign			"List of vital signs"
//	@Failure		400			{object}	response.ErrorEnvelope		"Validation error"
//	@Failure		401			{object}	response.ErrorEnvelope		"Not authenticated"
//	@Failure		403			{object}	response.ErrorEnvelope		"Forbidden / No access grant"
//	@Router			/patients/{patientId}/vitals [get]
func (h *Handler) ListPatientVitals(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}
	patientID, err := uuid.Parse(c.Param("patientId"))
	if err != nil {
		response.SendError(c, appErrors.ErrValidationError("invalid patient id"))
		return
	}
	var q ListVitalsQuery
	if err := c.ShouldBindQuery(&q); err != nil {
		response.SendError(c, appErrors.ErrValidationError(err.Error()))
		return
	}
	vitals, err := h.svc.ListPatientVitals(c.Request.Context(), user, patientID, q)
	if err != nil {
		response.SendError(c, err)
		return
	}
	response.List(c, http.StatusOK, "vital_signs", vitals)
}

// SyncPatientVitals godoc
//
//	@Summary		Sync offline patient vitals
//	@Description	Syncs offline logged patient vitals with deduplication support. Patient only.
//	@Tags			Vitals
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			body	body		vitals.SyncVitalsRequest		true	"Offline vitals entries"
//	@Success		200		{object}	vitals.SyncVitalsResponse		"Sync results with status"
//	@Failure		400		{object}	response.ErrorEnvelope			"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope			"Not authenticated"
//	@Router			/patients/me/vitals/sync [post]
func (h *Handler) SyncPatientVitals(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}
	var req SyncVitalsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, appErrors.ErrValidationError(err.Error()))
		return
	}
	result, err := h.svc.SyncPatientVitals(c.Request.Context(), user, req)
	if err != nil {
		response.SendError(c, err)
		return
	}
	response.JSON(c, http.StatusOK, result)
}

// GetDoctorSyncVitals godoc
//
//	@Summary		Get clinic-recorded vitals for sync
//	@Description	Fetches clinic-recorded vitals since a specific timestamp to sync back to patient's app. Patient only.
//	@Tags			Vitals
//	@Produce		json
//	@Security		BearerAuth
//	@Param			since	query		string						false	"Fetch records since this timestamp (RFC3339 format)"
//	@Success		200		{array}		vitals.VitalSign			"List of clinical vital signs to sync"
//	@Failure		400		{object}	response.ErrorEnvelope		"Validation / parsing error"
//	@Failure		401		{object}	response.ErrorEnvelope		"Not authenticated"
//	@Router			/patients/me/vitals/doctor-sync [get]
func (h *Handler) GetDoctorSyncVitals(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}
	var q DoctorSyncQuery
	if err := c.ShouldBindQuery(&q); err != nil {
		response.SendError(c, appErrors.ErrValidationError(err.Error()))
		return
	}
	vitals, err := h.svc.GetDoctorSyncVitals(c.Request.Context(), user, q.Since)
	if err != nil {
		response.SendError(c, err)
		return
	}
	response.List(c, http.StatusOK, "vital_signs", vitals)
}

// AckDoctorVitals godoc
//
//	@Summary		Acknowledge synced clinic vitals
//	@Description	Acknowledges that clinic-recorded vitals have been successfully synced to the patient's device. Patient only.
//	@Tags			Vitals
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			body	body		vitals.AckVitalsRequest			true	"List of vital IDs successfully synced"
//	@Success		200		{object}	map[string]int					"Count of acknowledged records under key 'acked'"
//	@Failure		400		{object}	response.ErrorEnvelope			"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope			"Not authenticated"
//	@Router			/patients/me/vitals/doctor-sync/ack [post]
func (h *Handler) AckDoctorVitals(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}
	var req AckVitalsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, appErrors.ErrValidationError(err.Error()))
		return
	}
	if err := h.svc.AckDoctorVitals(c.Request.Context(), user, req); err != nil {
		response.SendError(c, err)
		return
	}
	response.JSON(c, http.StatusOK, gin.H{"acked": len(req.SyncedIDs)})
}
