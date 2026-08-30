package response

import (
	"net/http"

	appErrors "afyamind-backend/src/shared/errors"
	"github.com/gin-gonic/gin"
)

type ErrorEnvelope struct {
	Error ErrorBody `json:"error"`
}

type ErrorBody struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

// Error sends a standardized error response: { "error": { "code": "...", "message": "..." } }
func Error(c *gin.Context, statusCode int, code string, message string) {
	c.JSON(statusCode, ErrorEnvelope{
		Error: ErrorBody{
			Code:    code,
			Message: message,
		},
	})
}

// AppError handles sending an AppError to the Gin context
func RespondAppError(c *gin.Context, err *appErrors.AppError) {
	if err == nil {
		return
	}
	Error(c, err.StatusCode, err.Code, err.Message)
}

func SendError(c *gin.Context, err error) {
	if appErr, ok := err.(*appErrors.AppError); ok {
		RespondAppError(c, appErr)
		return
	}
	Error(c, http.StatusInternalServerError, "internal_error", err.Error())
}

// JSON sends a standard JSON payload
func JSON(c *gin.Context, statusCode int, data any) {
	c.JSON(statusCode, data)
}

// List sends a list response wrapped in a key: { "<pluralName>": [...] }
func List(c *gin.Context, statusCode int, pluralName string, items any) {
	if items == nil {
		items = []any{}
	}
	c.JSON(statusCode, gin.H{
		pluralName: items,
	})
}

// NoContent sends HTTP 204 No Content
func NoContent(c *gin.Context) {
	c.Status(http.StatusNoContent)
}
