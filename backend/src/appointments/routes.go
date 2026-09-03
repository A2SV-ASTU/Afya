package appointments

import (
	accessrequests "afyamind-backend/src/access-requests"
	sharedAuth "afyamind-backend/src/shared/auth"
	"afyamind-backend/src/shared/middleware"
	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.RouterGroup, handler *Handler, jwtSecret string) {
	apptGroup := r.Group("/appointments")
	apptGroup.Use(middleware.RequireAuth(jwtSecret))
	{
		apptGroup.POST("", middleware.RequireRole("doctor"), handler.CreateAppointment)
		apptGroup.PATCH("/:id/status", middleware.RequireRole("doctor"), handler.UpdateAppointmentStatus)
	}

	patientApptGroup := r.Group("/patients/:patientId/appointments")
	patientApptGroup.Use(middleware.RequireAuth(jwtSecret))
	{
		patientApptGroup.GET("", middleware.RequireRole("doctor", "patient"), accessrequests.AccessGuard(sharedAuth.DB), handler.GetPatientAppointments)
	}
}
