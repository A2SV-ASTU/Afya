package auth

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
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
	users         map[uuid.UUID]*users.User
	verifications map[string]*EmailVerification
}

func newMockAuthRepo() *mockAuthRepo {
	return &mockAuthRepo{
		users:         make(map[uuid.UUID]*users.User),
		verifications: make(map[string]*EmailVerification),
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

func (m *mockAuthRepo) CreatePasswordReset(ctx context.Context, userID uuid.UUID, tokenHash string, expiresAt time.Time) error {
	return nil
}

func (m *mockAuthRepo) FindPasswordResetByTokenHash(ctx context.Context, tokenHash string) (uuid.UUID, uuid.UUID, bool, error) {
	return uuid.Nil, uuid.Nil, false, nil
}

func (m *mockAuthRepo) MarkPasswordResetUsed(ctx context.Context, id uuid.UUID) error {
	return nil
}

func (m *mockAuthRepo) UpdateUserPassword(ctx context.Context, userID uuid.UUID, newHash string) error {
	return nil
}

func (m *mockAuthRepo) CreateEmailVerification(ctx context.Context, userID uuid.UUID, email, otpHash string, expiresAt time.Time) error {
	m.verifications[email] = &EmailVerification{
		ID:        uuid.New(),
		UserID:    userID,
		Email:     email,
		OTPHash:   otpHash,
		Attempts:  0,
		ExpiresAt: expiresAt,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	return nil
}

func (m *mockAuthRepo) FindEmailVerificationByEmail(ctx context.Context, email string) (*EmailVerification, error) {
	v, exists := m.verifications[email]
	if !exists {
		return nil, users.ErrUserNotFound
	}
	return v, nil
}

func (m *mockAuthRepo) IncrementVerificationAttempts(ctx context.Context, id uuid.UUID) error {
	for _, v := range m.verifications {
		if v.ID == id {
			v.Attempts++
			return nil
		}
	}
	return nil
}

func (m *mockAuthRepo) DeleteEmailVerification(ctx context.Context, id uuid.UUID) error {
	for email, v := range m.verifications {
		if v.ID == id {
			delete(m.verifications, email)
			return nil
		}
	}
	return nil
}

func (m *mockAuthRepo) MarkEmailVerified(ctx context.Context, userID uuid.UUID) error {
	u, exists := m.users[userID]
	if !exists {
		return users.ErrUserNotFound
	}
	u.IsEmailVerified = true
	now := time.Now()
	u.EmailVerifiedAt = &now
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

	// 1. Success signup - creates unverified user and saves OTP
	req := SignupRequest{FirstName: "Alice", LastName: "Smith", Phone: "+251911111111", Email: "alice@example.com", Password: "securePassword123"}
	user, appErr := svc.Signup(context.Background(), req)
	if appErr != nil {
		t.Fatalf("unexpected signup error: %v", appErr)
	}
	if user.Email != "alice@example.com" || user.Role != users.RolePatient {
		t.Errorf("unexpected user attributes: %+v", user)
	}
	if user.IsEmailVerified {
		t.Error("expected new patient to be unverified")
	}

	// Verify OTP was stored in repo
	ver, err := repo.FindEmailVerificationByEmail(context.Background(), "alice@example.com")
	if err != nil || ver == nil {
		t.Fatalf("expected verification record for alice@example.com, got %v", err)
	}
	if ver.OTPHash == "" {
		t.Error("expected non-empty OTP hash")
	}

	// 2. Invalid email format
	badEmailReq := SignupRequest{FirstName: "Alice", LastName: "Smith", Phone: "+251911111112", Email: "invalid-email", Password: "password123"}
	_, appErr = svc.Signup(context.Background(), badEmailReq)
	if appErr == nil || appErr.Code != "validation_error" {
		t.Errorf("expected validation_error for bad email, got %v", appErr)
	}

	// 3. Short password
	shortPassReq := SignupRequest{FirstName: "Bob", LastName: "Jones", Phone: "+251911111113", Email: "bob@example.com", Password: "short"}
	_, appErr = svc.Signup(context.Background(), shortPassReq)
	if appErr == nil || appErr.Code != "validation_error" {
		t.Errorf("expected validation_error for short password, got %v", appErr)
	}

	// 4. Duplicate email (409 conflict)
	_, appErr = svc.Signup(context.Background(), req)
	if appErr == nil || appErr.Code != "conflict" {
		t.Errorf("expected conflict code for duplicate email, got %v", appErr)
	}
}

func TestAuthService_VerifyEmail(t *testing.T) {
	cfg := setupTestConfig()
	repo := newMockAuthRepo()
	svc := NewService(repo, cfg, nil)

	signupReq := SignupRequest{FirstName: "Alice", LastName: "Smith", Phone: "+251911111111", Email: "alice@example.com", Password: "securePassword123"}
	user, _ := svc.Signup(context.Background(), signupReq)

	// Inject known OTP: 654321
	knownOTP := "654321"
	knownHash := sha256.Sum256([]byte(knownOTP))
	knownHashStr := hex.EncodeToString(knownHash[:])
	repo.verifications["alice@example.com"].OTPHash = knownHashStr

	// 1. Invalid OTP
	_, _, _, appErr := svc.VerifyEmail(context.Background(), VerifyEmailRequest{Email: "alice@example.com", OTP: "000000"})
	if appErr == nil || appErr.Code != "invalid_otp" {
		t.Errorf("expected invalid_otp error, got %v", appErr)
	}
	if repo.verifications["alice@example.com"].Attempts != 1 {
		t.Errorf("expected attempts to increment to 1, got %d", repo.verifications["alice@example.com"].Attempts)
	}

	// 2. Correct OTP
	verifiedUser, accToken, refToken, appErr := svc.VerifyEmail(context.Background(), VerifyEmailRequest{Email: "alice@example.com", OTP: knownOTP})
	if appErr != nil {
		t.Fatalf("unexpected verify email error: %v", appErr)
	}
	if !verifiedUser.IsEmailVerified || verifiedUser.ID != user.ID {
		t.Errorf("expected verified user, got %+v", verifiedUser)
	}
	if accToken == "" || refToken == "" {
		t.Error("expected non-empty tokens on successful verification")
	}

	// Verification record should be cleaned up
	_, err := repo.FindEmailVerificationByEmail(context.Background(), "alice@example.com")
	if err == nil {
		t.Error("expected verification record to be deleted after success")
	}
}

func TestAuthService_ResendOTP(t *testing.T) {
	cfg := setupTestConfig()
	repo := newMockAuthRepo()
	svc := NewService(repo, cfg, nil)

	signupReq := SignupRequest{FirstName: "Alice", LastName: "Smith", Phone: "+251911111111", Email: "alice@example.com", Password: "securePassword123"}
	_, _ = svc.Signup(context.Background(), signupReq)

	// 1. Cooldown active (just created < 60s ago)
	appErr := svc.ResendOTP(context.Background(), ResendOTPRequest{Email: "alice@example.com"})
	if appErr == nil || appErr.Code != "conflict" {
		t.Errorf("expected conflict for cooldown active, got %v", appErr)
	}

	// 2. Cooldown elapsed
	repo.verifications["alice@example.com"].CreatedAt = time.Now().Add(-2 * time.Minute)
	appErr = svc.ResendOTP(context.Background(), ResendOTPRequest{Email: "alice@example.com"})
	if appErr != nil {
		t.Fatalf("unexpected error resending OTP: %v", appErr)
	}

	// 3. Resend for verified user should fail with conflict
	_ = repo.MarkEmailVerified(context.Background(), repo.users[repo.verifications["alice@example.com"].UserID].ID)
	appErr = svc.ResendOTP(context.Background(), ResendOTPRequest{Email: "alice@example.com"})
	if appErr == nil || appErr.Code != "conflict" {
		t.Errorf("expected conflict when resending to verified email, got %v", appErr)
	}
}

func TestAuthService_Login(t *testing.T) {
	cfg := setupTestConfig()
	repo := newMockAuthRepo()
	svc := NewService(repo, cfg, nil)

	signupReq := SignupRequest{FirstName: "Alice", LastName: "Smith", Phone: "+251911111111", Email: "alice@example.com", Password: "securePassword123"}
	user, _ := svc.Signup(context.Background(), signupReq)

	// 1. Login blocked for unverified patient
	loginReq := LoginRequest{Email: "alice@example.com", Password: "securePassword123"}
	_, _, _, appErr := svc.Login(context.Background(), loginReq)
	if appErr == nil || appErr.Code != "email_not_verified" {
		t.Errorf("expected email_not_verified error for unverified patient, got %v", appErr)
	}

	// 2. Verify patient email
	_ = repo.MarkEmailVerified(context.Background(), user.ID)

	// 3. Valid login with email after verification
	verifiedUser, accToken, refToken, appErr := svc.Login(context.Background(), loginReq)
	if appErr != nil {
		t.Fatalf("unexpected login error: %v", appErr)
	}
	if verifiedUser.Email != "alice@example.com" || accToken == "" || refToken == "" {
		t.Errorf("unexpected login result: %+v", verifiedUser)
	}

	// 4. Valid login with phone
	loginPhoneReq := LoginRequest{Phone: "+251911111111", Password: "securePassword123"}
	userPhone, _, _, appErr := svc.Login(context.Background(), loginPhoneReq)
	if appErr != nil || userPhone.ID != user.ID {
		t.Fatalf("unexpected phone login result: %v", appErr)
	}

	// 5. Invalid password
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
	user, _ := svc.Signup(context.Background(), signupReq)
	_ = repo.MarkEmailVerified(context.Background(), user.ID)

	refToken, _ := token.GenerateToken(user.ID, string(user.Role), token.TokenTypeRefresh, 7*24*time.Hour, cfg.JWTSecret)

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

	// 1. POST /v1/auth/register (returns 201 with SignupResponse, NO cookies yet)
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
		if len(cookies) > 0 {
			t.Errorf("expected no cookies on initial signup, got %d cookies", len(cookies))
		}
	})

	// 2. POST /v1/auth/login before verification -> 403 Forbidden
	t.Run("POST /v1/auth/login unverified blocked", func(t *testing.T) {
		body, _ := json.Marshal(LoginRequest{Email: "charlie@example.com", Password: "password123"})
		req := httptest.NewRequest(http.MethodPost, "/v1/auth/login", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusForbidden {
			t.Fatalf("expected 403 Forbidden for unverified login, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 3. POST /v1/auth/verify-email
	t.Run("POST /v1/auth/verify-email", func(t *testing.T) {
		// Set known OTP
		knownOTP := "112233"
		h := sha256.Sum256([]byte(knownOTP))
		repo.verifications["charlie@example.com"].OTPHash = hex.EncodeToString(h[:])

		body, _ := json.Marshal(VerifyEmailRequest{Email: "charlie@example.com", OTP: knownOTP})
		req := httptest.NewRequest(http.MethodPost, "/v1/auth/verify-email", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected 200 OK, got %d. Body: %s", w.Code, w.Body.String())
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
			t.Fatal("expected access_token and refresh_token cookies to be set on verify-email")
		}
	})

	// 4. POST /v1/auth/login after verification -> 200 OK
	t.Run("POST /v1/auth/login verified", func(t *testing.T) {
		body, _ := json.Marshal(LoginRequest{Email: "charlie@example.com", Password: "password123"})
		req := httptest.NewRequest(http.MethodPost, "/v1/auth/login", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 5. POST /v1/auth/refresh
	t.Run("POST /v1/auth/refresh", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/v1/auth/refresh", nil)
		req.AddCookie(refreshTokenCookie)
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 6. POST /v1/auth/logout
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

	// 7. POST /v1/auth/reset-password via Cookie
	t.Run("POST /v1/auth/reset-password via Cookie", func(t *testing.T) {
		body, _ := json.Marshal(map[string]string{"password": "newSecurePassword123"})
		req := httptest.NewRequest(http.MethodPost, "/v1/auth/reset-password", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		req.AddCookie(&http.Cookie{Name: "reset_token", Value: "valid_dummy_reset_token"})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}

		cookies := w.Result().Cookies()
		for _, c := range cookies {
			if c.Name == "reset_token" && c.MaxAge > 0 {
				t.Errorf("expected reset_token cookie to be cleared, got MaxAge %d", c.MaxAge)
			}
		}
	})
}

