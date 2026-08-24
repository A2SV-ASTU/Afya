package invitations

import (
	"afyamind-backend/src/shared/middleware"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(rg *gin.RouterGroup, handler *Handler, jwtSecret string) {
	adminGroup := rg.Group("/admin")
	{
		// POST /admin/invitations — SUPER_ADMIN only
		adminGroup.POST("/invitations",
			middleware.RequireAuth(jwtSecret),
			middleware.RequireSuperAdmin(),
			handler.CreateInvitation,
		)

		// POST /admin/invitations/accept — Public (token is the auth)
		adminGroup.POST("/invitations/accept", handler.AcceptInvitation)
	}
}
