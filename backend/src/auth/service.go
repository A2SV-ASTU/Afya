package auth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"log"
	"math/big"
	"net/mail"
	"strings"
	"time"

	"afyamind-backend/src/config"
	"afyamind-backend/src/shared/email"
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/token"
	"afyamind-backend/src/users"

	"golang.org/x/crypto/bcrypt"
)

type Service interface {
	Signup(ctx context.Context, req SignupRequest) (*users.User, *appErrors.AppError)
	VerifyEmail(ctx context.Context, req VerifyEmailRequest) (*users.User, string, string, *appErrors.AppError)
	ResendOTP(ctx context.Context, req ResendOTPRequest) *appErrors.AppError
	Login(ctx context.Context, req LoginRequest) (*users.User, string, string, *appErrors.AppError)
	Refresh(ctx context.Context, refreshToken string) (*users.User, string, *appErrors.AppError)
	ForgotPassword(ctx context.Context, emailAddress string) *appErrors.AppError
	ResetPassword(ctx context.Context, tokenRaw, newPassword string) *appErrors.AppError
}

type service struct {
	repo   Repository
	cfg    *config.Config
	sender email.EmailSender
}

func NewService(repo Repository, cfg *config.Config, sender email.EmailSender) Service {
	return &service{
		repo:   repo,
		cfg:    cfg,
		sender: sender,
	}
}

func generateOTP() (string, string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(900000))
	if err != nil {
		return "", "", err
	}
	code := fmt.Sprintf("%06d", 100000+n.Int64())
	hash := sha256.Sum256([]byte(code))
	return code, hex.EncodeToString(hash[:]), nil
}

func (s *service) Signup(ctx context.Context, req SignupRequest) (*users.User, *appErrors.AppError) {
	firstName := strings.TrimSpace(req.FirstName)
	lastName := strings.TrimSpace(req.LastName)
	email := strings.ToLower(strings.TrimSpace(req.Email))
	phone := strings.TrimSpace(req.Phone)
	password := req.Password

	// 1. Required field validations
	if firstName == "" || lastName == "" {
		return nil, appErrors.ErrValidationError("First name and last name are required")
	}
	if phone == "" {
		return nil, appErrors.ErrValidationError("Phone number is required")
	}

	// 2. Email format validation
	if _, err := mail.ParseAddress(email); err != nil || !strings.Contains(email, ".") {
		return nil, appErrors.ErrValidationError("Invalid email format")
	}

	// 3. Password complexity validation
	if len(password) < 8 {
		return nil, appErrors.ErrValidationError("Password must be at least 8 characters long")
	}

	// 4. Pre-check for duplicate email or phone (soft check)
	existingEmailUser, err := s.repo.FindByEmail(ctx, email)
	if err == nil && existingEmailUser != nil {
		return nil, appErrors.ErrConflict("Email is already registered")
	}

	existingPhoneUser, err := s.repo.FindByPhone(ctx, phone)
	if err == nil && existingPhoneUser != nil {
		return nil, appErrors.ErrConflict("Phone number is already registered")
	}

	// 5. Check that email service is configured before creating account
	if s.sender == nil {
		log.Printf("ERROR: Cannot complete signup for %s — SMTP email service is not configured", email)
		return nil, appErrors.ErrInternal("Email verification service is temporarily unavailable. Please contact support.")
	}

	// 6. Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, appErrors.ErrInternal("Failed to hash password")
	}

	// 7. Optional DOB parsing
	var dobPtr *time.Time
	if req.DateOfBirth != nil && *req.DateOfBirth != "" {
		parsedDOB, err := time.Parse("2006-01-02", *req.DateOfBirth)
		if err != nil {
			return nil, appErrors.ErrValidationError("Invalid date_of_birth format (expected YYYY-MM-DD)")
		}
		dobPtr = &parsedDOB
	}

	var sexPtr *string
	if req.Sex != nil && *req.Sex != "" {
		sexLower := strings.ToLower(strings.TrimSpace(*req.Sex))
		sexPtr = &sexLower
	}

	// 8. Construct user entity (Public signup ALWAYS forces role = patient and is_email_verified = false)
	newUser := &users.User{
		FirstName:       firstName,
		LastName:        lastName,
		Email:           email,
		Phone:           phone,
		PasswordHash:    string(hashedPassword),
		Role:            users.RolePatient,
		DateOfBirth:     dobPtr,
		Sex:             sexPtr,
		IsEmailVerified: false,
	}

	// 9. Save user to DB (handles race condition via unique constraint mapping)
	if err := s.repo.Create(ctx, newUser); err != nil {
		if errors.Is(err, users.ErrDuplicateEmail) {
			return nil, appErrors.ErrConflict("Email is already registered")
		}
		if errors.Is(err, users.ErrDuplicatePhone) {
			return nil, appErrors.ErrConflict("Phone number is already registered")
		}
		if errors.Is(err, users.ErrUserConflict) {
			return nil, appErrors.ErrConflict("Email or phone is already registered")
		}
		return nil, appErrors.ErrInternal("Failed to create user account")
	}

	// 10. Generate 6-digit OTP & save verification record
	rawOTP, otpHash, err := generateOTP()
	if err != nil {
		return nil, appErrors.ErrInternal("Failed to generate verification code")
	}

	expiresAt := time.Now().Add(10 * time.Minute)
	if err := s.repo.CreateEmailVerification(ctx, newUser.ID, email, otpHash, expiresAt); err != nil {
		return nil, appErrors.ErrInternal("Failed to save verification code")
	}

	// 11. Send verification email and handle delivery failure
	if err := s.sender.SendVerificationOTP(email, firstName, rawOTP); err != nil {
		log.Printf("ERROR: Failed to deliver verification OTP to %s: %v", email, err)
		return nil, appErrors.ErrInternal("Failed to send verification email. Please try again later.")
	}

	return newUser, nil
}


