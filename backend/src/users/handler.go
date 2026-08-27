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

// GetMe handles GET /users/me
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

// UpdateMe handles PATCH /users/me
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

// ChangePassword handles PUT /users/me/password
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

// DeleteMe handles DELETE /users/me
func (h *Handler) DeleteMe(c *gin.Context) {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
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
