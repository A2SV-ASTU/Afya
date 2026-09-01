package accessrequests

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"afyamind-backend/src/shared/email"
	"afyamind-backend/src/users"

	"github.com/google/uuid"
)

type Service interface {
	LookupPatient(ctx context.Context, email string) (*PatientLookupResponse, error)
	CreateRequest(ctx context.Context, clinicID, doctorID uuid.UUID, req CreateAccessRequestRequest, apiBaseURL string) (*AccessRequest, error)
	ApproveRequest(ctx context.Context, patientID, requestID uuid.UUID) error
	DenyRequest(ctx context.Context, patientID, requestID uuid.UUID) error
	RevokeRequest(ctx context.Context, clinicID, requestID, callerID uuid.UUID) error
	ListRequests(ctx context.Context, clinicID, callerID uuid.UUID, status string) ([]*AccessRequest, error)
	ListPatientActiveRequests(ctx context.Context, patientID uuid.UUID) ([]*AccessRequest, error)
	ListPatientGrants(ctx context.Context, patientID uuid.UUID) ([]*AccessRequest, error)
	RevokePatientGrant(ctx context.Context, patientID, clinicID uuid.UUID) error
	ApproveByToken(ctx context.Context, tokenRaw string) error
	DenyByToken(ctx context.Context, tokenRaw string) error
}

type service struct {
	db       *sql.DB
	repo     Repository
	userRepo users.Repository
	sender   *email.Sender
}

func NewService(db *sql.DB, repo Repository, userRepo users.Repository, sender *email.Sender) Service {
	return &service{
		db:       db,
		repo:     repo,
		userRepo: userRepo,
		sender:   sender,
	}
}

func generateAccessToken() (string, string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", "", err
	}
	raw := hex.EncodeToString(b)
	hash := sha256.Sum256([]byte(raw))
	return raw, hex.EncodeToString(hash[:]), nil
}

func (s *service) LookupPatient(ctx context.Context, email string) (*PatientLookupResponse, error) {
	user, err := s.userRepo.FindByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, users.ErrUserNotFound) {
			return nil, errors.New("patient_not_found")
		}
		return nil, err
	}
	if user.Role != users.RolePatient {
		return nil, errors.New("patient_not_found")
	}

	return &PatientLookupResponse{
		ID:        user.ID,
		FirstName: user.FirstName,
		LastName:  user.LastName,
		Email:     user.Email,
	}, nil
}

