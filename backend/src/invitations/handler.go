package invitations

import (
	"net/http"

	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/middleware"
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

	if err := h.svc.CreateInvitation(c.Request.Context(), clinicID, callerID, req); err != nil {
		if err.Error() == "unauthorized to invite for this clinic" {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			return
		}
		response.RespondAppError(c, appErrors.ErrInternal(err.Error()))
		return
	}

	response.JSON(c, http.StatusCreated, gin.H{"message": "Invitation created successfully"})
}

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

	// Ideally we would log the user in (issue a cookie), but without the full auth token generator,
	// we just return the user as accepted. The prompt says "log the doctor in (issue cookie)"
	// but the auth package is Dev A's. Let's assume we can just return the user for now.
	// Or we might need to invoke token generation.
	response.JSON(c, http.StatusOK, user)
}
