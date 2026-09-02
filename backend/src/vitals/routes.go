package vitals

import (
	accessrequests "afyamind-backend/src/access-requests"
	sharedAuth "afyamind-backend/src/shared/auth"
	"afyamind-backend/src/shared/middleware"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.RouterGroup, handler *Handler, jwtSecret string) {
	// 1. Encounter Vitals
	encounterVitals := r.Group("/encounters/:id/vitals")
	encounterVitals.Use(middleware.RequireAuth(jwtSecret))
	{
		encounterVitals.POST("",
			middleware.RequireRole("doctor"),
			accessrequests.AccessGuard(sharedAuth.DB),
			handler.RecordEncounterVitals,
		)
	}

	// 2. Patient Self-Log
	singleVital := r.Group("/vitals")
	singleVital.Use(middleware.RequireAuth(jwtSecret))
	{
		singleVital.POST("",
			middleware.RequireRole("patient"),
			handler.LogPatientVital,
		)
	}

	// 3. Logged-in Patient Mobile Sync (Registered BEFORE patientId group to avoid shadowing)
	meVitals := r.Group("/patients/me/vitals")
	meVitals.Use(middleware.RequireAuth(jwtSecret))
	meVitals.Use(middleware.RequireRole("patient"))
	{
		meVitals.POST("/sync", handler.SyncPatientVitals)
		meVitals.GET("/doctor-sync", handler.GetDoctorSyncVitals)
		meVitals.POST("/doctor-sync/ack", handler.AckDoctorVitals)
	}

	// 4. General Vitals List
	patientVitals := r.Group("/patients/:patientId/vitals")
	patientVitals.Use(middleware.RequireAuth(jwtSecret))
	{
		patientVitals.GET("",
			middleware.RequireRole("patient", "doctor"),
			accessrequests.AccessGuard(sharedAuth.DB),
			handler.ListPatientVitals,
		)
	}
}
