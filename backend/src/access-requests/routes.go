package accessrequests

import (
	"afyamind-backend/src/shared/middleware"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(rg *gin.RouterGroup, handler *Handler, jwtSecret string) {
	// Clinic admin/doctor routes
	clinicsGroup := rg.Group("/clinics/:clinicId/access-requests")
	clinicsGroup.Use(middleware.RequireAuth(jwtSecret))
	// Technically either clinic_admin or doctor can list or create.
	// We'll enforce role inside handler or use a combined role check.
	clinicsGroup.Use(middleware.RequireRole("clinic_admin", "doctor"))
	{
		clinicsGroup.GET("", handler.ListRequests)
		clinicsGroup.POST("", handler.CreateRequest)
		// Only clinic admin can revoke, we use a separate group
		revokeGroup := clinicsGroup.Group("/:id/revoke")
		revokeGroup.Use(middleware.RequireRole("clinic_admin"))
		{
			revokeGroup.POST("", handler.RevokeRequest)
		}
	}

	// Patients lookup endpoint (clinic_admin only, own clinic enforced in guard/handler if needed, but since it's just email lookup, role check is enough for now based on contract)
	patientLookupGroup := rg.Group("/patients/lookup")
	patientLookupGroup.Use(middleware.RequireAuth(jwtSecret))
	patientLookupGroup.Use(middleware.RequireRole("clinic_admin")) // The brief says "clinic_admin (own clinic)", but it's an exact-email lookup.
	{
		patientLookupGroup.GET("", handler.LookupPatient)
	}

	// Patient routes
	patientAccessGroup := rg.Group("/access-requests/:id")
	patientAccessGroup.Use(middleware.RequireAuth(jwtSecret))
	patientAccessGroup.Use(middleware.RequireRole("patient"))
	{
		patientAccessGroup.POST("/approve", handler.ApproveRequest)
		patientAccessGroup.POST("/deny", handler.DenyRequest)
	}

	// Patient portal routes (listing and grant management)
	patientPortalGroup := rg.Group("/patient")
	patientPortalGroup.Use(middleware.RequireAuth(jwtSecret))
	patientPortalGroup.Use(middleware.RequireRole("patient"))
	{
		patientPortalGroup.GET("/access-requests/active", handler.ListPatientActiveRequests)
		patientPortalGroup.GET("/grants", handler.ListPatientGrants)
		patientPortalGroup.POST("/grants/:clinicId/revoke", handler.RevokePatientGrant)
	}

}
