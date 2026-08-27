package middleware

import (
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
)

// RequireRole checks if the authenticated user has one of the allowed roles.
func RequireRole(roles ...string) gin.HandlerFunc {
	allowed := make(map[string]bool, len(roles))
	for _, r := range roles {
		allowed[r] = true
	}

	return func(c *gin.Context) {
		role, ok := GetUserRole(c)
		if !ok || !allowed[role] {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			c.Abort()
			return
		}
		c.Next()
	}
}
