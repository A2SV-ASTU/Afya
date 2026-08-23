package middleware

import (
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
)

// RequireAdmin middleware ensures the authenticated user has ADMIN or SUPER_ADMIN role
func RequireAdmin() gin.HandlerFunc {
	return func(c *gin.Context) {
		role, ok := GetUserRole(c)
		if !ok || (role != "ADMIN" && role != "SUPER_ADMIN") {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			c.Abort()
			return
		}
		c.Next()
	}
}
