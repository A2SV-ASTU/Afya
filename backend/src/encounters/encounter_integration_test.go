package encounters

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/token"
	"afyamind-backend/src/users"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func TestEncounters_HTTPIntegration(t *testing.T) {
	gin.SetMode(gin.TestMode)
	secret := "jwt_test_secret"

	repo := newMockRepository()
	clinicID := uuid.New()
	userRepo := &mockUserRepo{clinicID: clinicID}
	svc := NewService(repo, userRepo)
	handler := NewHandler(svc)

	doctorID := uuid.New()
	patientID := uuid.New()

	doctorToken, _ := token.GenerateToken(doctorID, string(users.RoleDoctor), token.TokenTypeAccess, time.Hour, secret)
	patientToken, _ := token.GenerateToken(patientID, string(users.RolePatient), token.TokenTypeAccess, time.Hour, secret)

	r := gin.New()
	api := r.Group("/api/v1")
	api.Use(middleware.RequireAuth(secret))

	api.POST("/patients/:patientId/encounters", middleware.RequireRole(string(users.RoleDoctor)), handler.CreateEncounter)
	api.GET("/patients/:patientId/encounters", middleware.RequireRole(string(users.RoleDoctor), string(users.RolePatient)), handler.ListEncounters)
	api.GET("/encounters/:id", middleware.RequireRole(string(users.RoleDoctor), string(users.RolePatient)), handler.GetEncounter)
	api.GET("/encounters/:id/medical-history", middleware.RequireRole(string(users.RoleDoctor), string(users.RolePatient)), handler.GetMedicalHistory)
	api.PATCH("/encounters/:id/close", middleware.RequireRole(string(users.RoleDoctor)), handler.CloseEncounter)

	var createdEncounterID uuid.UUID

	// 1. POST /api/v1/patients/:patientId/encounters
	t.Run("POST /api/v1/patients/:patientId/encounters", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/patients/"+patientID.String()+"/encounters", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: doctorToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusCreated {
			t.Fatalf("expected status 201 Created, got %d. Body: %s", w.Code, w.Body.String())
		}

		var resp EncounterResponse
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("failed to unmarshal response: %v", err)
		}
		if resp.Encounter.Status != StatusOpen {
			t.Errorf("expected encounter status 'open', got '%s'", resp.Encounter.Status)
		}
		createdEncounterID = resp.Encounter.ID
	})

	// 2. GET /api/v1/patients/:patientId/encounters
	t.Run("GET /api/v1/patients/:patientId/encounters", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patients/"+patientID.String()+"/encounters?page=1&limit=10", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: doctorToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 3. GET /api/v1/encounters/:id
	t.Run("GET /api/v1/encounters/:id", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/encounters/"+createdEncounterID.String(), nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 4. GET /api/v1/encounters/:encounterId/medical-history
	t.Run("GET /api/v1/encounters/:encounterId/medical-history", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/encounters/"+createdEncounterID.String()+"/medical-history", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: doctorToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 5. PATCH /api/v1/encounters/:id/close
	t.Run("PATCH /api/v1/encounters/:id/close", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/encounters/"+createdEncounterID.String()+"/close", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: doctorToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 6. PATCH /api/v1/encounters/:id/close again -> 409 Conflict
	t.Run("PATCH /api/v1/encounters/:id/close conflict", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/encounters/"+createdEncounterID.String()+"/close", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: doctorToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusConflict {
			t.Fatalf("expected status 409 Conflict, got %d. Body: %s", w.Code, w.Body.String())
		}
	})
}
