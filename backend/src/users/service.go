package users

import (
	"context"
	"errors"
	"strings"

	appErrors "afyamind-backend/src/shared/errors"
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
	if req.Name == nil || strings.TrimSpace(*req.Name) == "" {
		return nil, appErrors.ErrValidationError("Name field is required and cannot be empty")
	}

	cleanName := strings.TrimSpace(*req.Name)
	user, err := s.repo.UpdateProfile(ctx, userID, cleanName)
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
