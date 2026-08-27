package middleware

import (
	"log"

	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
)

// Recovery middleware recovers from panics and returns a standardized 500 error response
func Recovery() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if err := recover(); err != nil {
				log.Printf("[PANIC RECOVERY] panic recovered: %v", err)
				response.RespondAppError(c, appErrors.ErrInternal("Internal server error"))
				c.Abort()
			}
		}()
		c.Next()
	}
}
