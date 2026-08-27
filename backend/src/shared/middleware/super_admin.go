package middleware

import (
	"github.com/gin-gonic/gin"
)

// RequireSuperAdmin middleware ensures the authenticated user has super_admin role
func RequireSuperAdmin() gin.HandlerFunc {
	return RequireRole("super_admin")
}
