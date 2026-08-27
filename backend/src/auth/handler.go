package auth

import (
	"net/http"

	"afyamind-backend/src/config"
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"
	"afyamind-backend/src/users"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service Service
	cfg     *config.Config
}

func NewHandler(service Service, cfg *config.Config) *Handler {
	return &Handler{
		service: service,
		cfg:     cfg,
	}
}

func setCookies(c *gin.Context, accessToken, refreshToken string, cfg *config.Config) {
	accessMaxAge := cfg.AccessTokenExpiryMinutes * 60
	refreshMaxAge := cfg.RefreshTokenExpiryDays * 24 * 60 * 60

	c.SetSameSite(http.SameSiteStrictMode)

	c.SetCookie(
		"access_token",
		accessToken,
		accessMaxAge,
		"/",
		cfg.CookieDomain,
		cfg.CookieSecure,
		true, // HttpOnly
	)

	c.SetCookie(
		"refresh_token",
		refreshToken,
		refreshMaxAge,
		"/",
		cfg.CookieDomain,
		cfg.CookieSecure,
		true, // HttpOnly
	)
}

func clearCookies(c *gin.Context, cfg *config.Config) {
	c.SetSameSite(http.SameSiteStrictMode)
	c.SetCookie("access_token", "", -1, "/", cfg.CookieDomain, cfg.CookieSecure, true)
	c.SetCookie("refresh_token", "", -1, "/", cfg.CookieDomain, cfg.CookieSecure, true)
}

// Signup handles POST /auth/signup or /auth/register
func (h *Handler) Signup(c *gin.Context) {
	var req SignupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request body"))
		return
	}

	user, accessToken, refreshToken, appErr := h.service.Signup(c.Request.Context(), req)
	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	setCookies(c, accessToken, refreshToken, h.cfg)
	response.JSON(c, http.StatusCreated, gin.H{
		"data": users.ToUserResponse(user),
	})
}

// Login handles POST /auth/login
func (h *Handler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request body"))
		return
	}

	user, accessToken, refreshToken, appErr := h.service.Login(c.Request.Context(), req)
	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	setCookies(c, accessToken, refreshToken, h.cfg)
	response.JSON(c, http.StatusOK, gin.H{
		"data": gin.H{
			"user": users.ToUserResponse(user),
		},
	})
}

// Refresh handles POST /auth/refresh
func (h *Handler) Refresh(c *gin.Context) {
	var refreshToken string
	var req RefreshRequest
	if err := c.ShouldBindJSON(&req); err == nil && req.RefreshToken != "" {
		refreshToken = req.RefreshToken
	}

	if refreshToken == "" {
		cookieToken, err := c.Cookie("refresh_token")
		if err == nil {
			refreshToken = cookieToken
		}
	}

	if refreshToken == "" {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
		return
	}

	_, newAccessToken, appErr := h.service.Refresh(c.Request.Context(), refreshToken)
	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	// Update access_token cookie
	c.SetSameSite(http.SameSiteStrictMode)
	c.SetCookie(
		"access_token",
		newAccessToken,
		h.cfg.AccessTokenExpiryMinutes*60,
		"/",
		h.cfg.CookieDomain,
		h.cfg.CookieSecure,
		true,
	)

	response.JSON(c, http.StatusOK, gin.H{
		"data": gin.H{
			"message": "Token refreshed successfully",
		},
	})
}

// Logout handles POST /auth/logout
func (h *Handler) Logout(c *gin.Context) {
	clearCookies(c, h.cfg)
	response.JSON(c, http.StatusOK, gin.H{
		"data": gin.H{
			"message": "Logged out successfully",
		},
	})
}
