package diagnoses

import (
	"database/sql"

	accessrequests "afyamind-backend/src/access-requests"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/users"
	"github.com/gin-gonic/gin"
)

func RegisterRoutes(router *gin.RouterGroup, handler *Handler, db *sql.DB, jwtSecret string) {
	group := router.Group("/encounters/:id/diagnoses")
	group.Use(middleware.RequireAuth(jwtSecret))
	{
		group.POST("", middleware.RequireRole(string(users.RoleDoctor)), accessrequests.AccessGuard(db), handler.CreateDiagnosis)
		group.GET("", middleware.RequireRole(string(users.RoleDoctor), string(users.RolePatient)), accessrequests.AccessGuard(db), handler.GetDiagnoses)
	}
}

