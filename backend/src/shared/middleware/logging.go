package middleware

import (
	"log"
	"time"

	"github.com/gin-gonic/gin"
)

// Logging middleware logs basic request metadata (HTTP method, path, status, latency)
func Logging() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path
		rawQuery := c.Request.URL.RawQuery

		c.Next()

		latency := time.Since(start)
		statusCode := c.Writer.Status()
		clientIP := c.ClientIP()
		method := c.Request.Method

		if rawQuery != "" {
			path = path + "?" + rawQuery
		}

		log.Printf("[HTTP] %d | %13v | %s | %s %s",
			statusCode,
			latency,
			clientIP,
			method,
			path,
		)
	}
}
