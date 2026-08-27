package middleware

import (
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"
	"afyamind-backend/src/token"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

const (
	ContextKeyUserID   = "user_id"
	ContextKeyUserRole = "user_role"
)

// RequireAuth middleware extracts access_token cookie and validates the JWT claims
func RequireAuth(jwtSecret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		cookie, err := c.Cookie("access_token")
		if err != nil || cookie == "" {
			response.RespondAppError(c, appErrors.ErrUnauthenticated())
			c.Abort()
			return
		}

		claims, err := token.ParseToken(cookie, jwtSecret)
		if err != nil || claims.TokenType != token.TokenTypeAccess {
			response.RespondAppError(c, appErrors.ErrUnauthenticated())
			c.Abort()
			return
		}

		c.Set(ContextKeyUserID, claims.UserID)
		c.Set(ContextKeyUserRole, claims.Role)
		c.Next()
	}
}

// GetUserID retrieves the authenticated user's UUID from gin Context
func GetUserID(c *gin.Context) (uuid.UUID, bool) {
	val, exists := c.Get(ContextKeyUserID)
	if !exists {
		return uuid.Nil, false
	}
	id, ok := val.(uuid.UUID)
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
