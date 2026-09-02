package clinicalevaluations

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"afyamind-backend/src/encounters"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/token"
	"afyamind-backend/src/users"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func TestClinicalEvaluations_HTTPIntegration(t *testing.T) {
	gin.SetMode(gin.TestMode)
	secret := "jwt_test_secret"

	repo := newMockRepository()
	encRepo := newMockEncounterRepo()
	svc := NewService(repo, encRepo)
	handler := NewHandler(svc)

	doctorID := uuid.New()
	patientID := uuid.New()
	clinicID := uuid.New()

	openEncounterID := uuid.New()
	encRepo.encounters[openEncounterID] = &encounters.Encounter{
		ID:        openEncounterID,
		PatientID: patientID,
		ClinicID:  clinicID,
		Status:    encounters.StatusOpen,
	}

	doctorToken, _ := token.GenerateToken(doctorID, string(users.RoleDoctor), token.TokenTypeAccess, time.Hour, secret)
	patientToken, _ := token.GenerateToken(patientID, string(users.RolePatient), token.TokenTypeAccess, time.Hour, secret)

	r := gin.New()
	api := r.Group("/api/v1")
	api.Use(middleware.RequireAuth(secret))

	api.POST("/encounters/:id/clinical-evaluation", middleware.RequireRole(string(users.RoleDoctor)), handler.CreateClinicalEvaluation)
	api.GET("/encounters/:id/clinical-evaluation", middleware.RequireRole(string(users.RoleDoctor), string(users.RolePatient)), handler.GetClinicalEvaluation)

	// 1. POST /api/v1/encounters/:encounterId/clinical-evaluation (Invalid Body)
	t.Run("POST invalid request body", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/encounters/"+openEncounterID.String()+"/clinical-evaluation", bytes.NewBuffer([]byte("{}")))
		req.Header.Set("Content-Type", "application/json")
		req.AddCookie(&http.Cookie{Name: "access_token", Value: doctorToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusBadRequest {
			t.Fatalf("expected status 400 Bad Request, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 2. POST /api/v1/encounters/:encounterId/clinical-evaluation (Valid)
	t.Run("POST create evaluation success", func(t *testing.T) {
		reqBody, _ := json.Marshal(CreateClinicalEvaluationRequest{
			ChiefComplaint:          "Chest pain",
			HistoryOfPresentIllness: "Started this morning",
		})
		req := httptest.NewRequest(http.MethodPost, "/api/v1/encounters/"+openEncounterID.String()+"/clinical-evaluation", bytes.NewBuffer(reqBody))
		req.Header.Set("Content-Type", "application/json")
		req.AddCookie(&http.Cookie{Name: "access_token", Value: doctorToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusCreated {
			t.Fatalf("expected status 201 Created, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 3. GET /api/v1/encounters/:encounterId/clinical-evaluation (Valid)
	t.Run("GET clinical evaluation success", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/encounters/"+openEncounterID.String()+"/clinical-evaluation", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// 4. GET /api/v1/encounters/:encounterId/clinical-evaluation (Not found)
	t.Run("GET missing clinical evaluation", func(t *testing.T) {
		missingID := uuid.New()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/encounters/"+missingID.String()+"/clinical-evaluation", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: doctorToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusNotFound {
			t.Fatalf("expected status 404 Not Found, got %d. Body: %s", w.Code, w.Body.String())
		}
	})
}
