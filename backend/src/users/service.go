package users

import (
	"context"
	"errors"
	"net/mail"
	"strings"

	appErrors "afyamind-backend/src/shared/errors"

	"golang.org/x/crypto/bcrypt"
)

type Service interface {
	GetProfile(ctx context.Context, userID int64) (*UserResponse, *appErrors.AppError)
	UpdateProfile(ctx context.Context, userID int64, req UpdateProfileRequest) (*UserResponse, *appErrors.AppError)
	AcceptDisclaimer(ctx context.Context, userID int64, req DisclaimerRequest) (*UserResponse, *appErrors.AppError)
	IsDisclaimerAccepted(ctx context.Context, userID int64) (bool, error)
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) GetProfile(ctx context.Context, userID int64) (*UserResponse, *appErrors.AppError) {
	user, err := s.repo.FindByID(ctx, userID)
	if err != nil {
		if errors.Is(err, ErrUserNotFound) {
			return nil, appErrors.ErrNotFound("User")
		}
		return nil, appErrors.ErrInternal("Failed to retrieve user profile")
	}
	return ToUserResponse(user), nil
}

func (s *service) UpdateProfile(ctx context.Context, userID int64, req UpdateProfileRequest) (*UserResponse, *appErrors.AppError) {
	var cleanNamePtr *string
	var cleanEmailPtr *string
	var passwordHashPtr *string

	// 1. Name update validation
	if req.Name != nil {
		cleanName := strings.TrimSpace(*req.Name)
		if cleanName == "" {
			return nil, appErrors.ErrValidationError("Name cannot be empty")
		}
		cleanNamePtr = &cleanName
	}

	// 2. Email update validation
	if req.Email != nil {
		cleanEmail := strings.ToLower(strings.TrimSpace(*req.Email))
		if _, err := mail.ParseAddress(cleanEmail); err != nil || !strings.Contains(cleanEmail, ".") {
			return nil, appErrors.ErrInvalidEmail("Invalid email format")
		}

		existingUser, err := s.repo.FindByEmail(ctx, cleanEmail)
		if err == nil && existingUser != nil && existingUser.ID != userID {
			return nil, appErrors.ErrValidationError("Email is already registered by another account")
		}
		cleanEmailPtr = &cleanEmail
	}

	// 3. Password update validation
	if req.Password != nil {
		password := *req.Password
		if len(password) < 8 {
			return nil, appErrors.ErrInvalidPassword("Password must be at least 8 characters long")
		}

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
		if err != nil {
			return nil, appErrors.ErrInternal("Failed to hash new password")
		}
		hashStr := string(hashedPassword)
		passwordHashPtr = &hashStr
	}

	// At least one field should be provided
	if cleanNamePtr == nil && cleanEmailPtr == nil && passwordHashPtr == nil {
		return nil, appErrors.ErrValidationError("At least one field (name, email, or password) must be provided for update")
	}

	user, err := s.repo.UpdateProfile(ctx, userID, cleanNamePtr, cleanEmailPtr, passwordHashPtr)
	if err != nil {
		if errors.Is(err, ErrUserNotFound) {
			return nil, appErrors.ErrNotFound("User")
		}
		return nil, appErrors.ErrInternal("Failed to update user profile")
	}

	return ToUserResponse(user), nil
}

func (s *service) AcceptDisclaimer(ctx context.Context, userID int64, req DisclaimerRequest) (*UserResponse, *appErrors.AppError) {
	if !req.AgeAttested18 {
		return nil, appErrors.ErrValidationError("Age attestation (18+) is required to accept disclaimer")
	}

	user, err := s.repo.AcceptDisclaimer(ctx, userID)
	if err != nil {
		if errors.Is(err, ErrUserNotFound) {
			return nil, appErrors.ErrNotFound("User")
		}
		return nil, appErrors.ErrInternal("Failed to accept disclaimer")
	}

	return ToUserResponse(user), nil
}

func (s *service) IsDisclaimerAccepted(ctx context.Context, userID int64) (bool, error) {
	user, err := s.repo.FindByID(ctx, userID)
	if err != nil {
		return false, err
	}
	return user.DisclaimerAcceptedAt != nil && user.AgeAttested18, nil
}
