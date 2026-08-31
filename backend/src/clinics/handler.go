package clinics

import (
	"net/http"

	sharedAuth "afyamind-backend/src/shared/auth"
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct {
	svc Service
}

func NewHandler(svc Service) *Handler {
	return &Handler{svc: svc}
}

// CreateClinic godoc
//
//	@Summary		Create a new clinic
//	@Description	Registers a new healthcare clinic and seeds its first admin. Super Admin only.
//	@Tags			Clinics
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			body	body		clinics.CreateClinicRequest	true	"Clinic details"
//	@Success		201		{object}	clinics.Clinic				"Clinic created successfully"
//	@Failure		400		{object}	response.ErrorEnvelope		"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope		"Not authenticated"
//	@Failure		409		{object}	response.ErrorEnvelope		"Clinic email already registered or status conflict"
//	@Router			/clinics [post]
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

// GetClinics godoc
//
//	@Summary		List all clinics
//	@Description	Returns a list of all registered healthcare clinics. Super Admin only.
//	@Tags			Clinics
//	@Produce		json
//	@Security		BearerAuth
//	@Success		200	{object}	response.DataEnvelope{data=[]clinics.Clinic}	"List of clinics"
//	@Failure		401	{object}	response.ErrorEnvelope							"Not authenticated"
//	@Failure		404	{object}	response.ErrorEnvelope							"No clinics found"
//	@Router			/clinics [get]
func (h *Handler) GetClinics(c *gin.Context) {
	clinics, err := h.svc.GetClinics(c.Request.Context())
	if err != nil {
		response.RespondAppError(c, appErrors.ErrNotFound(err.Error()))
		return
	}

	response.List(c, http.StatusOK, "clinics", clinics)
}

// DeactivateClinic godoc
//
//	@Summary		Deactivate a clinic
//	@Description	Changes status of the clinic to deactivated. Super Admin only.
//	@Tags			Clinics
//	@Produce		json
//	@Security		BearerAuth
//	@Param			clinicId	path		string						true	"Clinic ID"
//	@Success		200			{object}	response.MessageEnvelope	"Clinic deactivated successfully"
//	@Failure		400			{object}	response.ErrorEnvelope		"Invalid UUID format"
//	@Failure		401			{object}	response.ErrorEnvelope		"Not authenticated"
//	@Failure		404			{object}	response.ErrorEnvelope		"Clinic not found"
//	@Router			/clinics/{clinicId}/deactivate [patch]
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

// DeactivateDoctor godoc
//
//	@Summary		Deactivate a doctor
//	@Description	Deactivates a doctor's account in the specified clinic. Clinic admin only.
//	@Tags			Clinics
//	@Produce		json
//	@Security		BearerAuth
//	@Param			clinicId	path		string						true	"Clinic ID"
//	@Param			doctorId	path		string						true	"Doctor ID"
//	@Success		200			{object}	response.MessageEnvelope	"Doctor deactivated successfully"
//	@Failure		400			{object}	response.ErrorEnvelope		"Validation error"
//	@Failure		401			{object}	response.ErrorEnvelope		"Not authenticated"
//	@Failure		403			{object}	response.ErrorEnvelope		"Forbidden — unauthorized for clinic"
//	@Failure		404			{object}	response.ErrorEnvelope		"Doctor not found"
//	@Router			/clinics/{clinicId}/doctors/{doctorId}/deactivate [patch]
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

// ActivateClinic godoc
//
//	@Summary		Activate a clinic
//	@Description	Changes status of the clinic to active. Super Admin only.
//	@Tags			Clinics
//	@Produce		json
//	@Security		BearerAuth
//	@Param			clinicId	path		string						true	"Clinic ID"
//	@Success		200			{object}	response.MessageEnvelope	"Clinic activated successfully"
//	@Failure		400			{object}	response.ErrorEnvelope		"Invalid UUID format"
//	@Failure		401			{object}	response.ErrorEnvelope		"Not authenticated"
//	@Failure		404			{object}	response.ErrorEnvelope		"Clinic not found"
//	@Router			/clinics/{clinicId}/activate [patch]
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

// ActivateDoctor godoc
//
//	@Summary		Activate a doctor
//	@Description	Activates a doctor's account in the specified clinic. Clinic admin only.
//	@Tags			Clinics
//	@Produce		json
//	@Security		BearerAuth
//	@Param			clinicId	path		string						true	"Clinic ID"
//	@Param			doctorId	path		string						true	"Doctor ID"
//	@Success		200			{object}	response.MessageEnvelope	"Doctor activated successfully"
//	@Failure		400			{object}	response.ErrorEnvelope		"Validation error"
//	@Failure		401			{object}	response.ErrorEnvelope		"Not authenticated"
//	@Failure		403			{object}	response.ErrorEnvelope		"Forbidden — unauthorized for clinic"
//	@Failure		404			{object}	response.ErrorEnvelope		"Doctor not found"
//	@Router			/clinics/{clinicId}/doctors/{doctorId}/activate [patch]
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

// GetClinic godoc
//
//	@Summary		Get clinic details
//	@Description	Retrieves clinical information for a single clinic. Super Admin or Clinic Admin.
//	@Tags			Clinics
//	@Produce		json
//	@Security		BearerAuth
//	@Param			clinicId	path		string									true	"Clinic ID"
//	@Success		200			{object}	response.DataEnvelope{data=clinics.Clinic}	"Clinic details"
//	@Failure		400			{object}	response.ErrorEnvelope					"Validation error"
//	@Failure		401			{object}	response.ErrorEnvelope					"Not authenticated"
//	@Router			/clinics/{clinicId} [get]
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

// GetClinicDoctors godoc
//
//	@Summary		List doctors in a clinic
//	@Description	Lists all doctors registered under a specific clinic. Super Admin or Clinic Admin.
//	@Tags			Clinics
//	@Produce		json
//	@Security		BearerAuth
//	@Param			clinicId	path		string												true	"Clinic ID"
//	@Success		200			{object}	response.DataEnvelope{data=[]clinics.DoctorResponse}	"List of doctors"
//	@Failure		400			{object}	response.ErrorEnvelope								"Validation error"
//	@Failure		401			{object}	response.ErrorEnvelope								"Not authenticated"
//	@Router			/clinics/{clinicId}/doctors [get]
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

// GetClinicInvitations godoc
//
//	@Summary		List invitations in a clinic
//	@Description	Lists all sent invitations for a specific clinic. Super Admin or Clinic Admin.
//	@Tags			Clinics
//	@Produce		json
//	@Security		BearerAuth
//	@Param			clinicId	path		string													true	"Clinic ID"
//	@Success		200			{object}	response.DataEnvelope{data=[]clinics.InvitationResponse}	"List of invitations"
//	@Failure		400			{object}	response.ErrorEnvelope									"Validation error"
//	@Failure		401			{object}	response.ErrorEnvelope									"Not authenticated"
//	@Router			/clinics/{clinicId}/invitations [get]
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
