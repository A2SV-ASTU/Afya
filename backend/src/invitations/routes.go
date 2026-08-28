package invitations

import (
	"afyamind-backend/src/shared/middleware"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(rg *gin.RouterGroup, handler *Handler, jwtSecret string) {
	// Clinic admin routes
	clinicsGroup := rg.Group("/clinics/:clinicId/invitations")
	clinicsGroup.Use(middleware.RequireAuth(jwtSecret))
	clinicsGroup.Use(middleware.RequireRole("clinic_admin"))
	{
		clinicsGroup.POST("", handler.CreateInvitation)
	}

	// Public routes
	publicGroup := rg.Group("/invitations")
	{
		publicGroup.POST("/:token/accept", handler.AcceptInvitation)
	}
}
