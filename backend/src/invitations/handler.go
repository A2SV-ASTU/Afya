package invitations

import (
	"net/http"

	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{service: service}
}

// CreateInvitation handles POST /admin/invitations
func (h *Handler) CreateInvitation(c *gin.Context) {
	var req CreateInvitationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request body"))
		return
	}

	if appErr := h.service.CreateInvitation(c.Request.Context(), req); appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	response.JSON(c, http.StatusCreated, gin.H{"message": "Invitation sent successfully"})
}

// AcceptInvitation handles POST /admin/invitations/accept
func (h *Handler) AcceptInvitation(c *gin.Context) {
	var req AcceptInvitationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request body"))
		return
	}

	if appErr := h.service.AcceptInvitation(c.Request.Context(), req); appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	response.JSON(c, http.StatusOK, gin.H{"message": "Account activated successfully"})
}
