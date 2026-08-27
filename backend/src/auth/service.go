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
	firstName := strings.TrimSpace(req.FirstName)
	lastName := strings.TrimSpace(req.LastName)
	email := strings.ToLower(strings.TrimSpace(req.Email))
	phone := strings.TrimSpace(req.Phone)
	password := req.Password

	// 1. Required field validations
	if firstName == "" || lastName == "" {
		return nil, "", "", appErrors.ErrValidationError("First name and last name are required")
	}
	if phone == "" {
		return nil, "", "", appErrors.ErrValidationError("Phone number is required")
	}

	// 2. Email format validation
	if _, err := mail.ParseAddress(email); err != nil || !strings.Contains(email, ".") {
		return nil, "", "", appErrors.ErrValidationError("Invalid email format")
	}

	// 3. Password complexity validation
	if len(password) < 8 {
		return nil, "", "", appErrors.ErrValidationError("Password must be at least 8 characters long")
	}

	// 4. Duplicate checks
	existingEmailUser, err := s.repo.FindByEmail(ctx, email)
	if err == nil && existingEmailUser != nil {
		return nil, "", "", appErrors.ErrConflict("Email is already registered")
	}

	existingPhoneUser, err := s.repo.FindByPhone(ctx, phone)
	if err == nil && existingPhoneUser != nil {
		return nil, "", "", appErrors.ErrConflict("Phone number is already registered")
	}

	// 5. Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, "", "", appErrors.ErrInternal("Failed to hash password")
	}

	// 6. Optional DOB parsing
	var dobPtr *time.Time
	if req.DateOfBirth != nil && *req.DateOfBirth != "" {
		parsedDOB, err := time.Parse("2006-01-02", *req.DateOfBirth)
		if err != nil {
			return nil, "", "", appErrors.ErrValidationError("Invalid date_of_birth format (expected YYYY-MM-DD)")
		}
		dobPtr = &parsedDOB
	}

	var sexPtr *string
	if req.Sex != nil && *req.Sex != "" {
		sexLower := strings.ToLower(strings.TrimSpace(*req.Sex))
		sexPtr = &sexLower
	}

	// 7. Construct user entity (Public signup ALWAYS forces role = patient)
	newUser := &users.User{
		FirstName:    firstName,
		LastName:     lastName,
		Email:        email,
		Phone:        phone,
		PasswordHash: string(hashedPassword),
		Role:         users.RolePatient,
		DateOfBirth:  dobPtr,
		Sex:          sexPtr,
	}

	// 8. Save user to DB
	if err := s.repo.Create(ctx, newUser); err != nil {
		return nil, "", "", appErrors.ErrInternal("Failed to create user account")
	}

	// 9. Mint access and refresh tokens
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
	loginStr := strings.TrimSpace(req.Login)
	if loginStr == "" {
		if req.Email != "" {
			loginStr = strings.TrimSpace(req.Email)
		} else if req.Phone != "" {
			loginStr = strings.TrimSpace(req.Phone)
		}
	}
	loginStr = strings.ToLower(loginStr)
	password := req.Password

	if loginStr == "" || password == "" {
		return nil, "", "", appErrors.ErrInvalidCredentials()
	}

	user, err := s.repo.FindByLogin(ctx, loginStr)
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
		return nil, "", appErrors.ErrUnauthenticated()
	}

	claims, err := token.ParseToken(refreshTokenStr, s.cfg.JWTSecret)
	if err != nil || claims.TokenType != token.TokenTypeRefresh {
		return nil, "", appErrors.ErrUnauthenticated()
	}

	user, err := s.repo.FindByID(ctx, claims.UserID)
	if err != nil {
		if errors.Is(err, users.ErrUserNotFound) {
			return nil, "", appErrors.ErrUnauthenticated()
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
