package users

import (
	"context"
	"errors"
	"strings"

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
	if req.Email != nil && *req.Email != "" {
		cleanEmail := strings.ToLower(strings.TrimSpace(*req.Email))
		existingUser, err := s.repo.FindByEmail(ctx, cleanEmail)
		if err == nil && existingUser != nil && existingUser.ID != userID {
			return nil, appErrors.ErrConflict("Email is already registered by another account")
		}
		req.Email = &cleanEmail
	}

	if req.Phone != nil && *req.Phone != "" {
		cleanPhone := strings.TrimSpace(*req.Phone)
		existingUser, err := s.repo.FindByPhone(ctx, cleanPhone)
		if err == nil && existingUser != nil && existingUser.ID != userID {
			return nil, appErrors.ErrConflict("Phone number is already registered by another account")
		}
		req.Phone = &cleanPhone
	}

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
	user, err := s.repo.FindByID(ctx, userID)
	if err != nil {
		if errors.Is(err, ErrUserNotFound) {
			return appErrors.ErrNotFound("User")
		}
		return appErrors.ErrInternal("Failed to lookup user")
	}

	if user.Role == RoleSuperAdmin {
		return appErrors.ErrForbiddenRole()
	}

	if err := s.repo.DeleteAccount(ctx, userID); err != nil {
		return appErrors.ErrInternal("Failed to delete user account")
	}
	return nil
}