func (s *service) CreateRequest(ctx context.Context, clinicID, doctorID uuid.UUID, req CreateAccessRequestRequest, apiBaseURL string) (*AccessRequest, error) {
	// 1. Validate Caller (Clinic Admin or Doctor must belong to this clinic)
	caller, err := s.userRepo.FindByID(ctx, doctorID)
	if err != nil {
		return nil, errors.New("unauthorized")
	}
	if caller.ClinicID == nil || *caller.ClinicID != clinicID {
		return nil, errors.New("unauthorized_for_clinic")
	}

	// 2. Get Clinic Name for Email
	var clinicName string
	err = s.db.QueryRowContext(ctx, "SELECT name FROM clinics WHERE id = $1", clinicID).Scan(&clinicName)
	if err != nil {
		clinicName = "An Afya Clinic" // Fallback
	}

	patient, err := s.userRepo.FindByID(ctx, req.PatientID)
	if err != nil || patient.Role != users.RolePatient {
		return nil, errors.New("patient_not_found")
	}

	// 3. Generate magic link token
	rawToken, hashToken, err := generateAccessToken()
	if err != nil {
		return nil, fmt.Errorf("failed to generate magic link token: %w", err)
	}

	ar := &AccessRequest{
		PatientID:           req.PatientID,
		RequestingClinicID:  clinicID,
		Reason:              req.Reason,
		SubmittedByDoctorID: &doctorID,
		Status:              StatusPending,
		ExpiresAt:           time.Now().Add(15 * time.Minute),
		TokenHash:           hashToken,
	}

	if err := s.repo.Create(ctx, ar); err != nil {
		return nil, err
	}

	if s.sender != nil {
		approveURL := fmt.Sprintf("%s/api/v1/magic/access-request?token=%s&action=approve", apiBaseURL, rawToken)
		denyURL := fmt.Sprintf("%s/api/v1/magic/access-request?token=%s&action=deny", apiBaseURL, rawToken)

		subject := fmt.Sprintf("Access Request from %s", clinicName)
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
        .info-box { background-color: #f0fdf4; border-left: 4px solid #22c55e; padding: 20px; margin: 20px 0; border-radius: 0 8px 8px 0; }
        .info-box p { margin: 5px 0; color: #166534; }
        .info-box strong { color: #14532d; display: inline-block; width: 140px; }
        .btn-group { text-align: center; margin: 30px 0; }
        .btn { display: inline-block; padding: 14px 36px; border-radius: 8px; text-decoration: none; font-weight: 700; font-size: 16px; margin: 0 8px; }
        .btn-approve { background-color: #22c55e; color: #ffffff !important; }
        .btn-deny { background-color: #ef4444; color: #ffffff !important; }
        .alert { font-size: 14px; color: #991b1b; background-color: #fef2f2; padding: 12px; border-radius: 6px; margin-top: 20px; border-left: 4px solid #dc2626; }
        .footer { padding: 25px; text-align: center; font-size: 13px; color: #9ca3af; background-color: #f9fafb; border-top: 1px solid #f3f4f6; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>New Access Request</h1>
        </div>
        <div class="content">
            <p>Hello <strong>%s</strong>,</p>
            <p><strong>%s</strong> is requesting access to your medical history and patient records on the Afya platform.</p>
            <div class="info-box">
                <p><strong>Requesting Clinic:</strong> %s</p>
                <p><strong>Reason Provided:</strong> %s</p>
            </div>
            <div class="btn-group">
                <a href="%s" class="btn btn-approve">✓ Approve Request</a>
                <a href="%s" class="btn btn-deny">✕ Deny Request</a>
            </div>
            <div class="alert">
                <strong>Important:</strong> This request will automatically expire in 15 minutes. After clicking a button above, you will see a confirmation page before any action is taken.
            </div>
        </div>
        <div class="footer">
            <p>&copy; 2026 Afya. All rights reserved.</p>
            <p>If you do not recognize this clinic, please deny the request.</p>
        </div>
    </div>
</body>
</html>`, patient.FirstName, clinicName, clinicName, req.Reason, approveURL, denyURL)

		go func(email, subject, body string) {
			_ = s.sender.Send(email, subject, body)
		}(patient.Email, subject, body)
	}

	return ar, nil
}

func (s *service) ApproveRequest(ctx context.Context, patientID, requestID uuid.UUID) error {
	ar, err := s.repo.FindByID(ctx, requestID)
	if err != nil {
		return err
	}
	if ar.PatientID != patientID {
		return errors.New("not_target_patient")
	}
	if ar.Status != StatusPending {
		return errors.New("request_not_pending")
	}
	if time.Now().After(ar.ExpiresAt) {
		return errors.New("request_expired")
	}

	return s.repo.UpdateStatus(ctx, requestID, StatusApproved)
}

func (s *service) DenyRequest(ctx context.Context, patientID, requestID uuid.UUID) error {
	ar, err := s.repo.FindByID(ctx, requestID)
	if err != nil {
		return err
	}
	if ar.PatientID != patientID {
		return errors.New("not_target_patient")
	}
	if ar.Status != StatusPending {
		return errors.New("request_not_pending")
	}
	if time.Now().After(ar.ExpiresAt) {
		return errors.New("request_expired")
	}

	return s.repo.UpdateStatus(ctx, requestID, StatusDenied)
}

func (s *service) RevokeRequest(ctx context.Context, clinicID, requestID, callerID uuid.UUID) error {
	caller, err := s.userRepo.FindByID(ctx, callerID)
	if err != nil {
		return errors.New("unauthorized")
	}
	if caller.ClinicID == nil || *caller.ClinicID != clinicID {
		return errors.New("unauthorized_for_clinic")
	}

	ar, err := s.repo.FindByID(ctx, requestID)
	if err != nil {
		return err
	}
	if ar.RequestingClinicID != clinicID {
		return errors.New("unauthorized_clinic")
	}
	if ar.Status != StatusApproved {
		return errors.New("access_request_not_approved")
	}

	return s.repo.Revoke(ctx, requestID)
}

func (s *service) ListRequests(ctx context.Context, clinicID, callerID uuid.UUID, status string) ([]*AccessRequest, error) {
	caller, err := s.userRepo.FindByID(ctx, callerID)
	if err != nil {
		return nil, errors.New("unauthorized")
	}
	if caller.ClinicID == nil || *caller.ClinicID != clinicID {
		return nil, errors.New("unauthorized_for_clinic")
	}

	return s.repo.ListByClinicID(ctx, clinicID, status)
}

func (s *service) ListPatientActiveRequests(ctx context.Context, patientID uuid.UUID) ([]*AccessRequest, error) {
	return s.repo.ListPendingByPatientID(ctx, patientID)
}

func (s *service) ListPatientGrants(ctx context.Context, patientID uuid.UUID) ([]*AccessRequest, error) {
	return s.repo.ListActiveGrantsByPatientID(ctx, patientID)
}

func (s *service) RevokePatientGrant(ctx context.Context, patientID, clinicID uuid.UUID) error {
	return s.repo.RevokeByPatientAndClinic(ctx, patientID, clinicID)
}

// ApproveByToken approves an access request using a magic link token (no login required)
func (s *service) ApproveByToken(ctx context.Context, tokenRaw string) error {
	hash := sha256.Sum256([]byte(tokenRaw))
	tokenHashStr := hex.EncodeToString(hash[:])

	ar, err := s.repo.FindByTokenHash(ctx, tokenHashStr)
	if err != nil {
		return errors.New("invalid_token")
	}
	if ar.Status != StatusPending {
		return errors.New("request_not_pending")
	}
	if time.Now().After(ar.ExpiresAt) {
		return errors.New("request_expired")
	}

	return s.repo.UpdateStatus(ctx, ar.ID, StatusApproved)
}

// DenyByToken denies an access request using a magic link token (no login required)
func (s *service) DenyByToken(ctx context.Context, tokenRaw string) error {
	hash := sha256.Sum256([]byte(tokenRaw))
	tokenHashStr := hex.EncodeToString(hash[:])

	ar, err := s.repo.FindByTokenHash(ctx, tokenHashStr)
	if err != nil {
		return errors.New("invalid_token")
	}
	if ar.Status != StatusPending {
		return errors.New("request_not_pending")
	}
	if time.Now().After(ar.ExpiresAt) {
		return errors.New("request_expired")
	}

	return s.repo.UpdateStatus(ctx, ar.ID, StatusDenied)
}
