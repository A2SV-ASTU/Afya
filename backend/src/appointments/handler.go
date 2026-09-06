package appointments

import (
	"net/http"

	"afyamind-backend/src/shared/auth"
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

// CreateAppointment godoc
//
//	@Summary		Create a new appointment
//	@Description	Schedules a consultation between a patient and the doctor. Enforces access guard permissions.
//	@Tags			Appointments
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			body	body		appointments.CreateAppointmentRequest	true	"Appointment details"
//	@Success		201		{object}	response.DataEnvelope{data=appointments.Appointment}	"Appointment scheduled"
//	@Failure		400		{object}	response.ErrorEnvelope					"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope					"Not authenticated"
//	@Router			/appointments [post]
func (h *Handler) CreateAppointment(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}

	var req CreateAppointmentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, errors.ErrValidationError(""))
		return
	}

	appt, err := h.service.CreateAppointment(c.Request.Context(), user, req)
	if err != nil {
		response.SendError(c, err)
		return
	}

	response.JSON(c, http.StatusCreated, gin.H{"appointment": appt})
}

// GetPatientAppointments godoc
//
//	@Summary		Get appointments for a patient
//	@Description	Retrieves all scheduled/past appointments for a specific patient. Filterable by status.
//	@Tags			Appointments
//	@Produce		json
//	@Security		BearerAuth
//	@Param			patientId	path		string								true	"Patient UUID"
//	@Param			status		query		string								false	"Filter by appointment status (scheduled, attended, cancelled)"
//	@Success		200			{object}	response.DataEnvelope{data=[]appointments.Appointment}	"List of appointments"
//	@Failure		400			{object}	response.ErrorEnvelope				"Validation/ID error"
//	@Failure		401			{object}	response.ErrorEnvelope				"Not authenticated"
//	@Router			/patients/{patientId}/appointments [get]
func (h *Handler) GetPatientAppointments(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}

	patientIDParam := c.Param("patientId")
	patientID, err := uuid.Parse(patientIDParam)
	if err != nil {
		response.SendError(c, errors.ErrValidationError(""))
		return
	}

	var status *AppointmentStatus
	if statusQuery := c.Query("status"); statusQuery != "" {
		s := AppointmentStatus(statusQuery)
		status = &s
	}

	appointments, err := h.service.GetPatientAppointments(c.Request.Context(), user, patientID, status)
	if err != nil {
		response.SendError(c, err)
		return
	}

	response.List(c, http.StatusOK, "appointments", appointments)
}

// UpdateAppointmentStatus godoc
//
//	@Summary		Update appointment status
//	@Description	Updates the status of an appointment (e.g. attended, missed, cancelled). Requires doctor role.
//	@Tags			Appointments
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string										true	"Appointment UUID"
//	@Param			body	body		appointments.UpdateAppointmentStatusRequest	true	"New appointment status"
//	@Success		200		{object}	response.DataEnvelope{data=appointments.Appointment}	"Appointment updated"
//	@Failure		400		{object}	response.ErrorEnvelope						"Validation/ID error"
//	@Failure		401		{object}	response.ErrorEnvelope						"Not authenticated"
//	@Failure		403		{object}	response.ErrorEnvelope						"Forbidden role"
//	@Failure		404		{object}	response.ErrorEnvelope						"Appointment not found"
//	@Router			/appointments/{id}/status [patch]
func (h *Handler) UpdateAppointmentStatus(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}

	apptIDParam := c.Param("id")
	apptID, err := uuid.Parse(apptIDParam)
	if err != nil {
		response.SendError(c, errors.ErrValidationError("invalid appointment ID"))
		return
	}

	var req UpdateAppointmentStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, errors.ErrValidationError(""))
		return
	}

	appt, err := h.service.UpdateAppointmentStatus(c.Request.Context(), user, apptID, req)
	if err != nil {
		response.SendError(c, err)
		return
	}

	response.JSON(c, http.StatusOK, gin.H{"appointment": appt})
}
