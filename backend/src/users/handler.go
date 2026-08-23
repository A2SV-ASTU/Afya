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
		response.RespondAppError(c, appErrors.ErrUnauthorized())
		return
	}

	userResp, appErr := h.service.GetProfile(c.Request.Context(), userID)
	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	response.JSON(c, http.StatusOK, userResp)
}

// UpdateMe handles PATCH /users/me
func (h *Handler) UpdateMe(c *gin.Context) {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthorized())
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

	response.JSON(c, http.StatusOK, userResp)
}

// ChangePassword handles PUT /users/me/password
func (h *Handler) ChangePassword(c *gin.Context) {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthorized())
		return
	}

	var req ChangePasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request payload, old_password and new_password required"))
		return
	}

	if appErr := h.service.ChangePassword(c.Request.Context(), userID, req); appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	response.JSON(c, http.StatusOK, gin.H{"message": "Password updated successfully"})
}

// AcceptDisclaimer handles POST /users/me/disclaimer
func (h *Handler) AcceptDisclaimer(c *gin.Context) {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthorized())
		return
	}

	var req DisclaimerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request payload, age_attested_18 required"))
		return
	}

	userResp, appErr := h.service.AcceptDisclaimer(c.Request.Context(), userID, req)
	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	response.JSON(c, http.StatusOK, userResp)
}
