package auth

import (
	"context"
	"errors"
	"net/mail"
	"strings"
	"time"

	"afyamind-backend/src/config"
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/token"
	"afyamind-backend/src/users"

	"golang.org/x/crypto/bcrypt"
)

type Service interface {
	Signup(ctx context.Context, req SignupRequest) (*users.User, string, string, *appErrors.AppError)
	Login(ctx context.Context, req LoginRequest) (*users.User, string, string, *appErrors.AppError)
	Refresh(ctx context.Context, refreshToken string) (*users.User, string, *appErrors.AppError)
}

type service struct {
	repo Repository
	cfg  *config.Config
}

func NewService(repo Repository, cfg *config.Config) Service {
	return &service{
		repo: repo,
		cfg:  cfg,
	}
}

func (s *service) Signup(ctx context.Context, req SignupRequest) (*users.User, string, string, *appErrors.AppError) {
	email := strings.ToLower(strings.TrimSpace(req.Email))
	name := strings.TrimSpace(req.Name)
	password := req.Password

	// 1. Email format validation
	if _, err := mail.ParseAddress(email); err != nil || !strings.Contains(email, ".") {
		return nil, "", "", appErrors.ErrInvalidEmail("Invalid email format")
	}

	// 2. Password complexity validation
	if len(password) < 8 {
		return nil, "", "", appErrors.ErrInvalidPassword("Password must be at least 8 characters long")
	}

	// 3. Name validation
	if name == "" {
		return nil, "", "", appErrors.ErrValidationError("Name field is required")
	}

	// 4. Existing user check
	existingUser, err := s.repo.FindByEmail(ctx, email)
	if err == nil && existingUser != nil {
		return nil, "", "", appErrors.ErrValidationError("Email is already registered")
	}

	// 5. Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, "", "", appErrors.ErrInternal("Failed to hash password")
	}

	// 6. Age attestation validation
	if !req.AgeAttested18 {
		return nil, "", "", appErrors.ErrValidationError("Age attestation (18+) is required to sign up")
	}

	now := time.Now()

	// 7. Construct user entity (Public signup always creates a PERSON)
	newUser := &users.User{
		Email:                email,
		Name:                 name,
		PasswordHash:         string(hashedPassword),
		Role:                 users.RolePerson,
		AgeAttested18:        true,
		DisclaimerAcceptedAt: &now,
	}

	// 7. Save user to DB
	if err := s.repo.Create(ctx, newUser); err != nil {
		return nil, "", "", appErrors.ErrInternal("Failed to create user account")
	}

	// 8. Mint access and refresh tokens
	accessTokenDuration := time.Duration(s.cfg.AccessTokenExpiryMinutes) * time.Minute
	refreshTokenDuration := time.Duration(s.cfg.RefreshTokenExpiryDays) * 24 * time.Hour

	accessToken, err := token.GenerateToken(newUser.ID, string(newUser.Role), token.TokenTypeAccess, accessTokenDuration, s.cfg.JWTSecret)
	if err != nil {
		return nil, "", "", appErrors.ErrInternal("Failed to generate access token")
	}

	refreshToken, err := token.GenerateToken(newUser.ID, string(newUser.Role), token.TokenTypeRefresh, refreshTokenDuration, s.cfg.JWTSecret)
	if err != nil {
		return nil, "", "", appErrors.ErrInternal("Failed to generate refresh token")
	}

	return newUser, accessToken, refreshToken, nil
}

func (s *service) Login(ctx context.Context, req LoginRequest) (*users.User, string, string, *appErrors.AppError) {
	email := strings.ToLower(strings.TrimSpace(req.Email))
	password := req.Password

	if email == "" || password == "" {
		return nil, "", "", appErrors.ErrInvalidCredentials()
	}

	user, err := s.repo.FindByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, users.ErrUserNotFound) {
			return nil, "", "", appErrors.ErrInvalidCredentials()
		}
		return nil, "", "", appErrors.ErrInternal("Database query failed")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
		return nil, "", "", appErrors.ErrInvalidCredentials()
	}

	accessTokenDuration := time.Duration(s.cfg.AccessTokenExpiryMinutes) * time.Minute
	refreshTokenDuration := time.Duration(s.cfg.RefreshTokenExpiryDays) * 24 * time.Hour

	accessToken, err := token.GenerateToken(user.ID, string(user.Role), token.TokenTypeAccess, accessTokenDuration, s.cfg.JWTSecret)
	if err != nil {
		return nil, "", "", appErrors.ErrInternal("Failed to generate access token")
	}

	refreshToken, err := token.GenerateToken(user.ID, string(user.Role), token.TokenTypeRefresh, refreshTokenDuration, s.cfg.JWTSecret)
	if err != nil {
		return nil, "", "", appErrors.ErrInternal("Failed to generate refresh token")
	}

	return user, accessToken, refreshToken, nil
}

func (s *service) Refresh(ctx context.Context, refreshTokenStr string) (*users.User, string, *appErrors.AppError) {
	if refreshTokenStr == "" {
		return nil, "", appErrors.ErrUnauthorized()
	}

	claims, err := token.ParseToken(refreshTokenStr, s.cfg.JWTSecret)
	if err != nil || claims.TokenType != token.TokenTypeRefresh {
		return nil, "", appErrors.ErrUnauthorized()
	}

	user, err := s.repo.FindByID(ctx, claims.UserID)
	if err != nil {
		if errors.Is(err, users.ErrUserNotFound) {
			return nil, "", appErrors.ErrUnauthorized()
		}
		return nil, "", appErrors.ErrInternal("Failed to lookup user")
	}

	accessTokenDuration := time.Duration(s.cfg.AccessTokenExpiryMinutes) * time.Minute
	newAccessToken, err := token.GenerateToken(user.ID, string(user.Role), token.TokenTypeAccess, accessTokenDuration, s.cfg.JWTSecret)
	if err != nil {
		return nil, "", appErrors.ErrInternal("Failed to generate access token")
	}

	return user, newAccessToken, nil
}
