package prescriptions

import (
	accessrequests "afyamind-backend/src/access-requests"
	sharedAuth "afyamind-backend/src/shared/auth"
	"afyamind-backend/src/shared/middleware"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.RouterGroup, handler *Handler, jwtSecret string) {
	// Encounter-scoped routes
	encounterRx := r.Group("/encounters/:id/prescriptions")
	encounterRx.Use(middleware.RequireAuth(jwtSecret))
	{
		encounterRx.POST("",
			middleware.RequireRole("doctor"),
			accessrequests.AccessGuard(sharedAuth.DB),
			handler.CreatePrescription,
		)
		encounterRx.GET("",
			middleware.RequireRole("doctor", "patient"),
			accessrequests.AccessGuard(sharedAuth.DB),
			handler.ListPrescriptions,
		)
	}

	// Prescription-level mutation routes protected by package-level PrescriptionAccessGuard
	rxGroup := r.Group("/prescriptions/:id")
	rxGroup.Use(middleware.RequireAuth(jwtSecret))
	{
		rxGroup.PATCH("",
			middleware.RequireRole("doctor"),
			PrescriptionAccessGuard(sharedAuth.DB),
			handler.UpdatePrescription,
		)
		rxGroup.PATCH("/complete",
			middleware.RequireRole("patient"),
			PrescriptionAccessGuard(sharedAuth.DB),
			handler.CompletePrescription,
		)
		rxGroup.PATCH("/deactivate",
			middleware.RequireRole("doctor"),
			PrescriptionAccessGuard(sharedAuth.DB),
			handler.DeactivatePrescription,
		)
	}

	// Patient-scoped prescription history
	patientRx := r.Group("/patients/:patientId/prescriptions")
	patientRx.Use(middleware.RequireAuth(jwtSecret))
	{
		patientRx.GET("",
			middleware.RequireRole("doctor", "patient"),
			accessrequests.AccessGuard(sharedAuth.DB),
			handler.ListPatientPrescriptions,
		)
	}
}

