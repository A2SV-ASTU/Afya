package middleware

import (
	"context"

	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
)

type DisclaimerChecker interface {
	IsDisclaimerAccepted(ctx context.Context, userID int64) (bool, error)
}

// RequireDisclaimer middleware checks if the authenticated user has accepted the disclaimer
func RequireDisclaimer(checker DisclaimerChecker) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, ok := GetUserID(c)
		if !ok {
			response.RespondAppError(c, appErrors.ErrUnauthorized())
			c.Abort()
			return
		}

		accepted, err := checker.IsDisclaimerAccepted(c.Request.Context(), userID)
		if err != nil || !accepted {
			response.RespondAppError(c, appErrors.ErrAttestationRequired())
			c.Abort()
			return
		}

		c.Next()
	}
}
