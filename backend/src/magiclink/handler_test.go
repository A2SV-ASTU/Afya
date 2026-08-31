package magiclink

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	accessrequests "afyamind-backend/src/access-requests"
	"afyamind-backend/src/auth"
	"afyamind-backend/src/config"
	shared_errors "afyamind-backend/src/shared/errors"

	"github.com/gin-gonic/gin"
)

// --- Mock Auth Service ---

type mockAuthService struct {
	auth.Service // embed to satisfy interface for methods we don't mock
	shouldFail   bool
	failCode     string
}

func (m *mockAuthService) ResetPassword(ctx context.Context, token, newPassword string) *shared_errors.AppError {
	if m.shouldFail {
		return &shared_errors.AppError{Code: m.failCode, Message: "Mock Error"}
	}
	return nil
}

// --- Mock Access Request Service ---

type mockARService struct {
	accessrequests.Service
	shouldFail bool
	failErr    error
}

func (m *mockARService) ApproveByToken(ctx context.Context, token string) error {
	if m.shouldFail {
		return m.failErr
	}
	return nil
}

func (m *mockARService) DenyByToken(ctx context.Context, token string) error {
	if m.shouldFail {
		return m.failErr
	}
	return nil
}

// --- Test Suite ---

func setupRouter(arService accessrequests.Service, authService auth.Service) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	cfg := &config.Config{APIBaseURL: "http://localhost:8080"}
	handler := NewHandler(arService, authService, cfg)
	v1 := r.Group("/api/v1")
	RegisterRoutes(v1, handler)
	return r
}

func TestMagicLink_AccessRequest(t *testing.T) {
	arSvc := &mockARService{}
	r := setupRouter(arSvc, nil)

	// 1. GET /api/v1/magic/access-request - Missing token
	req, _ := http.NewRequest(http.MethodGet, "/api/v1/magic/access-request", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for missing token, got %v", w.Code)
	}

	// 2. GET /api/v1/magic/access-request - Valid token & action
	req, _ = http.NewRequest(http.MethodGet, "/api/v1/magic/access-request?token=valid_token&action=approve", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Errorf("expected 200 for valid token/action, got %v", w.Code)
	}
	if !strings.Contains(w.Body.String(), "Confirm Approve") {
		t.Errorf("expected HTML to contain 'Confirm Approve', got %s", w.Body.String())
	}

	// 3. POST /api/v1/magic/access-request - Success Approve
	data := url.Values{}
	data.Set("token", "valid_token")
	data.Set("action", "approve")
	req, _ = http.NewRequest(http.MethodPost, "/api/v1/magic/access-request", strings.NewReader(data.Encode()))
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Errorf("expected 200 for successful approve, got %v", w.Code)
	}
	if !strings.Contains(w.Body.String(), "Approved") {
		t.Errorf("expected HTML success message")
	}

	// 4. POST /api/v1/magic/access-request - Invalid token error
	arSvc.shouldFail = true
	arSvc.failErr = errors.New("invalid_token")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req) // reusing request
	if w.Code != http.StatusOK {
		t.Errorf("expected 200 (serving error HTML), got %v", w.Code)
	}
	if !strings.Contains(w.Body.String(), "invalid") {
		t.Errorf("expected HTML to contain invalid token message")
	}
}

func TestMagicLink_ResetPassword(t *testing.T) {
	authSvc := &mockAuthService{}
	r := setupRouter(nil, authSvc)

	// 1. GET /api/v1/magic/reset-password - Valid token
	req, _ := http.NewRequest(http.MethodGet, "/api/v1/magic/reset-password?token=valid_token", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Errorf("expected 200 for valid reset password GET, got %v", w.Code)
	}
	if !strings.Contains(w.Body.String(), "Reset Password") {
		t.Errorf("expected HTML to contain 'Reset Password'")
	}

	// 2. POST /api/v1/magic/reset-password - Password mismatch
	data := url.Values{}
	data.Set("token", "valid_token")
	data.Set("password", "newpass123")
	data.Set("confirm_password", "mismatch123")
	req, _ = http.NewRequest(http.MethodPost, "/api/v1/magic/reset-password", strings.NewReader(data.Encode()))
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if !strings.Contains(w.Body.String(), "Passwords Don't Match") {
		t.Errorf("expected passwords mismatch error HTML")
	}

	// 3. POST /api/v1/magic/reset-password - Short password
	data.Set("confirm_password", "newpass123")
	data.Set("password", "short")
	req, _ = http.NewRequest(http.MethodPost, "/api/v1/magic/reset-password", strings.NewReader(data.Encode()))
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if !strings.Contains(w.Body.String(), "Invalid Password") {
		t.Errorf("expected invalid password HTML")
	}

	// 4. POST /api/v1/magic/reset-password - Success
	data.Set("password", "newpass123")
	data.Set("confirm_password", "newpass123")
	req, _ = http.NewRequest(http.MethodPost, "/api/v1/magic/reset-password", strings.NewReader(data.Encode()))
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if !strings.Contains(w.Body.String(), "successfully reset") {
		t.Errorf("expected successful reset HTML")
	}
}

func TestMagicLink_AcceptInvitation(t *testing.T) {
	r := setupRouter(nil, nil)

	// 1. GET /api/v1/magic/accept-invitation - Missing token
	req, _ := http.NewRequest(http.MethodGet, "/api/v1/magic/accept-invitation", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for missing token")
	}

	// 2. GET /api/v1/magic/accept-invitation - Valid token
	req, _ = http.NewRequest(http.MethodGet, "/api/v1/magic/accept-invitation?token=valid_token", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Errorf("expected 200 for valid accept invitation GET, got %v", w.Code)
	}
	if !strings.Contains(w.Body.String(), "Welcome to Afya") {
		t.Errorf("expected HTML to contain 'Welcome to Afya'")
	}
}
