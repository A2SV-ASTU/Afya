package clinics

import (
	"net/http"

	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"

	sharedAuth "afyamind-backend/src/shared/auth"


	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct {
	svc Service
}

func NewHandler(svc Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) CreateClinic(c *gin.Context) {
	var req CreateClinicRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError(err.Error()))
		return
	}

	clinic, err := h.svc.CreateClinic(c.Request.Context(), req)
	if err != nil {
		if err.Error() == "clinic is already deactivated" {
			response.RespondAppError(c, appErrors.ErrConflict(err.Error()))
			return
		}
		// Since it could be database error or something else, handle it.
		// A duplicate email on clinics should throw clinic_email_already_registered
		response.RespondAppError(c, appErrors.ErrConflict(err.Error()))
		return
	}

	response.JSON(c, http.StatusCreated, clinic)
}

func (h *Handler) GetClinics(c *gin.Context) {
	clinics, err := h.svc.GetClinics(c.Request.Context())
	if err != nil {
		response.RespondAppError(c, appErrors.ErrNotFound(err.Error()))
		return
	}

	response.List(c, http.StatusOK, "clinics", clinics)
}

func (h *Handler) DeactivateClinic(c *gin.Context) {
	id, err := uuid.Parse(c.Param("clinicId"))
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError(err.Error()))
		return
	}

	if err := h.svc.DeactivateClinic(c.Request.Context(), id); err != nil {
		if err == ErrClinicNotFound {
			response.RespondAppError(c, appErrors.ErrNotFound(err.Error()))
			return
		}
		response.RespondAppError(c, appErrors.ErrConflict(err.Error()))
		return
	}

	response.JSON(c, http.StatusOK, gin.H{"status": "deactivated"})
}

func (h *Handler) DeactivateDoctor(c *gin.Context) {
	clinicIDStr := c.Param("clinicId")
	doctorIDStr := c.Param("doctorId")

	clinicID, err := uuid.Parse(clinicIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid clinic ID"))
		return
	}

	doctorID, err := uuid.Parse(doctorIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid doctor ID"))
		return
	}

	user, err := sharedAuth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}

	if err := h.svc.DeactivateDoctor(c.Request.Context(), user, clinicID, doctorID); err != nil {
		if err.Error() == "unauthorized for this clinic" {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			return
		}
		if err.Error() == "doctor not found in this clinic" {
			response.RespondAppError(c, appErrors.ErrNotFound("doctor"))
			return
		}
		response.RespondAppError(c, appErrors.ErrInternal(err.Error()))
		return
	}

	response.JSON(c, http.StatusOK, gin.H{"status": "deactivated"})
}

func (h *Handler) ActivateClinic(c *gin.Context) {
	idStr := c.Param("clinicId")
	id, err := uuid.Parse(idStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid clinic ID format"))
		return
	}

	if err := h.svc.ActivateClinic(c.Request.Context(), id); err != nil {
		if err == ErrClinicNotFound {
			response.RespondAppError(c, appErrors.ErrNotFound(err.Error()))
			return
		}
		response.RespondAppError(c, appErrors.ErrConflict(err.Error()))
		return
	}

	response.JSON(c, http.StatusOK, gin.H{"status": "active"})
}

func (h *Handler) ActivateDoctor(c *gin.Context) {
	clinicIDStr := c.Param("clinicId")
	doctorIDStr := c.Param("doctorId")

	clinicID, err := uuid.Parse(clinicIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid clinic ID"))
		return
	}

	doctorID, err := uuid.Parse(doctorIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid doctor ID"))
		return
	}

	user, err := sharedAuth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}

	if err := h.svc.ActivateDoctor(c.Request.Context(), user, clinicID, doctorID); err != nil {
		if err.Error() == "unauthorized for this clinic" {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			return
		}
		if err.Error() == "doctor not found in this clinic" {
			response.RespondAppError(c, appErrors.ErrNotFound(err.Error()))
			return
		}
		response.RespondAppError(c, appErrors.ErrInternal(err.Error()))
		return
	}

	response.JSON(c, http.StatusOK, gin.H{"status": "active"})
}


func (h *Handler) GetClinic(c *gin.Context) {
	user, err := sharedAuth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}

	idParam := c.Param("clinicId")
	id, err := uuid.Parse(idParam)
	if err != nil {
		response.SendError(c, appErrors.ErrValidationError(""))
		return
	}

	clinic, err := h.svc.GetClinic(c.Request.Context(), user, id)
	if err != nil {
		response.SendError(c, err)
		return
	}

	response.JSON(c, http.StatusOK, gin.H{"clinic": clinic})
}

func (h *Handler) GetClinicDoctors(c *gin.Context) {
	user, err := sharedAuth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}

	clinicIDParam := c.Param("clinicId")
	clinicID, err := uuid.Parse(clinicIDParam)
	if err != nil {
		response.SendError(c, appErrors.ErrValidationError(""))
		return
	}

	doctors, err := h.svc.GetClinicDoctors(c.Request.Context(), user, clinicID)
	if err != nil {
		response.SendError(c, err)
		return
	}

	response.List(c, http.StatusOK, "doctors", doctors)
}

func (h *Handler) GetClinicInvitations(c *gin.Context) {
	user, err := sharedAuth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}

	clinicIDParam := c.Param("clinicId")
	clinicID, err := uuid.Parse(clinicIDParam)
	if err != nil {
		response.SendError(c, appErrors.ErrValidationError(""))
		return
	}

	invitations, err := h.svc.GetClinicInvitations(c.Request.Context(), user, clinicID)
	if err != nil {
		response.SendError(c, err)
		return
	}

	response.List(c, http.StatusOK, "invitations", invitations)
}

