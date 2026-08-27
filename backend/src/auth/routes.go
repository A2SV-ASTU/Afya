package auth

import (
	"afyamind-backend/src/shared/middleware"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(rg *gin.RouterGroup, handler *Handler, jwtSecret string) {
	authGroup := rg.Group("/auth")
	{
		authGroup.POST("/register", handler.Signup)
		authGroup.POST("/signup", handler.Signup)
		authGroup.POST("/login", handler.Login)
		authGroup.POST("/refresh", handler.Refresh)
		authGroup.POST("/logout", middleware.RequireAuth(jwtSecret), handler.Logout)
	}
}
