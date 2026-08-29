package clinicalevaluations

import (
	"database/sql"

	accessrequests "afyamind-backend/src/access-requests"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/users"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(rg *gin.RouterGroup, handler *Handler, db *sql.DB, jwtSecret string) {
	evalGroup := rg.Group("/encounters/:id/clinical-evaluation")
	evalGroup.Use(middleware.RequireAuth(jwtSecret))
	{
		evalGroup.POST("", middleware.RequireRole(string(users.RoleDoctor)), accessrequests.AccessGuard(db), handler.CreateClinicalEvaluation)
		evalGroup.GET("", middleware.RequireRole(string(users.RoleDoctor), string(users.RolePatient)), accessrequests.AccessGuard(db), handler.GetClinicalEvaluation)
	}
}
