package errors

import (
	"fmt"
	"net/http"
)

type AppError struct {
	StatusCode int    `json:"-"`
	Code       string `json:"code"`
	Message    string `json:"message"`
}

func (e *AppError) Error() string {
	return fmt.Sprintf("[%s] %s", e.Code, e.Message)
}

func NewAppError(statusCode int, code string, message string) *AppError {
	return &AppError{
		StatusCode: statusCode,
		Code:       code,
		Message:    message,
	}
}

// Sentinel AppErrors according to AfyaMind API Contract

func ErrValidationError(msg string) *AppError {
	if msg == "" {
		msg = "Validation failed"
	}
	return NewAppError(http.StatusBadRequest, "validation_error", msg)
}

func ErrInvalidEmail(msg string) *AppError {
	if msg == "" {
		msg = "Invalid email format"
	}
	return NewAppError(http.StatusBadRequest, "validation_error", msg)
}

func ErrInvalidPassword(msg string) *AppError {
	if msg == "" {
		msg = "Password does not meet requirements"
	}
	return NewAppError(http.StatusBadRequest, "validation_error", msg)
}

func ErrInvalidCredentials() *AppError {
	return NewAppError(http.StatusUnauthorized, "unauthenticated", "Invalid credentials")
}

func ErrUnauthorized() *AppError {
	return NewAppError(http.StatusUnauthorized, "unauthenticated", "Authentication required")
}

func ErrUnauthenticated() *AppError {
	return NewAppError(http.StatusUnauthorized, "unauthenticated", "Authentication required")
}

func ErrForbiddenRole() *AppError {
	return NewAppError(http.StatusForbidden, "forbidden_role", "Access forbidden for this account role")
}

func ErrForbiddenGrant() *AppError {
	return NewAppError(http.StatusForbidden, "forbidden_grant", "Clinic has no active access grant for this patient")
}

func ErrNotFound(resource string) *AppError {
	msg := "Resource not found"
	if resource != "" {
		msg = fmt.Sprintf("%s not found", resource)
	}
	return NewAppError(http.StatusNotFound, "not_found", msg)
}

func ErrConflict(msg string) *AppError {
	if msg == "" {
		msg = "Resource conflict occurred"
	}
	return NewAppError(http.StatusConflict, "conflict", msg)
}

func ErrExpired(msg string) *AppError {
	if msg == "" {
		msg = "Resource or invitation has expired"
	}
	return NewAppError(http.StatusGone, "expired", msg)
}

func ErrEmailNotVerified() *AppError {
	return NewAppError(http.StatusForbidden, "email_not_verified", "Please verify your email address before logging in")
}

func ErrInvalidOTP(msg string) *AppError {
	if msg == "" {
		msg = "Invalid or expired verification code"
	}
	return NewAppError(http.StatusBadRequest, "invalid_otp", msg)
}

func ErrInternal(msg string) *AppError {
	if msg == "" {
		msg = "An internal server error occurred"
	}
	return NewAppError(http.StatusInternalServerError, "internal_error", msg)
}

