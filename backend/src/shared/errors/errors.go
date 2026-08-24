package errors

import "errors"

// Sentinel errors mapped to the contract's error codes.
var (
	ErrNotFound            = errors.New("not_found")
	ErrValidation          = errors.New("validation_error")
	ErrUnauthorized        = errors.New("unauthorized")
	ErrForbiddenRole       = errors.New("forbidden_role")
	ErrInvalidEmail        = errors.New("invalid_email")
	ErrInvalidPassword     = errors.New("invalid_password")
	ErrInvalidCredentials  = errors.New("invalid_credentials")
	ErrAttestationRequired = errors.New("attestation_required")
	ErrInvalidToken        = errors.New("invalid_token")
)
