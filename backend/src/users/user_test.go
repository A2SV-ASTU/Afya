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
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type mockRepository struct {
	users map[uuid.UUID]*User
}

func newMockRepository() *mockRepository {
	return &mockRepository{
		users: make(map[uuid.UUID]*User),
	}
}

func (m *mockRepository) FindByID(ctx context.Context, id uuid.UUID) (*User, error) {
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

func (m *mockRepository) FindByPhone(ctx context.Context, phone string) (*User, error) {
	for _, u := range m.users {
		if u.Phone == phone {
			return u, nil
		}
	}
	return nil, ErrUserNotFound
}

func (m *mockRepository) FindByLogin(ctx context.Context, login string) (*User, error) {
	for _, u := range m.users {
		if u.Email == login || u.Phone == login {
			return u, nil
		}
	}
	return nil, ErrUserNotFound
}

func (m *mockRepository) Create(ctx context.Context, user *User) error {
	if user.ID == uuid.Nil {
		user.ID = uuid.New()
	}
	user.CreatedAt = time.Now()
	user.UpdatedAt = time.Now()
	m.users[user.ID] = user
	return nil
}

func (m *mockRepository) UpdateProfile(ctx context.Context, id uuid.UUID, req UpdateProfileRequest) (*User, error) {
	u, exists := m.users[id]
	if !exists {
		return nil, ErrUserNotFound
	}
	if req.FirstName != nil {
		u.FirstName = *req.FirstName
	}
	if req.LastName != nil {
		u.LastName = *req.LastName
	}
	if req.Email != nil {
		u.Email = *req.Email
	}
	if req.Phone != nil {
		u.Phone = *req.Phone
	}
	u.UpdatedAt = time.Now()
	return u, nil
}

func (m *mockRepository) UpdatePassword(ctx context.Context, id uuid.UUID, passwordHash string) error {
	u, exists := m.users[id]
	if !exists {
		return ErrUserNotFound
	}
	u.PasswordHash = passwordHash
	u.UpdatedAt = time.Now()
	return nil
}

func (m *mockRepository) DeleteAccount(ctx context.Context, id uuid.UUID) error {
	_, exists := m.users[id]
	if !exists {
		return ErrUserNotFound
	}
	delete(m.users, id)
	return nil
}

func TestUserService_GetProfile(t *testing.T) {
	repo := newMockRepository()
	svc := NewService(repo)

	testUser := &User{Email: "test@example.com", FirstName: "Test", LastName: "User", Role: RolePatient}
	_ = repo.Create(context.Background(), testUser)

	profile, appErr := svc.GetProfile(context.Background(), testUser.ID)
	if appErr != nil {
		t.Fatalf("unexpected error getting profile: %v", appErr)
	}

	if profile.Email != "test@example.com" || profile.FirstName != "Test" {
		t.Errorf("unexpected profile data: %+v", profile)
	}

	_, appErr = svc.GetProfile(context.Background(), uuid.New())
	if appErr == nil || appErr.Code != "not_found" {
		t.Errorf("expected not_found error for non-existent user, got: %v", appErr)
	}
}

func TestUserService_UpdateProfile(t *testing.T) {
	repo := newMockRepository()
	svc := NewService(repo)

	testUser := &User{Email: "test@example.com", FirstName: "Old", LastName: "Name", Role: RolePatient}
	_ = repo.Create(context.Background(), testUser)

	// 1. Update First & Last Name
	newFirst := "NewFirst"
	newLast := "NewLast"

	updated, appErr := svc.UpdateProfile(context.Background(), testUser.ID, UpdateProfileRequest{
		FirstName: &newFirst,
		LastName:  &newLast,
	})
	if appErr != nil {
		t.Fatalf("unexpected error updating profile: %v", appErr)
	}
	if updated.FirstName != "NewFirst" || updated.LastName != "NewLast" {
		t.Errorf("expected updated names, got: %+v", updated)
	}
}

func TestUserService_ChangePassword(t *testing.T) {
	repo := newMockRepository()
	svc := NewService(repo)

	hashedPass, _ := bcrypt.GenerateFromPassword([]byte("oldPassword123"), bcrypt.DefaultCost)
	testUser := &User{Email: "test@example.com", FirstName: "User", LastName: "Test", Role: RolePatient, PasswordHash: string(hashedPass)}
	_ = repo.Create(context.Background(), testUser)

	// 1. Wrong old password rejection
	appErr := svc.ChangePassword(context.Background(), testUser.ID, ChangePasswordRequest{
		CurrentPassword: "wrongOldPassword",
		NewPassword:     "newPassword123",
	})
	if appErr == nil || appErr.Code != "unauthenticated" {
		t.Errorf("expected unauthenticated for wrong old password, got: %v", appErr)
	}

	// 2. Short new password rejection
	appErr = svc.ChangePassword(context.Background(), testUser.ID, ChangePasswordRequest{
		CurrentPassword: "oldPassword123",
		NewPassword:     "short",
	})
	if appErr == nil || appErr.Code != "validation_error" {
		t.Errorf("expected validation_error for short new password, got: %v", appErr)
	}

	// 3. Successful password change
	appErr = svc.ChangePassword(context.Background(), testUser.ID, ChangePasswordRequest{
		CurrentPassword: "oldPassword123",
		NewPassword:     "brandNewPassword123",
	})
	if appErr != nil {
		t.Fatalf("unexpected error changing password: %v", appErr)
	}

	// Verify new password works with bcrypt
	u, _ := repo.FindByID(context.Background(), testUser.ID)
	if err := bcrypt.CompareHashAndPassword([]byte(u.PasswordHash), []byte("brandNewPassword123")); err != nil {
		t.Error("expected new password to match updated hash")
	}
}

func TestUserHandlers_HTTPIntegration(t *testing.T) {
	gin.SetMode(gin.TestMode)
	secret := "jwt_test_secret"
	repo := newMockRepository()
	svc := NewService(repo)
	handler := NewHandler(svc)

	hashedPass, _ := bcrypt.GenerateFromPassword([]byte("oldSecret123"), bcrypt.DefaultCost)
	testUser := &User{Email: "john@example.com", FirstName: "John", LastName: "Doe", Role: RolePatient, PasswordHash: string(hashedPass)}
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
	})

	// 2. PATCH /v1/users/me
	t.Run("PATCH /v1/users/me", func(t *testing.T) {
		newFirst := "John"
		newLast := "Updated"
		patchBody, _ := json.Marshal(UpdateProfileRequest{FirstName: &newFirst, LastName: &newLast})
		req := httptest.NewRequest(http.MethodPatch, "/v1/users/me", bytes.NewBuffer(patchBody))
		req.Header.Set("Content-Type", "application/json")
		req.AddCookie(&http.Cookie{Name: "access_token", Value: accessToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 3. PUT /v1/users/me/password
	t.Run("PUT /v1/users/me/password", func(t *testing.T) {
		passBody, _ := json.Marshal(ChangePasswordRequest{
			CurrentPassword: "oldSecret123",
			NewPassword:     "newSecurePassword456",
		})
		req := httptest.NewRequest(http.MethodPut, "/v1/users/me/password", bytes.NewBuffer(passBody))
		req.Header.Set("Content-Type", "application/json")
		req.AddCookie(&http.Cookie{Name: "access_token", Value: accessToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 4. DELETE /v1/users/me
	t.Run("DELETE /v1/users/me", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodDelete, "/v1/users/me", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: accessToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200, got %d. Body: %s", w.Code, w.Body.String())
		}
	})
}
