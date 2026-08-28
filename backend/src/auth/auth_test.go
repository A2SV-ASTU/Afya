package auth

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"afyamind-backend/src/config"
	"afyamind-backend/src/token"
	"afyamind-backend/src/users"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type mockAuthRepo struct {
	users map[uuid.UUID]*users.User
}

func newMockAuthRepo() *mockAuthRepo {
	return &mockAuthRepo{
		users: make(map[uuid.UUID]*users.User),
	}
}

func (m *mockAuthRepo) FindByEmail(ctx context.Context, email string) (*users.User, error) {
	for _, u := range m.users {
		if u.Email == email {
			return u, nil
		}
	}
	return nil, users.ErrUserNotFound
}

func (m *mockAuthRepo) FindByPhone(ctx context.Context, phone string) (*users.User, error) {
	for _, u := range m.users {
		if u.Phone == phone {
			return u, nil
		}
	}
	return nil, users.ErrUserNotFound
}

func (m *mockAuthRepo) FindByLogin(ctx context.Context, login string) (*users.User, error) {
	for _, u := range m.users {
		if u.Email == login || u.Phone == login {
			return u, nil
		}
	}
	return nil, users.ErrUserNotFound
}

func (m *mockAuthRepo) FindByID(ctx context.Context, id uuid.UUID) (*users.User, error) {
	u, exists := m.users[id]
	if !exists {
		return nil, users.ErrUserNotFound
	}
	return u, nil
}

func (m *mockAuthRepo) Create(ctx context.Context, user *users.User) error {
	if user.ID == uuid.Nil {
		user.ID = uuid.New()
	}
	user.CreatedAt = time.Now()
	user.UpdatedAt = time.Now()
	m.users[user.ID] = user
	return nil
}

func setupTestConfig() *config.Config {
	return &config.Config{
		JWTSecret:                "test_secret_key_12345",
		AccessTokenExpiryMinutes: 15,
		RefreshTokenExpiryDays:   7,
		CookieDomain:             "",
		CookieSecure:             false,
	}
}

func TestAuthService_Signup(t *testing.T) {
	cfg := setupTestConfig()
	repo := newMockAuthRepo()
	svc := NewService(repo, cfg, nil)

	// 1. Success signup
	req := SignupRequest{FirstName: "Alice", LastName: "Smith", Phone: "+251911111111", Email: "alice@example.com", Password: "securePassword123"}
	user, accToken, refToken, appErr := svc.Signup(context.Background(), req)
	if appErr != nil {
		t.Fatalf("unexpected signup error: %v", appErr)
	}
	if user.Email != "alice@example.com" || user.Role != users.RolePatient {
		t.Errorf("unexpected user attributes: %+v", user)
	}
	if accToken == "" || refToken == "" {
		t.Error("expected non-empty access and refresh tokens")
	}

	// 2. Invalid email format
	badEmailReq := SignupRequest{FirstName: "Alice", LastName: "Smith", Phone: "+251911111112", Email: "invalid-email", Password: "password123"}
	_, _, _, appErr = svc.Signup(context.Background(), badEmailReq)
	if appErr == nil || appErr.Code != "validation_error" {
		t.Errorf("expected validation_error for bad email, got %v", appErr)
	}

	// 3. Short password
	shortPassReq := SignupRequest{FirstName: "Bob", LastName: "Jones", Phone: "+251911111113", Email: "bob@example.com", Password: "short"}
	_, _, _, appErr = svc.Signup(context.Background(), shortPassReq)
	if appErr == nil || appErr.Code != "validation_error" {
		t.Errorf("expected validation_error for short password, got %v", appErr)
	}

	// 4. Duplicate email (409 conflict)
	_, _, _, appErr = svc.Signup(context.Background(), req)
	if appErr == nil || appErr.Code != "conflict" {
		t.Errorf("expected conflict code for duplicate email, got %v", appErr)
	}
}

