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
		authGroup.POST("/verify-email", handler.VerifyEmail)
		authGroup.POST("/resend-otp", handler.ResendOTP)
		authGroup.POST("/login", handler.Login)
		authGroup.POST("/refresh", handler.Refresh)
		authGroup.POST("/forgot-password", handler.ForgotPassword)
		authGroup.POST("/reset-password", handler.ResetPassword)
		authGroup.POST("/logout", middleware.RequireAuth(jwtSecret), handler.Logout)
	}
}

