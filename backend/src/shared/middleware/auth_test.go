package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"afyamind-backend/src/token"

	"github.com/gin-gonic/gin"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func TestRequireAuth_MissingCookie(t *testing.T) {
	r := gin.New()
	r.Use(RequireAuth("secret"))
	r.GET("/protected", func(c *gin.Context) {
		c.Status(http.StatusOK)
	})

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected status 401, got %d", w.Code)
	}
}

func TestRequireAuth_ValidToken(t *testing.T) {
	secret := "test_secret"
	tokenStr, err := token.GenerateToken(10, "PERSON", token.TokenTypeAccess, time.Minute, secret)
	if err != nil {
		t.Fatalf("failed to generate token: %v", err)
	}

	r := gin.New()
	r.Use(RequireAuth(secret))
	var capturedID int64
	var capturedRole string

	r.GET("/protected", func(c *gin.Context) {
		id, _ := GetUserID(c)
		role, _ := GetUserRole(c)
		capturedID = id
		capturedRole = role
		c.Status(http.StatusOK)
	})

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	req.AddCookie(&http.Cookie{Name: "access_token", Value: tokenStr})
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", w.Code)
	}
	if capturedID != 10 {
		t.Errorf("expected userID 10, got %d", capturedID)
	}
	if capturedRole != "PERSON" {
		t.Errorf("expected role PERSON, got %s", capturedRole)
	}
}

func TestRequireAuth_RefreshTokenFailsAccessRoute(t *testing.T) {
	secret := "test_secret"
	// Generate a REFRESH token instead of ACCESS token
	tokenStr, err := token.GenerateToken(10, "PERSON", token.TokenTypeRefresh, time.Minute, secret)
	if err != nil {
		t.Fatalf("failed to generate refresh token: %v", err)
	}

	r := gin.New()
	r.Use(RequireAuth(secret))

	r.GET("/protected", func(c *gin.Context) {
		c.Status(http.StatusOK)
	})

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	req.AddCookie(&http.Cookie{Name: "access_token", Value: tokenStr})
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected status 401 when using refresh token for auth, got %d", w.Code)
	}
}
