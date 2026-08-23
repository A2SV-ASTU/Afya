package users

import (
	"afyamind-backend/src/shared/middleware"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(rg *gin.RouterGroup, handler *Handler, jwtSecret string) {
	usersGroup := rg.Group("/users")
	usersGroup.Use(middleware.RequireAuth(jwtSecret))
	{
		usersGroup.GET("/me", handler.GetMe)
		usersGroup.PATCH("/me", handler.UpdateMe)
		usersGroup.POST("/me/disclaimer", handler.AcceptDisclaimer)
	}
}
