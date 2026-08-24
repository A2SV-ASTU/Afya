package middleware

import (
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
)

// RequireSuperAdmin middleware ensures the authenticated user has SUPER_ADMIN role
func RequireSuperAdmin() gin.HandlerFunc {
	return func(c *gin.Context) {
		role, ok := GetUserRole(c)
		if !ok || role != "SUPER_ADMIN" {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			c.Abort()
			return
		}
		c.Next()
	}
}
