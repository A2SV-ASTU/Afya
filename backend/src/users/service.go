package users

import (
	"context"
	"errors"

	appErrors "afyamind-backend/src/shared/errors"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type Service interface {
	GetProfile(ctx context.Context, userID uuid.UUID) (*UserResponse, *appErrors.AppError)
	UpdateProfile(ctx context.Context, userID uuid.UUID, req UpdateProfileRequest) (*UserResponse, *appErrors.AppError)
	ChangePassword(ctx context.Context, userID uuid.UUID, req ChangePasswordRequest) *appErrors.AppError
	DeleteAccount(ctx context.Context, userID uuid.UUID) *appErrors.AppError
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) GetProfile(ctx context.Context, userID uuid.UUID) (*UserResponse, *appErrors.AppError) {
	user, err := s.repo.FindByID(ctx, userID)
	if err != nil {
		if errors.Is(err, ErrUserNotFound) {
			return nil, appErrors.ErrNotFound("User")
		}
		return nil, appErrors.ErrInternal("Failed to retrieve user profile")
	}
	return ToUserResponse(user), nil
}

func (s *service) UpdateProfile(ctx context.Context, userID uuid.UUID, req UpdateProfileRequest) (*UserResponse, *appErrors.AppError) {
	user, err := s.repo.UpdateProfile(ctx, userID, req)
	if err != nil {
		if errors.Is(err, ErrUserNotFound) {
			return nil, appErrors.ErrNotFound("User")
		}
		return nil, appErrors.ErrInternal("Failed to update user profile")
	}

	return ToUserResponse(user), nil
}

func (s *service) ChangePassword(ctx context.Context, userID uuid.UUID, req ChangePasswordRequest) *appErrors.AppError {
	currentPassword := req.CurrentPassword
	newPassword := req.NewPassword

	if currentPassword == "" || newPassword == "" {
		return appErrors.ErrValidationError("Both current_password and new_password are required")
	}

	if len(newPassword) < 8 {
		return appErrors.ErrValidationError("New password must be at least 8 characters long")
	}

	user, err := s.repo.FindByID(ctx, userID)
	if err != nil {
		if errors.Is(err, ErrUserNotFound) {
			return appErrors.ErrNotFound("User")
		}
		return appErrors.ErrInternal("Failed to lookup user")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(currentPassword)); err != nil {
		return appErrors.ErrInvalidCredentials()
	}

	newHash, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return appErrors.ErrInternal("Failed to hash new password")
	}

	if err := s.repo.UpdatePassword(ctx, userID, string(newHash)); err != nil {
		return appErrors.ErrInternal("Failed to update password")
	}

	return nil
}

func (s *service) DeleteAccount(ctx context.Context, userID uuid.UUID) *appErrors.AppError {
	if err := s.repo.DeleteAccount(ctx, userID); err != nil {
		if errors.Is(err, ErrUserNotFound) {
			return appErrors.ErrNotFound("User")
		}
		return appErrors.ErrInternal("Failed to delete user account")
	}
	return nil
}
