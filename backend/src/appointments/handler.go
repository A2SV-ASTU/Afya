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
