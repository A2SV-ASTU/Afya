package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestRequireAdmin_ForbiddenForPatient(t *testing.T) {
	r := gin.New()
	r.Use(func(c *gin.Context) {
		c.Set(ContextKeyUserRole, "patient")
		c.Next()
	})
	r.Use(RequireAdmin())
	r.GET("/admin-route", func(c *gin.Context) {
		c.Status(http.StatusOK)
	})

	req := httptest.NewRequest(http.MethodGet, "/admin-route", nil)
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusForbidden {
		t.Errorf("expected status 403 for patient role, got %d", w.Code)
	}
}

func TestRequireAdmin_AllowsClinicAdminAndSuperAdmin(t *testing.T) {
	roles := []string{"clinic_admin", "super_admin"}

	for _, rName := range roles {
		r := gin.New()
		r.Use(func(c *gin.Context) {
			c.Set(ContextKeyUserRole, rName)
			c.Next()
		})
		r.Use(RequireAdmin())
		r.GET("/admin-route", func(c *gin.Context) {
			c.Status(http.StatusOK)
		})

		req := httptest.NewRequest(http.MethodGet, "/admin-route", nil)
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Errorf("expected status 200 for %s role, got %d", rName, w.Code)
		}
	}
}
