package users

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"afyamind-backend/src/token"

	"github.com/gin-gonic/gin"
)

type mockRepository struct {
	users map[int64]*User
}

func newMockRepository() *mockRepository {
	return &mockRepository{
		users: make(map[int64]*User),
	}
}

func (m *mockRepository) FindByID(ctx context.Context, id int64) (*User, error) {
	u, exists := m.users[id]
	if !exists {
		return nil, ErrUserNotFound
	}
	return u, nil
}

func (m *mockRepository) FindByEmail(ctx context.Context, email string) (*User, error) {
	for _, u := range m.users {
		if u.Email == email {
			return u, nil
		}
	}
	return nil, ErrUserNotFound
}

func (m *mockRepository) Create(ctx context.Context, user *User) error {
	user.ID = int64(len(m.users) + 1)
	user.CreatedAt = time.Now()
	user.UpdatedAt = time.Now()
	m.users[user.ID] = user
	return nil
}

func (m *mockRepository) UpdateProfile(ctx context.Context, id int64, name string) (*User, error) {
	u, exists := m.users[id]
	if !exists {
		return nil, ErrUserNotFound
	}
	u.Name = name
	u.UpdatedAt = time.Now()
	return u, nil
}

func (m *mockRepository) AcceptDisclaimer(ctx context.Context, id int64) (*User, error) {
	u, exists := m.users[id]
	if !exists {
		return nil, ErrUserNotFound
	}
	now := time.Now()
	u.AgeAttested18 = true
	u.DisclaimerAcceptedAt = &now
	u.UpdatedAt = now
	return u, nil
}

func TestUserService_GetProfile(t *testing.T) {
	repo := newMockRepository()
	svc := NewService(repo)

	testUser := &User{Email: "test@example.com", Name: "Test User", Role: RolePerson, Status: StatusActive}
	_ = repo.Create(context.Background(), testUser)

	profile, appErr := svc.GetProfile(context.Background(), testUser.ID)
	if appErr != nil {
		t.Fatalf("unexpected error getting profile: %v", appErr)
	}

	if profile.Email != "test@example.com" || profile.Name != "Test User" {
		t.Errorf("unexpected profile data: %+v", profile)
	}

	_, appErr = svc.GetProfile(context.Background(), 999)
	if appErr == nil || appErr.Code != "not_found" {
		t.Errorf("expected not_found error for non-existent user, got: %v", appErr)
	}
}

func TestUserService_UpdateProfile(t *testing.T) {
	repo := newMockRepository()
	svc := NewService(repo)

	testUser := &User{Email: "test@example.com", Name: "Old Name", Role: RolePerson, Status: StatusActive}
	_ = repo.Create(context.Background(), testUser)

	newName := "New Name"
	updated, appErr := svc.UpdateProfile(context.Background(), testUser.ID, UpdateProfileRequest{Name: &newName})
	if appErr != nil {
		t.Fatalf("unexpected error updating profile: %v", appErr)
	}
	if updated.Name != "New Name" {
		t.Errorf("expected updated name 'New Name', got '%s'", updated.Name)
	}

	// Validate empty name rejection
	emptyName := ""
	_, appErr = svc.UpdateProfile(context.Background(), testUser.ID, UpdateProfileRequest{Name: &emptyName})
	if appErr == nil || appErr.Code != "validation_error" {
		t.Errorf("expected validation_error for empty name, got: %v", appErr)
	}
}

func TestUserService_AcceptDisclaimer(t *testing.T) {
	repo := newMockRepository()
	svc := NewService(repo)

	testUser := &User{Email: "test@example.com", Name: "User", Role: RolePerson, Status: StatusActive}
	_ = repo.Create(context.Background(), testUser)

	// False attestation rejection
	_, appErr := svc.AcceptDisclaimer(context.Background(), testUser.ID, DisclaimerRequest{AgeAttested18: false})
	if appErr == nil || appErr.Code != "validation_error" {
		t.Errorf("expected validation_error when age_attested_18 is false, got: %v", appErr)
	}

	// True attestation success
	resp, appErr := svc.AcceptDisclaimer(context.Background(), testUser.ID, DisclaimerRequest{AgeAttested18: true})
	if appErr != nil {
		t.Fatalf("unexpected error accepting disclaimer: %v", appErr)
	}
	if !resp.AgeAttested18 || resp.DisclaimerAcceptedAt == nil {
		t.Errorf("expected disclaimer to be accepted, got: %+v", resp)
	}
}

func TestUserHandlers_HTTPIntegration(t *testing.T) {
	gin.SetMode(gin.TestMode)
	secret := "jwt_test_secret"
	repo := newMockRepository()
	svc := NewService(repo)
	handler := NewHandler(svc)

	testUser := &User{Email: "john@example.com", Name: "John Doe", Role: RolePerson, Status: StatusActive}
	_ = repo.Create(context.Background(), testUser)

	accessToken, _ := token.GenerateToken(testUser.ID, string(testUser.Role), token.TokenTypeAccess, time.Minute, secret)

	r := gin.New()
	v1 := r.Group("/v1")
	RegisterRoutes(v1, handler, secret)

	// 1. GET /v1/users/me
	t.Run("GET /v1/users/me", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/v1/users/me", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: accessToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200, got %d. Body: %s", w.Code, w.Body.String())
		}

		var userResp UserResponse
		if err := json.Unmarshal(w.Body.Bytes(), &userResp); err != nil {
			t.Fatalf("failed to unmarshal response: %v", err)
		}
		if userResp.Email != "john@example.com" {
			t.Errorf("expected email john@example.com, got %s", userResp.Email)
		}
	})

	// 2. PATCH /v1/users/me
	t.Run("PATCH /v1/users/me", func(t *testing.T) {
		newName := "John Updated"
		patchBody, _ := json.Marshal(UpdateProfileRequest{Name: &newName})
		req := httptest.NewRequest(http.MethodPatch, "/v1/users/me", bytes.NewBuffer(patchBody))
		req.Header.Set("Content-Type", "application/json")
		req.AddCookie(&http.Cookie{Name: "access_token", Value: accessToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200, got %d. Body: %s", w.Code, w.Body.String())
		}

		var userResp UserResponse
		_ = json.Unmarshal(w.Body.Bytes(), &userResp)
		if userResp.Name != "John Updated" {
			t.Errorf("expected updated name 'John Updated', got '%s'", userResp.Name)
		}
	})

	// 3. POST /v1/users/me/disclaimer
	t.Run("POST /v1/users/me/disclaimer", func(t *testing.T) {
		discBody, _ := json.Marshal(DisclaimerRequest{AgeAttested18: true})
		req := httptest.NewRequest(http.MethodPost, "/v1/users/me/disclaimer", bytes.NewBuffer(discBody))
		req.Header.Set("Content-Type", "application/json")
		req.AddCookie(&http.Cookie{Name: "access_token", Value: accessToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200, got %d. Body: %s", w.Code, w.Body.String())
		}

		var userResp UserResponse
		_ = json.Unmarshal(w.Body.Bytes(), &userResp)
		if !userResp.AgeAttested18 || userResp.DisclaimerAcceptedAt == nil {
			t.Errorf("expected disclaimer attestation recorded, got: %+v", userResp)
		}
	})
}
