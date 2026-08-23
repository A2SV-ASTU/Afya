package middleware

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

type mockDisclaimerChecker struct {
	accepted bool
}

func (m *mockDisclaimerChecker) IsDisclaimerAccepted(ctx context.Context, userID int64) (bool, error) {
	return m.accepted, nil
}

func TestRequireDisclaimer_Unaccepted(t *testing.T) {
	r := gin.New()
	r.Use(func(c *gin.Context) {
		c.Set(ContextKeyUserID, int64(1))
		c.Next()
	})
	r.Use(RequireDisclaimer(&mockDisclaimerChecker{accepted: false}))
	r.GET("/wellness-route", func(c *gin.Context) {
		c.Status(http.StatusOK)
	})

	req := httptest.NewRequest(http.MethodGet, "/wellness-route", nil)
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusForbidden {
		t.Errorf("expected status 403 attestation_required when unaccepted, got %d", w.Code)
	}
}

func TestRequireDisclaimer_Accepted(t *testing.T) {
	r := gin.New()
	r.Use(func(c *gin.Context) {
		c.Set(ContextKeyUserID, int64(1))
		c.Next()
	})
	r.Use(RequireDisclaimer(&mockDisclaimerChecker{accepted: true}))
	r.GET("/wellness-route", func(c *gin.Context) {
		c.Status(http.StatusOK)
	})

	req := httptest.NewRequest(http.MethodGet, "/wellness-route", nil)
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected status 200 when accepted, got %d", w.Code)
	}
}
