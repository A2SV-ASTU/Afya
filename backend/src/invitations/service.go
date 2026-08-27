package invitations

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"log"
	"net/mail"
	"os"
	"strconv"
	"strings"
	"time"

	"afyamind-backend/src/shared/email"
	appErrors "afyamind-backend/src/shared/errors"

	"golang.org/x/crypto/bcrypt"
)

type Service interface {
	CreateInvitation(ctx context.Context, req CreateInvitationRequest) *appErrors.AppError
	AcceptInvitation(ctx context.Context, req AcceptInvitationRequest) *appErrors.AppError
}

type service struct {
	repo        Repository
	emailSender *email.Sender
	frontendURL string
	expiryHours int
}

func NewService(repo Repository, emailSender *email.Sender) Service {
	frontendURL := os.Getenv("FRONTEND_URL")
	if frontendURL == "" {
		frontendURL = "http://localhost:3000"
	}

	expiryHours := 48
	if val := os.Getenv("INVITATION_EXPIRY_HOURS"); val != "" {
		if parsed, err := strconv.Atoi(val); err == nil && parsed > 0 {
			expiryHours = parsed
		}
	}

	return &service{
		repo:        repo,
		emailSender: emailSender,
		frontendURL: frontendURL,
		expiryHours: expiryHours,
	}
}

func (s *service) CreateInvitation(ctx context.Context, req CreateInvitationRequest) *appErrors.AppError {
	emailAddr := strings.ToLower(strings.TrimSpace(req.Email))

	// 1. Validate email format
	if _, err := mail.ParseAddress(emailAddr); err != nil || !strings.Contains(emailAddr, ".") {
		return appErrors.ErrInvalidEmail("Invalid email format")
	}

	// 2. Check if user already exists
	userID, exists, err := s.repo.FindUserByEmail(ctx, emailAddr)
	if err != nil {
		return appErrors.ErrInternal("Failed to check existing user")
	}

	if exists {
		// Check if there's a pending invitation — if so, reissue
		_, pendingErr := s.repo.FindPendingInvitationByUserID(ctx, userID)
		if pendingErr == nil {
			// Pending invitation exists — reissue a new token
			return s.issueInvitation(ctx, userID, emailAddr)
		}
		if !errors.Is(pendingErr, ErrInvitationNotFound) {
			return appErrors.ErrInternal("Failed to check pending invitations")
		}
		// No pending invitation — user is already active or invitation was used
		return appErrors.ErrValidationError("A user with this email already exists")
	}

	// 3. Create user with INVITED status and a random placeholder password
	// We generate a secure random string so the password is mathematically unguessable.
	randomPassword, err := generateSecureToken(32)
	if err != nil {
		return appErrors.ErrInternal("Failed to generate random password")
	}

	placeholderHash, err := bcrypt.GenerateFromPassword([]byte(randomPassword), bcrypt.DefaultCost)
	if err != nil {
		return appErrors.ErrInternal("Failed to generate placeholder password hash")
	}

	// Use email prefix as the name placeholder
	name := strings.Split(emailAddr, "@")[0]

	userID, err = s.repo.CreateInvitedUser(ctx, emailAddr, name, string(placeholderHash))
	if err != nil {
		return appErrors.ErrInternal("Failed to create invited user")
	}

	return s.issueInvitation(ctx, userID, emailAddr)
}

func (s *service) issueInvitation(ctx context.Context, userID int64, emailAddr string) *appErrors.AppError {
	// 1. Generate cryptographically random token
	rawToken, err := generateSecureToken(32)
	if err != nil {
		return appErrors.ErrInternal("Failed to generate invitation token")
	}

	// 2. Hash the token for storage
	tokenHash := hashToken(rawToken)

	// 3. Create the invitation record
	inv := &AdminInvitation{
		UserID:    userID,
		TokenHash: tokenHash,
		ExpiresAt: time.Now().Add(time.Duration(s.expiryHours) * time.Hour),
	}

	if err := s.repo.CreateInvitation(ctx, inv); err != nil {
		return appErrors.ErrInternal("Failed to create invitation record")
	}

	// 4. Send invite email with token only
	emailBody := buildInviteEmailBody(rawToken)

	if s.emailSender != nil {
		if err := s.emailSender.Send(emailAddr, "You've been invited to AfyaMind Admin", emailBody); err != nil {
			// Log the error but don't fail — the invitation is already created
			log.Printf("WARNING: Failed to send invitation email to %s: %v", emailAddr, err)
		}
	} else {
		log.Printf("WARNING: SMTP not configured — invitation email not sent. Token: %s", rawToken)
	}

	return nil
}

func (s *service) AcceptInvitation(ctx context.Context, req AcceptInvitationRequest) *appErrors.AppError {
	rawToken := strings.TrimSpace(req.Token)
	password := req.Password

	if rawToken == "" {
		return appErrors.NewAppError(400, "invitation_not_found", "Invitation token is required")
	}

	// 1. Validate password
	if len(password) < 8 {
		return appErrors.ErrInvalidPassword("Password must be at least 8 characters long")
	}

	// 2. Hash the incoming token and look up the invitation
	tokenHash := hashToken(rawToken)

	inv, err := s.repo.FindInvitationByTokenHash(ctx, tokenHash)
	if err != nil {
		if errors.Is(err, ErrInvitationNotFound) {
			return appErrors.NewAppError(404, "invitation_not_found", "Invitation not found")
		}
		return appErrors.ErrInternal("Failed to look up invitation")
	}

	// 3. Check if already used
	if inv.UsedAt != nil {
		return appErrors.NewAppError(400, "invitation_already_used", "This invitation has already been used")
	}

	// 4. Check if expired
	if time.Now().After(inv.ExpiresAt) {
		return appErrors.NewAppError(400, "invitation_expired", "This invitation has expired")
	}

	// 5. Hash the new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return appErrors.ErrInternal("Failed to hash password")
	}

	// 6. Activate the user
	if err := s.repo.ActivateUser(ctx, inv.UserID, string(hashedPassword)); err != nil {
		return appErrors.ErrInternal("Failed to activate user account")
	}

	// 7. Mark invitation as used
	if err := s.repo.MarkInvitationUsed(ctx, inv.ID); err != nil {
		return appErrors.ErrInternal("Failed to mark invitation as used")
	}

	return nil
}

// generateSecureToken generates a cryptographically random hex-encoded token
func generateSecureToken(byteLength int) (string, error) {
	b := make([]byte, byteLength)
	if _, err := rand.Read(b); err != nil {
		return "", fmt.Errorf("failed to generate random bytes: %w", err)
	}
	return hex.EncodeToString(b), nil
}

// hashToken returns the SHA-256 hex digest of the given token
func hashToken(token string) string {
	h := sha256.Sum256([]byte(token))
	return hex.EncodeToString(h[:])
}

// buildInviteEmailBody returns a simple HTML email body with just the invitation token
func buildInviteEmailBody(token string) string {
	return fmt.Sprintf(`<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
  <h2 style="color: #2563eb;">You've been invited to AfyaMind Admin</h2>
  <p>You have been invited to join AfyaMind as an administrator.</p>
  <p>Use the following invitation token to activate your account:</p>
  <p style="text-align: center; margin: 30px 0;">
    <code style="background-color: #f3f4f6; color: #1f2937; padding: 12px 20px; border-radius: 6px; font-size: 14px; word-break: break-all; display: inline-block; border: 1px solid #d1d5db;">%s</code>
  </p>
  <p style="color: #6b7280; font-size: 14px;">
    This invitation expires in 48 hours. If you did not expect this email, you can safely ignore it.
  </p>
</body>
</html>`, token)
}
