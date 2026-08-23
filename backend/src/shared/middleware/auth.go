package middleware

import (
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"
	"afyamind-backend/src/token"

	"github.com/gin-gonic/gin"
)

const (
	ContextKeyUserID     = "user_id"
	ContextKeyUserRole   = "user_role"
	ContextKeyDisclaimer = "disclaimer_accepted"
)

// RequireAuth middleware extracts access_token cookie and validates the JWT claims
func RequireAuth(jwtSecret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		cookie, err := c.Cookie("access_token")
		if err != nil || cookie == "" {
			response.RespondAppError(c, appErrors.ErrUnauthorized())
			c.Abort()
			return
		}

		claims, err := token.ParseToken(cookie, jwtSecret)
		if err != nil || claims.TokenType != token.TokenTypeAccess {
			response.RespondAppError(c, appErrors.ErrUnauthorized())
			c.Abort()
			return
		}

		c.Set(ContextKeyUserID, claims.UserID)
		c.Set(ContextKeyUserRole, claims.Role)
		c.Next()
	}
}

// GetUserID retrieves the authenticated user's ID from gin Context
func GetUserID(c *gin.Context) (int64, bool) {
	val, exists := c.Get(ContextKeyUserID)
	if !exists {
		return 0, false
	}
	id, ok := val.(int64)
	return id, ok
}

// GetUserRole retrieves the authenticated user's role from gin Context
func GetUserRole(c *gin.Context) (string, bool) {
	val, exists := c.Get(ContextKeyUserRole)
	if !exists {
		return "", false
	}
	role, ok := val.(string)
	return role, ok
}
