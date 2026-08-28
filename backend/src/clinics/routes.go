package clinics

import (
	"afyamind-backend/src/shared/middleware"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(rg *gin.RouterGroup, handler *Handler, jwtSecret string) {
	clinicsGroup := rg.Group("/clinics")
	clinicsGroup.Use(middleware.RequireAuth(jwtSecret))

	// Super Admin routes
	superAdminGroup := clinicsGroup.Group("")
	superAdminGroup.Use(middleware.RequireSuperAdmin())
	{
		superAdminGroup.POST("", handler.CreateClinic)
		superAdminGroup.GET("", handler.GetClinics)
		superAdminGroup.PATCH("/:clinicId/deactivate", handler.DeactivateClinic)
		superAdminGroup.PATCH("/:clinicId/activate", handler.ActivateClinic)
	}

	// Clinic admin routes
	clinicAdminGroup := clinicsGroup.Group("/:clinicId/doctors/:doctorId")
	clinicAdminGroup.Use(middleware.RequireRole("clinic_admin"))
	{
		clinicAdminGroup.PATCH("/deactivate", handler.DeactivateDoctor)
		clinicAdminGroup.PATCH("/activate", handler.ActivateDoctor)
	}

	// NOTE: Other clinics endpoints (e.g. GET /clinics/:clinicId, GET /clinics/:clinicId/doctors)
	// are owned by another dev and will be added here later.
}
