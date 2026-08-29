package encounters

import (
	"database/sql"

	accessrequests "afyamind-backend/src/access-requests"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/users"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(rg *gin.RouterGroup, handler *Handler, db *sql.DB, jwtSecret string) {
	patientEncounters := rg.Group("/patients/:patientId/encounters")
	patientEncounters.Use(middleware.RequireAuth(jwtSecret))
	{
		patientEncounters.POST("", middleware.RequireRole(string(users.RoleDoctor)), accessrequests.AccessGuard(db), handler.CreateEncounter)
		patientEncounters.GET("", middleware.RequireRole(string(users.RoleDoctor), string(users.RolePatient)), accessrequests.AccessGuard(db), handler.ListEncounters)
	}

	encountersGroup := rg.Group("/encounters")
	encountersGroup.Use(middleware.RequireAuth(jwtSecret))
	{
		encountersGroup.GET("/:id", middleware.RequireRole(string(users.RoleDoctor), string(users.RolePatient)), accessrequests.AccessGuard(db), handler.GetEncounter)
		encountersGroup.PATCH("/:id/close", middleware.RequireRole(string(users.RoleDoctor)), accessrequests.AccessGuard(db), handler.CloseEncounter)
		encountersGroup.GET("/:id/medical-history", middleware.RequireRole(string(users.RoleDoctor), string(users.RolePatient)), accessrequests.AccessGuard(db), handler.GetMedicalHistory)
	}
}
