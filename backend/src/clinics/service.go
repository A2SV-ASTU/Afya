package clinics

import (

	"afyamind-backend/src/shared/auth"
	appErrors "afyamind-backend/src/shared/errors"


	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"log"

	"afyamind-backend/src/database"
	"afyamind-backend/src/shared/email"
	"afyamind-backend/src/users"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type Service interface {
	CreateClinic(ctx context.Context, req CreateClinicRequest) (*Clinic, error)
	GetClinics(ctx context.Context) ([]*Clinic, error)
	DeactivateClinic(ctx context.Context, id uuid.UUID) error
	ActivateClinic(ctx context.Context, id uuid.UUID) error
	DeactivateDoctor(ctx context.Context, user *auth.UserContext, clinicID, doctorID uuid.UUID) error
	ActivateDoctor(ctx context.Context, user *auth.UserContext, clinicID, doctorID uuid.UUID) error

	GetClinic(ctx context.Context, user *auth.UserContext, id uuid.UUID) (*Clinic, error)
	GetClinicDoctors(ctx context.Context, user *auth.UserContext, clinicID uuid.UUID) ([]DoctorResponse, error)
	GetClinicInvitations(ctx context.Context, user *auth.UserContext, clinicID uuid.UUID) ([]InvitationResponse, error)

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

func (s *service) CreateClinic(ctx context.Context, req CreateClinicRequest) (*Clinic, error) {
	// Generate random password
	b := make([]byte, 6)
	_, _ = rand.Read(b)
	generatedPassword := hex.EncodeToString(b)

	// Hash generated password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(generatedPassword), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("failed to hash password: %w", err)
	}

	var newClinic *Clinic

	err = database.WithTransaction(ctx, s.db, func(tx database.DBTX) error {
		clinicRepo := NewRepository(tx)
		userRepo := users.NewRepository(tx)

		// 1. Create Clinic
		clinic := &Clinic{
			Name:    req.Name,
			Email:   req.Email,
			Phone:   req.Phone,
			Address: req.Address,
			Status:  StatusActive,
		}

		if err := clinicRepo.Create(ctx, clinic); err != nil {
			// Basic error check for duplicate email
			// 409 clinic_email_already_registered
			return err
		}

		// 2. Create clinic_admin User
		adminUser := &users.User{
			FirstName:    req.AdminFirstName,
			LastName:     req.AdminLastName,
			Role:         users.RoleClinicAdmin,
			Email:        req.Email, // using clinic email for admin login
			Phone:        req.Phone,
			PasswordHash: string(hashedPassword),
			ClinicID:     &clinic.ID,
		}

		if err := userRepo.Create(ctx, adminUser); err != nil {
			return err
		}

		newClinic = clinic
		return nil
	})

	if err != nil {
		return nil, err
	}

	if s.sender != nil {
		subject := "Welcome to Afya - Your Clinic is Ready"
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
        .credentials { background-color: #f0fdf4; border-left: 4px solid #22c55e; border-radius: 0 8px 8px 0; padding: 25px; margin: 30px 0; box-shadow: 0 2px 5px rgba(0,0,0,0.02); }
        .credentials p { margin: 8px 0; font-size: 16px; color: #166534; }
        .credentials strong { color: #14532d; font-weight: 600; display: inline-block; width: 90px; }
        .credentials span { font-family: monospace; font-size: 18px; letter-spacing: 1px; color: #047857; background: #e0f2fe; padding: 2px 6px; border-radius: 4px; }
        .alert { font-size: 14px; color: #991b1b; background-color: #fef2f2; padding: 12px; border-radius: 6px; margin-top: 20px; border-left: 4px solid #dc2626; }
        .footer { padding: 25px; text-align: center; font-size: 13px; color: #9ca3af; background-color: #f9fafb; border-top: 1px solid #f3f4f6; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Welcome to Afya</h1>
            <p>Your clinic is officially registered!</p>
        </div>
        <div class="content">
            <p>Hello <strong>%s %s</strong>,</p>
            <p>We are thrilled to let you know that <strong>%s</strong> has been successfully set up on the Afya platform.</p>
            <p>Your administrative account is ready. For your security, we have generated a temporary password for your first login:</p>
            <div class="credentials">
                <p><strong>Email:</strong> %s</p>
                <p><strong>Password:</strong> <span>%s</span></p>
            </div>
            <div class="alert">
                <strong>Action Required:</strong> Please change your password immediately upon your first login to secure your account.
            </div>
        </div>
        <div class="footer">
            <p>&copy; 2026 Afya. All rights reserved.</p>
            <p>If you did not request this account, please contact our support team immediately.</p>
        </div>
    </div>
</body>
</html>`, req.AdminFirstName, req.AdminLastName, req.Name, req.Email, generatedPassword)

		go func(email, subject, body string) {
			_ = s.sender.Send(email, subject, body)
		}(req.Email, subject, body)
	} else {
		// Log the credentials so developers can test locally without SMTP
		log.Printf("LOCAL DEV: Created clinic admin %s with password: %s", req.Email, generatedPassword)
	}

	return newClinic, nil
}

func (s *service) GetClinics(ctx context.Context) ([]*Clinic, error) {
	return s.repo.ListAll(ctx)
}

func (s *service) DeactivateClinic(ctx context.Context, id uuid.UUID) error {
	clinic, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if clinic.Status == StatusDeactivated {
		return errors.New("clinic is already deactivated")
	}
	return s.repo.UpdateStatus(ctx, id, StatusDeactivated)
}

func (s *service) DeactivateDoctor(ctx context.Context, user *auth.UserContext, clinicID, doctorID uuid.UUID) error {
	if user.Role == string(users.RoleClinicAdmin) && (user.ClinicID == nil || *user.ClinicID != clinicID) {
		return errors.New("unauthorized for this clinic")
	}

	return s.repo.DeactivateDoctor(ctx, clinicID, doctorID)
}

func (s *service) ActivateClinic(ctx context.Context, id uuid.UUID) error {
	clinic, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if clinic.Status == StatusActive {
		return errors.New("clinic is already active")
	}
	return s.repo.UpdateStatus(ctx, id, StatusActive)
}

func (s *service) ActivateDoctor(ctx context.Context, user *auth.UserContext, clinicID, doctorID uuid.UUID) error {
	if user.Role == string(users.RoleClinicAdmin) && (user.ClinicID == nil || *user.ClinicID != clinicID) {
		return errors.New("unauthorized for this clinic")
	}

	return s.repo.ActivateDoctor(ctx, clinicID, doctorID)
}


func (s *service) GetClinic(ctx context.Context, user *auth.UserContext, id uuid.UUID) (*Clinic, error) {
	if user.Role == "clinic_admin" && (user.ClinicID == nil || *user.ClinicID != id) {
		return nil, appErrors.ErrForbiddenRole()
	}

	clinic, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if clinic == nil {
		return nil, appErrors.ErrNotFound("")
	}
	return clinic, nil
}

func (s *service) GetClinicDoctors(ctx context.Context, user *auth.UserContext, clinicID uuid.UUID) ([]DoctorResponse, error) {
	if user.Role != "super_admin" && (user.ClinicID == nil || *user.ClinicID != clinicID) {
		return nil, appErrors.ErrForbiddenRole()
	}

	// Verify clinic exists
	clinic, err := s.repo.FindByID(ctx, clinicID)
	if err != nil {
		return nil, err
	}
	if clinic == nil {
		return nil, appErrors.ErrNotFound("")
	}

	doctors, err := s.repo.FindDoctorsByClinicID(ctx, clinicID)
	if err != nil {
		return nil, err
	}
	if doctors == nil {
		return []DoctorResponse{}, nil // Return empty array instead of null
	}
	return doctors, nil
}

func (s *service) GetClinicInvitations(ctx context.Context, user *auth.UserContext, clinicID uuid.UUID) ([]InvitationResponse, error) {
	if user.Role != "super_admin" && (user.ClinicID == nil || *user.ClinicID != clinicID) {
		return nil, appErrors.ErrForbiddenRole()
	}

	// Verify clinic exists
	clinic, err := s.repo.FindByID(ctx, clinicID)
	if err != nil {
		return nil, err
	}
	if clinic == nil {
		return nil, appErrors.ErrNotFound("")
	}

	invitations, err := s.repo.FindInvitationsByClinicID(ctx, clinicID)
	if err != nil {
		return nil, err
	}
	if invitations == nil {
		return []InvitationResponse{}, nil // Return empty array instead of null
	}
	return invitations, nil
}