func (s *service) VerifyEmail(ctx context.Context, req VerifyEmailRequest) (*users.User, string, string, *appErrors.AppError) {
	emailStr := strings.ToLower(strings.TrimSpace(req.Email))
	otp := strings.TrimSpace(req.OTP)

	if emailStr == "" || len(otp) != 6 {
		return nil, "", "", appErrors.ErrValidationError("Valid email and 6-digit verification code are required")
	}

	ver, err := s.repo.FindEmailVerificationByEmail(ctx, emailStr)
	if err != nil {
		return nil, "", "", appErrors.ErrInvalidOTP("Invalid or expired verification code")
	}

	if time.Now().After(ver.ExpiresAt) {
		return nil, "", "", appErrors.ErrInvalidOTP("Verification code has expired. Please request a new one.")
	}

	if ver.Attempts >= 5 {
		return nil, "", "", appErrors.ErrInvalidOTP("Too many failed attempts. Please request a new verification code.")
	}

	inputHash := sha256.Sum256([]byte(otp))
	inputHashStr := hex.EncodeToString(inputHash[:])
	if inputHashStr != ver.OTPHash {
		_ = s.repo.IncrementVerificationAttempts(ctx, ver.ID)
		return nil, "", "", appErrors.ErrInvalidOTP("Invalid verification code")
	}

	if err := s.repo.MarkEmailVerified(ctx, ver.UserID); err != nil {
		return nil, "", "", appErrors.ErrInternal("Failed to mark email verified")
	}

	_ = s.repo.DeleteEmailVerification(ctx, ver.ID)

	user, err := s.repo.FindByID(ctx, ver.UserID)
	if err != nil {
		return nil, "", "", appErrors.ErrInternal("Failed to lookup user")
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

func (s *service) ResendOTP(ctx context.Context, req ResendOTPRequest) *appErrors.AppError {
	emailStr := strings.ToLower(strings.TrimSpace(req.Email))
	if emailStr == "" {
		return appErrors.ErrValidationError("Email is required")
	}

	user, err := s.repo.FindByEmail(ctx, emailStr)
	if err != nil || user == nil {
		return appErrors.ErrNotFound("User")
	}

	if user.IsEmailVerified {
		return appErrors.ErrConflict("Email is already verified")
	}

	ver, err := s.repo.FindEmailVerificationByEmail(ctx, emailStr)
	if err == nil && ver != nil {
		if time.Since(ver.CreatedAt) < 60*time.Second {
			return appErrors.ErrConflict("Please wait 60 seconds before requesting another code")
		}
	}

	if s.sender == nil {
		log.Printf("ERROR: Cannot resend verification OTP to %s — SMTP email service is not configured", emailStr)
		return appErrors.ErrInternal("Email verification service is temporarily unavailable. Please contact support.")
	}

	rawOTP, otpHash, err := generateOTP()
	if err != nil {
		return appErrors.ErrInternal("Failed to generate verification code")
	}

	expiresAt := time.Now().Add(10 * time.Minute)
	if err := s.repo.CreateEmailVerification(ctx, user.ID, emailStr, otpHash, expiresAt); err != nil {
		return appErrors.ErrInternal("Failed to save verification code")
	}

	if err := s.sender.SendVerificationOTP(emailStr, user.FirstName, rawOTP); err != nil {
		log.Printf("ERROR: Failed to deliver verification OTP to %s: %v", emailStr, err)
		return appErrors.ErrInternal("Failed to send verification email. Please try again later.")
	}

	return nil
}


func (s *service) Login(ctx context.Context, req LoginRequest) (*users.User, string, string, *appErrors.AppError) {
	loginStr := strings.TrimSpace(req.Email)
	if loginStr == "" {
		loginStr = strings.TrimSpace(req.Phone)
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

	// Enforce email verification for self-registered patients
	if user.Role == users.RolePatient && !user.IsEmailVerified {
		return nil, "", "", appErrors.ErrEmailNotVerified()
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

func generateResetToken() (string, string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", "", err
	}
	raw := hex.EncodeToString(b)
	hash := sha256.Sum256([]byte(raw))
	return raw, hex.EncodeToString(hash[:]), nil
}

func (s *service) ForgotPassword(ctx context.Context, emailAddress string) *appErrors.AppError {
	emailStr := strings.ToLower(strings.TrimSpace(emailAddress))
	user, err := s.repo.FindByEmail(ctx, emailStr)
	if err != nil {
		return nil // Do not leak existence
	}

	rawToken, hashToken, err := generateResetToken()
	if err != nil {
		return appErrors.ErrInternal("Failed to generate reset token")
	}

	expiresAt := time.Now().Add(1 * time.Hour)
	if err := s.repo.CreatePasswordReset(ctx, user.ID, hashToken, expiresAt); err != nil {
		return appErrors.ErrInternal("Failed to save reset token")
	}

	if s.sender != nil {
		resetURL := fmt.Sprintf("%s/api/v1/magic/reset-password?token=%s", s.cfg.APIBaseURL, rawToken)

		subject := "Reset Your Afya Password"
		body := fmt.Sprintf(`<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f0fdf4; margin: 0; padding: 40px 0; }
        .container { max-width: 550px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 25px rgba(34, 197, 94, 0.1); border: 1px solid #dcfce7; }
        .header { padding: 40px 30px; text-align: center; background-color: #22c55e; color: #ffffff; }
        .header h1 { margin: 0; font-size: 28px; font-weight: 700; letter-spacing: 0.5px; }
        .content { padding: 40px 30px; color: #374151; line-height: 1.8; font-size: 16px; }
        .btn-group { text-align: center; margin: 30px 0; }
        .btn { display: inline-block; padding: 14px 48px; border-radius: 8px; text-decoration: none; font-weight: 700; font-size: 16px; background-color: #22c55e; color: #ffffff !important; }
        .footer { padding: 25px; text-align: center; font-size: 13px; color: #9ca3af; background-color: #f9fafb; border-top: 1px solid #f3f4f6; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Password Reset Request</h1>
        </div>
        <div class="content">
            <p>Hello %s,</p>
            <p>We received a request to reset the password for your Afya account.</p>
            <p>Click the button below to set a new password:</p>
            <div class="btn-group">
                <a href="%s" class="btn">Reset Password</a>
            </div>
            <p><strong>Note:</strong> This link will expire in 1 hour. If you did not request a password reset, you can safely ignore this email.</p>
        </div>
        <div class="footer">
            <p>&copy; 2026 Afya. All rights reserved.</p>
        </div>
    </div>
</body>
</html>`, user.FirstName, resetURL)

		go func(e, sub, b string) {
			_ = s.sender.Send(e, sub, b)
		}(user.Email, subject, body)
	}

	return nil
}

func (s *service) ResetPassword(ctx context.Context, tokenRaw, newPassword string) *appErrors.AppError {
	hash := sha256.Sum256([]byte(tokenRaw))
	tokenHashStr := hex.EncodeToString(hash[:])

	id, userID, isUsed, err := s.repo.FindPasswordResetByTokenHash(ctx, tokenHashStr)
	if err != nil {
		return appErrors.ErrValidationError("Invalid or expired reset token")
	}
	if isUsed {
		return appErrors.ErrValidationError("This reset token has already been used")
	}

	if len(newPassword) < 8 {
		return appErrors.ErrValidationError("Password must be at least 8 characters long")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return appErrors.ErrInternal("Failed to hash new password")
	}

	if err := s.repo.UpdateUserPassword(ctx, userID, string(hashedPassword)); err != nil {
		return appErrors.ErrInternal("Failed to update password")
	}

	_ = s.repo.MarkPasswordResetUsed(ctx, id)

	return nil
}
