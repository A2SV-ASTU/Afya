package invitations

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"log"
	"time"

	"afyamind-backend/src/database"
	"afyamind-backend/src/shared/email"
	"afyamind-backend/src/users"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type Service interface {
	CreateInvitation(ctx context.Context, clinicID, invitedBy uuid.UUID, req CreateInvitationRequest) error
	AcceptInvitation(ctx context.Context, tokenRaw string, req AcceptInvitationRequest) (*users.User, error)
	MarkExpired(ctx context.Context) (int64, error)
}

type service struct {
	db     *sql.DB
	repo   Repository
	sender *email.Sender
}

func NewService(db *sql.DB, repo Repository, sender *email.Sender) Service {
	return &service{
		db:     db,
		repo:   repo,
		sender: sender,
	}
}

func generateToken() (string, string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", "", err
	}
	raw := hex.EncodeToString(b)
	hash := sha256.Sum256([]byte(raw))
	return raw, hex.EncodeToString(hash[:]), nil
}

func (s *service) CreateInvitation(ctx context.Context, clinicID, invitedBy uuid.UUID, req CreateInvitationRequest) error {
	caller, err := users.NewRepository(s.db).FindByID(ctx, invitedBy)
	if err != nil {
		return err
	}
	if caller.Role == users.RoleClinicAdmin && (caller.ClinicID == nil || *caller.ClinicID != clinicID) {
		return errors.New("unauthorized to invite for this clinic")
	}

	rawToken, hashToken, err := generateToken()
	if err != nil {
		return fmt.Errorf("failed to generate token: %w", err)
	}

	inv := &DoctorInvitation{
		ClinicID:  clinicID,
		Email:     req.Email,
		TokenHash: hashToken,
		Status:    StatusPending,
		ExpiresAt: time.Now().Add(24 * time.Hour),
		InvitedBy: &invitedBy,
	}

	if err := s.repo.Create(ctx, inv); err != nil {
		return err
	}

	if s.sender != nil {
		// send email (best effort, or we could fail if it doesn't send)
		subject := "You are invited to join Afya as a Doctor"
		body := fmt.Sprintf(`<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f0fdf4; margin: 0; padding: 40px 0; }
        .container { max-width: 550px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 25px rgba(34, 197, 94, 0.1); border: 1px solid #dcfce7; }
        .header { padding: 40px 30px; text-align: center; background-color: #22c55e; color: #ffffff; }
        .header h1 { margin: 0; font-size: 28px; font-weight: 700; letter-spacing: 0.5px; }
        .header p { margin: 10px 0 0 0; font-size: 16px; opacity: 0.9; }
        .content { padding: 40px 30px; color: #374151; line-height: 1.8; font-size: 16px; }
        .token-box { background-color: #f0fdf4; border-left: 4px solid #22c55e; border-radius: 0 8px 8px 0; padding: 25px; margin: 30px 0; box-shadow: 0 2px 5px rgba(0,0,0,0.02); text-align: center; }
        .token-box span { font-family: monospace; font-size: 18px; letter-spacing: 1px; color: #047857; background: #e0f2fe; padding: 4px 10px; border-radius: 4px; word-break: break-all; font-weight: bold; }
        .alert { font-size: 14px; color: #991b1b; background-color: #fef2f2; padding: 12px; border-radius: 6px; margin-top: 20px; border-left: 4px solid #dc2626; }
        .footer { padding: 25px; text-align: center; font-size: 13px; color: #9ca3af; background-color: #f9fafb; border-top: 1px solid #f3f4f6; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>You're Invited!</h1>
            <p>Join our platform as a Doctor</p>
        </div>
        <div class="content">
            <p>Hello Doctor,</p>
            <p>You have been officially invited to join an <strong>Afya</strong> clinic. We provide a modern, seamless experience for managing your practice and patient records.</p>
            <p>Please use the following secure token to accept your invitation and complete your profile setup:</p>
            <div class="token-box">
                <span>%s</span>
            </div>
            <div class="alert">
                <strong>Important:</strong> This secure token will expire in exactly 24 hours.
            </div>
        </div>
        <div class="footer">
            <p>&copy; 2026 Afya. All rights reserved.</p>
            <p>If you were not expecting this invitation, please safely ignore this email.</p>
        </div>
    </div>
</body>
</html>`, rawToken)
		go func(email, subject, body string) {
			_ = s.sender.Send(email, subject, body)
		}(req.Email, subject, body)
	} else {
		// Log the token so developers can test locally without SMTP
		log.Printf("LOCAL DEV: Created doctor invitation for %s with token: %s", req.Email, rawToken)
	}

	return nil
}

func (s *service) AcceptInvitation(ctx context.Context, tokenRaw string, req AcceptInvitationRequest) (*users.User, error) {
	hash := sha256.Sum256([]byte(tokenRaw))
	tokenHashStr := hex.EncodeToString(hash[:])

	inv, err := s.repo.FindByTokenHash(ctx, tokenHashStr)
	if err != nil {
		if errors.Is(err, ErrInvitationNotFound) {
			return nil, errors.New("invalid or expired token")
		}
		return nil, err
	}

	if inv.Status != StatusPending {
		return nil, errors.New("invitation already used or revoked")
	}

	if time.Now().After(inv.ExpiresAt) {
		return nil, errors.New("invitation expired")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("failed to hash password: %w", err)
	}

	var createdUser *users.User

	err = database.WithTransaction(ctx, s.db, func(tx database.DBTX) error {
		invRepo := NewRepository(tx)
		userRepo := users.NewRepository(tx)

		if err := invRepo.UpdateStatus(ctx, inv.ID, StatusAccepted); err != nil {
			return err
		}

		docStatus := users.DoctorStatusActive
		user := &users.User{
			FirstName:      req.FirstName,
			LastName:       req.LastName,
			Phone:          req.Phone,
			Role:           users.RoleDoctor,
			Email:          inv.Email,
			PasswordHash:   string(hashedPassword),
			ClinicID:       &inv.ClinicID,
			Specialization: &req.Specialization,
			LicenseNumber:  &req.LicenseNumber,
			DoctorStatus:   &docStatus,
			InvitedBy:      inv.InvitedBy,
		}

		if err := userRepo.Create(ctx, user); err != nil {
			return err
		}
		createdUser = user
		return nil
	})

	if err != nil {
		return nil, err
	}

	return createdUser, nil
}

func (s *service) MarkExpired(ctx context.Context) (int64, error) {
	return s.repo.MarkExpired(ctx)
}
