package accessrequests

import (
	"context"
	"testing"
	"time"

	"afyamind-backend/src/users"
	"github.com/google/uuid"
)

type mockRepository struct {
	requests map[uuid.UUID]*AccessRequest
}

func newMockRepository() *mockRepository {
	return &mockRepository{requests: make(map[uuid.UUID]*AccessRequest)}
}

func (m *mockRepository) Create(ctx context.Context, req *AccessRequest) error {
	req.ID = uuid.New()
	req.CreatedAt = time.Now()
	req.UpdatedAt = time.Now()
	m.requests[req.ID] = req
	return nil
}

func (m *mockRepository) FindByID(ctx context.Context, id uuid.UUID) (*AccessRequest, error) {
	req, ok := m.requests[id]
	if !ok {
		return nil, ErrRequestNotFound
	}
	return req, nil
}

func (m *mockRepository) FindByTokenHash(ctx context.Context, tokenHash string) (*AccessRequest, error) {
	for _, req := range m.requests {
		if req.TokenHash == tokenHash {
			return req, nil
		}
	}
	return nil, ErrRequestNotFound
}

func (m *mockRepository) ListByClinicID(ctx context.Context, clinicID uuid.UUID, status string) ([]*AccessRequest, error) {
	var list []*AccessRequest
	for _, req := range m.requests {
		if req.RequestingClinicID == clinicID {
			if status == "" || req.Status == status {
				list = append(list, req)
			}
		}
	}
	return list, nil
}

func (m *mockRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status string) error {
	req, ok := m.requests[id]
	if !ok {
		return ErrRequestNotFound
	}
	req.Status = status
	req.UpdatedAt = time.Now()
	return nil
}

func (m *mockRepository) Revoke(ctx context.Context, id uuid.UUID) error {
	req, ok := m.requests[id]
	if !ok {
		return ErrRequestNotFound
	}
	now := time.Now()
	req.RevokedAt = &now
	req.UpdatedAt = now
	return nil
}

func (m *mockRepository) FindActiveGrant(ctx context.Context, clinicID, patientID uuid.UUID) (*AccessRequest, error) {
	for _, req := range m.requests {
		if req.RequestingClinicID == clinicID && req.PatientID == patientID && req.Status == StatusApproved && req.RevokedAt == nil {
			return req, nil
		}
	}
	return nil, ErrRequestNotFound
}

func (m *mockRepository) MarkExpired(ctx context.Context) (int64, error) {
	var count int64
	for _, req := range m.requests {
		if req.Status == StatusPending && time.Now().After(req.ExpiresAt) {
			req.Status = StatusExpired
			count++
		}
	}
	return count, nil
}

type mockUserRepo struct {
	users map[uuid.UUID]*users.User
}

func newMockUserRepo() *mockUserRepo {
	return &mockUserRepo{users: make(map[uuid.UUID]*users.User)}
}

func (m *mockUserRepo) FindByID(ctx context.Context, id uuid.UUID) (*users.User, error) {
	u, ok := m.users[id]
	if !ok {
		return nil, users.ErrUserNotFound
	}
	return u, nil
}

func (m *mockUserRepo) FindByEmail(ctx context.Context, email string) (*users.User, error) {
	for _, u := range m.users {
		if u.Email == email {
			return u, nil
		}
	}
	return nil, users.ErrUserNotFound
}

func (m *mockUserRepo) FindByPhone(ctx context.Context, phone string) (*users.User, error) {
	for _, u := range m.users {
		if u.Phone == phone {
			return u, nil
		}
	}
	return nil, users.ErrUserNotFound
}

func (m *mockUserRepo) FindByLogin(ctx context.Context, login string) (*users.User, error) {
	return nil, users.ErrUserNotFound
}

func (m *mockUserRepo) Create(ctx context.Context, u *users.User) error {
	m.users[u.ID] = u
	return nil
}

func (m *mockUserRepo) UpdateProfile(ctx context.Context, id uuid.UUID, req users.UpdateProfileRequest) (*users.User, error) {
	return nil, nil
}

func (m *mockUserRepo) UpdatePassword(ctx context.Context, id uuid.UUID, passwordHash string) error {
	return nil
}

func (m *mockUserRepo) DeleteAccount(ctx context.Context, id uuid.UUID) error {
	return nil
}

func TestCreateAccessRequest_PopulatesPatient(t *testing.T) {
	repo := newMockRepository()
	userRepo := newMockUserRepo()

	clinicID := uuid.New()
	doctorID := uuid.New()
	patientID := uuid.New()

	doctor := &users.User{
		ID:       doctorID,
		Role:     users.RoleDoctor,
		ClinicID: &clinicID,
	}
	patient := &users.User{
		ID:        patientID,
		FirstName: "John",
		LastName:  "Doe",
		Email:     "john.doe@example.com",
		Role:      users.RolePatient,
	}

	userRepo.users[doctorID] = doctor
	userRepo.users[patientID] = patient

	svc := NewService(nil, repo, userRepo, nil)

	req := CreateAccessRequestRequest{
		PatientID: patientID,
		Reason:    "Routine Cardiology Checkup",
	}

	ar, err := svc.CreateRequest(context.Background(), clinicID, doctorID, req, "http://localhost:8080")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}

	if ar.Patient == nil {
		t.Fatalf("expected ar.Patient to be populated, got nil")
	}

	if ar.Patient.ID != patientID {
		t.Errorf("expected patient ID %s, got %s", patientID, ar.Patient.ID)
	}
	if ar.Patient.FirstName != "John" {
		t.Errorf("expected first name John, got %s", ar.Patient.FirstName)
	}
	if ar.Patient.LastName != "Doe" {
		t.Errorf("expected last name Doe, got %s", ar.Patient.LastName)
	}
	if ar.Patient.Email != "john.doe@example.com" {
		t.Errorf("expected email john.doe@example.com, got %s", ar.Patient.Email)
	}
}