func TestAuthService_Login(t *testing.T) {
	cfg := setupTestConfig()
	repo := newMockAuthRepo()
	svc := NewService(repo, cfg, nil)

	signupReq := SignupRequest{FirstName: "Alice", LastName: "Smith", Phone: "+251911111111", Email: "alice@example.com", Password: "securePassword123"}
	_, _, _, _ = svc.Signup(context.Background(), signupReq)

	// 1. Valid login with email
	loginReq := LoginRequest{Email: "alice@example.com", Password: "securePassword123"}
	user, accToken, refToken, appErr := svc.Login(context.Background(), loginReq)
	if appErr != nil {
		t.Fatalf("unexpected login error: %v", appErr)
	}
	if user.Email != "alice@example.com" || accToken == "" || refToken == "" {
		t.Errorf("unexpected login result: %+v", user)
	}

	// 2. Valid login with phone
	loginPhoneReq := LoginRequest{Phone: "+251911111111", Password: "securePassword123"}
	userPhone, _, _, appErr := svc.Login(context.Background(), loginPhoneReq)
	if appErr != nil || userPhone.ID != user.ID {
		t.Fatalf("unexpected phone login result: %v", appErr)
	}

	// 3. Invalid password
	wrongPassReq := LoginRequest{Email: "alice@example.com", Password: "wrongPassword"}
	_, _, _, appErr = svc.Login(context.Background(), wrongPassReq)
	if appErr == nil || appErr.Code != "unauthenticated" {
		t.Errorf("expected unauthenticated for wrong password, got %v", appErr)
	}
}

func TestAuthService_Refresh(t *testing.T) {
	cfg := setupTestConfig()
	repo := newMockAuthRepo()
	svc := NewService(repo, cfg, nil)

	signupReq := SignupRequest{FirstName: "Alice", LastName: "Smith", Phone: "+251911111111", Email: "alice@example.com", Password: "securePassword123"}
	user, _, refToken, _ := svc.Signup(context.Background(), signupReq)

	// 1. Valid refresh
	refreshedUser, newAccToken, appErr := svc.Refresh(context.Background(), refToken)
	if appErr != nil {
		t.Fatalf("unexpected refresh error: %v", appErr)
	}
	if refreshedUser.ID != user.ID || newAccToken == "" {
		t.Errorf("unexpected refresh response: %+v", refreshedUser)
	}

	// 2. Invalid/wrong token type
	accToken, _ := token.GenerateToken(user.ID, string(user.Role), token.TokenTypeAccess, time.Minute, cfg.JWTSecret)
	_, _, appErr = svc.Refresh(context.Background(), accToken)
	if appErr == nil || appErr.Code != "unauthenticated" {
		t.Errorf("expected unauthenticated when passing access token to refresh, got %v", appErr)
	}
}

func TestAuthHandlers_HTTPIntegration(t *testing.T) {
	gin.SetMode(gin.TestMode)
	cfg := setupTestConfig()
	repo := newMockAuthRepo()
	svc := NewService(repo, cfg, nil)
	handler := NewHandler(svc, cfg)

	r := gin.New()
	v1 := r.Group("/v1")
	RegisterRoutes(v1, handler, cfg.JWTSecret)

	var refreshTokenCookie *http.Cookie
	var accessTokenCookie *http.Cookie

	// 1. POST /v1/auth/register
	t.Run("POST /v1/auth/register", func(t *testing.T) {
		body, _ := json.Marshal(SignupRequest{FirstName: "Charlie", LastName: "Brown", Phone: "+251911222333", Email: "charlie@example.com", Password: "password123"})
		req := httptest.NewRequest(http.MethodPost, "/v1/auth/register", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusCreated {
			t.Fatalf("expected 201 Created, got %d. Body: %s", w.Code, w.Body.String())
		}

		cookies := w.Result().Cookies()
		for _, c := range cookies {
			if c.Name == "access_token" {
				accessTokenCookie = c
			}
			if c.Name == "refresh_token" {
				refreshTokenCookie = c
			}
		}

		if accessTokenCookie == nil || refreshTokenCookie == nil {
			t.Fatal("expected access_token and refresh_token cookies to be set")
		}
	})

	// 2. POST /v1/auth/login
	t.Run("POST /v1/auth/login", func(t *testing.T) {
		body, _ := json.Marshal(LoginRequest{Email: "charlie@example.com", Password: "password123"})
		req := httptest.NewRequest(http.MethodPost, "/v1/auth/login", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 3. POST /v1/auth/refresh
	t.Run("POST /v1/auth/refresh", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/v1/auth/refresh", nil)
		req.AddCookie(refreshTokenCookie)
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 4. POST /v1/auth/logout
	t.Run("POST /v1/auth/logout", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/v1/auth/logout", nil)
		req.AddCookie(accessTokenCookie)
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}

		cookies := w.Result().Cookies()
		for _, c := range cookies {
			if c.Name == "access_token" || c.Name == "refresh_token" {
				if c.MaxAge > 0 {
					t.Errorf("expected cookie %s to be cleared, got MaxAge %d", c.Name, c.MaxAge)
				}
			}
		}
	})
}
