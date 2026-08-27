package middleware

import (
	"github.com/gin-gonic/gin"
)

// RequireAdmin middleware ensures the authenticated user has clinic_admin or super_admin role
func RequireAdmin() gin.HandlerFunc {
	return RequireRole("clinic_admin", "super_admin")
}
