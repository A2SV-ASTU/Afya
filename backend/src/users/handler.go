package users

import (
	"net/http"

	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{service: service}
}

// GetMe godoc
//
//	@Summary		Get current user profile
//	@Description	Returns the full profile of the authenticated user.
//	@Tags			Users
//	@Produce		json
//	@Security		BearerAuth
//	@Success		200	{object}	response.DataEnvelope{data=users.UserResponse}	"User profile"
//	@Failure		401	{object}	response.ErrorEnvelope							"Not authenticated"
//	@Failure		404	{object}	response.ErrorEnvelope							"User not found"
//	@Router			/users/me [get]
func (h *Handler) GetMe(c *gin.Context) {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
		return
	}

	userResp, appErr := h.service.GetProfile(c.Request.Context(), userID)
	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	response.JSON(c, http.StatusOK, gin.H{
		"data": userResp,
	})
}

// UpdateMe godoc
//
//	@Summary		Update current user profile
//	@Description	Partially updates the authenticated user's profile. All fields are optional.
//	@Tags			Users
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			body	body		users.UpdateProfileRequest						true	"Fields to update (all optional)"
//	@Success		200		{object}	response.DataEnvelope{data=users.UserResponse}	"Updated profile"
//	@Failure		400		{object}	response.ErrorEnvelope							"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope							"Not authenticated"
//	@Router			/users/me [patch]
func (h *Handler) UpdateMe(c *gin.Context) {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
		return
	}

	var req UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request body"))
		return
	}

	userResp, appErr := h.service.UpdateProfile(c.Request.Context(), userID, req)
	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	response.JSON(c, http.StatusOK, gin.H{
		"data": userResp,
	})
}

// ChangePassword godoc
//
//	@Summary		Change account password
//	@Description	Updates the authenticated user's password after verifying the current one.
//	@Description	Accessible via both PUT and PATCH on /users/me/password.
//	@Tags			Users
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			body	body		users.ChangePasswordRequest	true	"Current and new password"
//	@Success		200		{object}	response.MessageEnvelope	"Password updated"
//	@Failure		400		{object}	response.ErrorEnvelope		"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope		"Not authenticated or wrong current password"
//	@Router			/users/me/password [put]
func (h *Handler) ChangePassword(c *gin.Context) {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
		return
	}

	var req ChangePasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request payload, current_password and new_password required"))
		return
	}

	if appErr := h.service.ChangePassword(c.Request.Context(), userID, req); appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	response.JSON(c, http.StatusOK, gin.H{
		"data": gin.H{
			"message": "Password updated successfully",
		},
	})
}

// DeleteMe godoc
//
//	@Summary		Delete current user account
//	@Description	Permanently deletes the authenticated user's account (not allowed for super_admin role).
//	@Tags			Users
//	@Produce		json
//	@Security		BearerAuth
//	@Success		200	{object}	response.MessageEnvelope	"Account deleted"
//	@Failure		401	{object}	response.ErrorEnvelope		"Not authenticated"
//	@Failure		403	{object}	response.ErrorEnvelope		"Forbidden for super_admin role"
//	@Failure		500	{object}	response.ErrorEnvelope		"Internal error"
//	@Router			/users/me [delete]
func (h *Handler) DeleteMe(c *gin.Context) {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
		return
	}

	role, ok := middleware.GetUserRole(c)
	if ok && role == string(RoleSuperAdmin) {
		response.RespondAppError(c, appErrors.ErrForbiddenRole())
		return
	}

	if appErr := h.service.DeleteAccount(c.Request.Context(), userID); appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	response.JSON(c, http.StatusOK, gin.H{
		"data": gin.H{
			"message": "Account deleted successfully",
		},
	})
}
