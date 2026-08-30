package invitations

import (
	"net/http"

	"afyamind-backend/src/config"
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/shared/response"
	"afyamind-backend/src/users"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct {
	svc Service
	cfg *config.Config
}

func NewHandler(svc Service, cfg *config.Config) *Handler {
	return &Handler{svc: svc, cfg: cfg}
}

// CreateInvitation godoc
//
//	@Summary		Invite a doctor to the clinic
//	@Description	Sends an invitation email to a doctor. Accessible by clinic admins.
//	@Tags			Invitations
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			clinicId	path		string						true	"Clinic UUID"
//	@Param			body		body		invitations.CreateInvitationRequest	true	"Email payload"
//	@Success		201			{object}	response.MessageEnvelope	"Invitation created successfully"
//	@Failure		400			{object}	response.ErrorEnvelope		"Validation error"
//	@Failure		401			{object}	response.ErrorEnvelope		"Not authenticated"
//	@Failure		403			{object}	response.ErrorEnvelope		"Unauthorized to invite"
//	@Router			/clinics/{clinicId}/invitations [post]
func (h *Handler) CreateInvitation(c *gin.Context) {
	clinicIDStr := c.Param("clinicId")
	clinicID, err := uuid.Parse(clinicIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid clinic ID"))
		return
	}

	callerID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
		return
	}

	var req CreateInvitationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError(err.Error()))
		return
	}

	if err := h.svc.CreateInvitation(c.Request.Context(), clinicID, callerID, req, h.cfg.APIBaseURL); err != nil {
		if err.Error() == "unauthorized to invite for this clinic" {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			return
		}
		response.RespondAppError(c, appErrors.ErrInternal(err.Error()))
		return
	}

	response.JSON(c, http.StatusCreated, gin.H{"message": "Invitation created successfully"})
}

// AcceptInvitation godoc
//
//	@Summary		Accept invitation & complete signup
//	@Description	Doctor accepts invitation and fills in profile to complete registration.
//	@Tags			Invitations
//	@Accept			json
//	@Produce		json
//	@Param			token	path		string								true	"Invitation Token"
//	@Param			body	body		invitations.AcceptInvitationRequest	true	"Sign up details"
//	@Success		200		{object}	users.UserResponse					"Doctor account created"
//	@Failure		400		{object}	response.ErrorEnvelope				"Validation error"
//	@Failure		410		{object}	response.ErrorEnvelope				"Invalid or expired token"
//	@Failure		409		{object}	response.ErrorEnvelope				"Invitation already used or revoked"
//	@Router			/invitations/{token}/accept [post]
func (h *Handler) AcceptInvitation(c *gin.Context) {
	token := c.Param("token")
	if token == "" {
		response.RespondAppError(c, appErrors.ErrValidationError("Missing token"))
		return
	}

	var req AcceptInvitationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError(err.Error()))
		return
	}

	user, err := h.svc.AcceptInvitation(c.Request.Context(), token, req)
	if err != nil {
		if err.Error() == "invalid or expired token" || err.Error() == "invitation expired" {
			response.RespondAppError(c, appErrors.ErrExpired(err.Error()))
			return
		}
		if err.Error() == "invitation already used or revoked" {
			response.RespondAppError(c, appErrors.ErrConflict(err.Error()))
			return
		}
		response.RespondAppError(c, appErrors.ErrInternal(err.Error()))
		return
	}

	response.JSON(c, http.StatusOK, users.ToUserResponse(user))
}
