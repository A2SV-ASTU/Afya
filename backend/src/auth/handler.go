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

// Signup godoc
//
//	@Summary		Register a new patient account
//	@Description	Creates a new patient account and sets HttpOnly JWT cookies (access_token + refresh_token).
//	@Description	Also aliased at POST /auth/signup.
//	@Tags			Auth
//	@Accept			json
//	@Produce		json
//	@Param			body	body		auth.SignupRequest						true	"Patient registration payload"
//	@Success		201		{object}	response.DataEnvelope{data=users.UserResponse}	"Account created"
//	@Failure		400		{object}	response.ErrorEnvelope					"Validation error"
//	@Failure		409		{object}	response.ErrorEnvelope					"Email or phone already in use"
//	@Router			/auth/register [post]
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

// Login godoc
//
//	@Summary		Authenticate a user
//	@Description	Validates credentials and sets HttpOnly JWT cookies (access_token + refresh_token).
//	@Description	Provide either email or phone, together with password.
//	@Tags			Auth
//	@Accept			json
//	@Produce		json
//	@Param			body	body		auth.LoginRequest						true	"Login credentials"
//	@Success		200		{object}	response.DataEnvelope{data=users.UserResponse}	"Login successful"
//	@Failure		400		{object}	response.ErrorEnvelope					"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope					"Invalid credentials"
//	@Router			/auth/login [post]
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

// Refresh godoc
//
//	@Summary		Refresh the access token
//	@Description	Issues a new access_token cookie. Reads the refresh token from the HttpOnly cookie by default.
//	@Description	Optionally accepts a JSON body with refresh_token for non-cookie clients.
//	@Tags			Auth
//	@Accept			json
//	@Produce		json
//	@Param			body	body		auth.RefreshRequest			false	"Optional: refresh token in JSON body"
//	@Success		200		{object}	response.MessageEnvelope	"Token refreshed"
//	@Failure		401		{object}	response.ErrorEnvelope		"Missing or invalid refresh token"
//	@Router			/auth/refresh [post]
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

// Logout godoc
//
//	@Summary		Log out the current user
//	@Description	Clears the access_token and refresh_token HttpOnly cookies.
//	@Tags			Auth
//	@Produce		json
//	@Security		BearerAuth
//	@Success		200	{object}	response.MessageEnvelope	"Logged out"
//	@Failure		401	{object}	response.ErrorEnvelope		"Not authenticated"
//	@Router			/auth/logout [post]
func (h *Handler) Logout(c *gin.Context) {
	clearCookies(c, h.cfg)
	response.JSON(c, http.StatusOK, gin.H{
		"data": gin.H{
			"message": "Logged out successfully",
		},
	})
}

// ForgotPassword godoc
//
//	@Summary		Request password reset link
//	@Description	If the email matches an account, sends a password reset link to it. Returns success regardless to prevent user enumeration.
//	@Tags			Auth
//	@Accept			json
//	@Produce		json
//	@Param			body	body		auth.ForgotPasswordRequest	true	"Email for password reset request"
//	@Success		200		{object}	response.MessageEnvelope	"Request processed successfully"
//	@Failure		400		{object}	response.ErrorEnvelope		"Validation error"
//	@Router			/auth/forgot-password [post]
func (h *Handler) ForgotPassword(c *gin.Context) {
	var req ForgotPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid email format"))
		return
	}

	_ = h.service.ForgotPassword(c.Request.Context(), req.Email)
	// Do not leak whether the email exists or if there was an internal error. Always return success.

	response.JSON(c, http.StatusOK, gin.H{
		"data": gin.H{
			"message": "If an account exists with that email, a password reset link has been sent.",
		},
	})
}

// ResetPassword godoc
//
//	@Summary		Reset password using token
//	@Description	Resets the password if the token is valid and unexpired. Clears reset token cookie.
//	@Tags			Auth
//	@Accept			json
//	@Produce		json
//	@Param			body	body		auth.ResetPasswordRequest	true	"Token and new password"
//	@Success		200		{object}	response.MessageEnvelope	"Password reset successfully"
//	@Failure		400		{object}	response.ErrorEnvelope		"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope		"Invalid or expired token"
//	@Router			/auth/reset-password [post]
func (h *Handler) ResetPassword(c *gin.Context) {
	var req ResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request payload"))
		return
	}

	token := req.Token
	if token == "" {
		if cookieToken, err := c.Cookie("reset_token"); err == nil && cookieToken != "" {
			token = cookieToken
		}
	}

	if token == "" {
		response.RespondAppError(c, appErrors.ErrValidationError("Reset token is required"))
		return
	}

	appErr := h.service.ResetPassword(c.Request.Context(), token, req.Password)

	if appErr != nil {
		response.RespondAppError(c, appErr)
		return
	}

	// Clear reset_token cookie after successful reset
	c.SetSameSite(http.SameSiteStrictMode)
	c.SetCookie("reset_token", "", -1, "/", h.cfg.CookieDomain, h.cfg.CookieSecure, true)

	response.JSON(c, http.StatusOK, gin.H{
		"data": gin.H{
			"message": "Password has been successfully reset. You can now log in.",
		},
	})
}
