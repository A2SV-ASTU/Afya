package accessrequests

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

// --- Tests ---

func TestPatientPortal_HTTPIntegration(t *testing.T) {
	gin.SetMode(gin.TestMode)
	secret := "jwt_test_secret"

	repo := newMockRepository()
	userRepo := newMockUserRepo()
	svc := NewService(nil, repo, userRepo, nil) // nil db and sender are fine since these endpoints don't use them
	handler := NewHandler(svc, nil) // nil config is fine since patient portal endpoints don't use cfg

	patientID := uuid.New()
	doctorID := uuid.New()
	clinicID := uuid.New()
	otherClinicID := uuid.New()

	// Seed users
	userRepo.users[patientID] = &users.User{
		ID:   patientID,
		Role: users.RolePatient,
	}
	userRepo.users[doctorID] = &users.User{
		ID:       doctorID,
		Role:     users.RoleDoctor,
		ClinicID: &clinicID,
	}

	patientToken, _ := token.GenerateToken(patientID, string(users.RolePatient), token.TokenTypeAccess, time.Hour, secret)
	doctorToken, _ := token.GenerateToken(doctorID, string(users.RoleDoctor), token.TokenTypeAccess, time.Hour, secret)

	// Seed access requests
	pendingRequestID := uuid.New()
	repo.requests[pendingRequestID] = &AccessRequest{
		ID:                  pendingRequestID,
		PatientID:           patientID,
		RequestingClinicID:  clinicID,
		Reason:              "Routine checkup",
		SubmittedByDoctorID: &doctorID,
		Status:              StatusPending,
		ExpiresAt:           time.Now().Add(5 * time.Minute),
		CreatedAt:           time.Now(),
		UpdatedAt:           time.Now(),
	}

	approvedRequestID := uuid.New()
	repo.requests[approvedRequestID] = &AccessRequest{
		ID:                  approvedRequestID,
		PatientID:           patientID,
		RequestingClinicID:  clinicID,
		Reason:              "Follow-up consultation",
		SubmittedByDoctorID: &doctorID,
		Status:              StatusApproved,
		ExpiresAt:           time.Now().Add(5 * time.Minute),
		CreatedAt:           time.Now(),
		UpdatedAt:           time.Now(),
	}

	// Another approved request for a different clinic
	otherApprovedID := uuid.New()
	repo.requests[otherApprovedID] = &AccessRequest{
		ID:                  otherApprovedID,
		PatientID:           patientID,
		RequestingClinicID:  otherClinicID,
		Reason:              "Specialist referral",
		SubmittedByDoctorID: &doctorID,
		Status:              StatusApproved,
		ExpiresAt:           time.Now().Add(5 * time.Minute),
		CreatedAt:           time.Now(),
		UpdatedAt:           time.Now(),
	}

	// Expired pending request
	expiredRequestID := uuid.New()
	repo.requests[expiredRequestID] = &AccessRequest{
		ID:                  expiredRequestID,
		PatientID:           patientID,
		RequestingClinicID:  clinicID,
		Reason:              "Old request",
		SubmittedByDoctorID: &doctorID,
		Status:              StatusPending,
		ExpiresAt:           time.Now().Add(-1 * time.Minute), // expired
		CreatedAt:           time.Now().Add(-10 * time.Minute),
		UpdatedAt:           time.Now().Add(-10 * time.Minute),
	}

	// Denied request (should not appear in active or grants)
	deniedRequestID := uuid.New()
	repo.requests[deniedRequestID] = &AccessRequest{
		ID:                  deniedRequestID,
		PatientID:           patientID,
		RequestingClinicID:  clinicID,
		Reason:              "Denied request",
		SubmittedByDoctorID: &doctorID,
		Status:              StatusDenied,
		ExpiresAt:           time.Now().Add(5 * time.Minute),
		CreatedAt:           time.Now(),
		UpdatedAt:           time.Now(),
	}

	// Setup router with all access-request routes
	r := gin.New()
	api := r.Group("/api/v1")
	api.Use(middleware.RequireAuth(secret))

	// Existing patient routes
	patientAccessGroup := api.Group("/access-requests/:id")
	patientAccessGroup.Use(middleware.RequireRole("patient"))
	{
		patientAccessGroup.POST("/approve", handler.ApproveRequest)
		patientAccessGroup.POST("/deny", handler.DenyRequest)
	}

	// Patient portal routes (the new endpoints under test)
	patientPortalGroup := api.Group("/patient")
	patientPortalGroup.Use(middleware.RequireRole("patient"))
	{
		patientPortalGroup.GET("/access-requests/active", handler.ListPatientActiveRequests)
		patientPortalGroup.GET("/grants", handler.ListPatientGrants)
		patientPortalGroup.POST("/grants/:clinicId/revoke", handler.RevokePatientGrant)
	}

	// ==================== GET /patient/access-requests/active ====================

	t.Run("GET /patient/access-requests/active - returns pending requests", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patient/access-requests/active", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}

		var resp map[string][]AccessRequest
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("failed to unmarshal response: %v", err)
		}

		accessRequests := resp["access_requests"]
		if len(accessRequests) != 1 {
			t.Fatalf("expected 1 pending request, got %d", len(accessRequests))
		}
		if accessRequests[0].ID != pendingRequestID {
			t.Errorf("expected pending request ID %s, got %s", pendingRequestID, accessRequests[0].ID)
		}
	})

	t.Run("GET /patient/access-requests/active - excludes expired requests", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patient/access-requests/active", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		var resp map[string][]AccessRequest
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("failed to unmarshal response: %v", err)
		}

		for _, ar := range resp["access_requests"] {
			if ar.ID == expiredRequestID {
				t.Error("expired request should not appear in active list")
			}
		}
	})

	t.Run("GET /patient/access-requests/active - excludes approved requests", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patient/access-requests/active", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		var resp map[string][]AccessRequest
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("failed to unmarshal response: %v", err)
		}

		for _, ar := range resp["access_requests"] {
			if ar.ID == approvedRequestID || ar.ID == otherApprovedID {
				t.Error("approved request should not appear in active pending list")
			}
		}
	})

	t.Run("GET /patient/access-requests/active - requires authentication", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patient/access-requests/active", nil)
		// No cookie
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusUnauthorized {
			t.Fatalf("expected status 401 Unauthorized, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	t.Run("GET /patient/access-requests/active - requires patient role", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patient/access-requests/active", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: doctorToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusForbidden {
			t.Fatalf("expected status 403 Forbidden for doctor role, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// ==================== GET /patient/grants ====================

	t.Run("GET /patient/grants - returns approved non-revoked grants", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patient/grants", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}

		var resp map[string][]AccessRequest
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("failed to unmarshal response: %v", err)
		}

		grants := resp["grants"]
		if len(grants) != 2 {
			t.Fatalf("expected 2 grants, got %d", len(grants))
		}

		grantIDs := make(map[uuid.UUID]bool)
		for _, g := range grants {
			grantIDs[g.ID] = true
			if g.Status != StatusApproved {
				t.Errorf("expected grant status 'approved', got '%s'", g.Status)
			}
		}
		if !grantIDs[approvedRequestID] {
			t.Error("expected approved request to appear in grants")
		}
		if !grantIDs[otherApprovedID] {
			t.Error("expected other approved request to appear in grants")
		}
	})

	t.Run("GET /patient/grants - excludes denied requests", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patient/grants", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		var resp map[string][]AccessRequest
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("failed to unmarshal response: %v", err)
		}

		for _, g := range resp["grants"] {
			if g.ID == deniedRequestID {
				t.Error("denied request should not appear in grants")
			}
		}
	})

	t.Run("GET /patient/grants - excludes pending requests", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patient/grants", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		var resp map[string][]AccessRequest
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("failed to unmarshal response: %v", err)
		}

		for _, g := range resp["grants"] {
			if g.ID == pendingRequestID {
				t.Error("pending request should not appear in grants")
			}
		}
	})

	t.Run("GET /patient/grants - requires authentication", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patient/grants", nil)
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusUnauthorized {
			t.Fatalf("expected status 401 Unauthorized, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	t.Run("GET /patient/grants - requires patient role", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patient/grants", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: doctorToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusForbidden {
			t.Fatalf("expected status 403 Forbidden for doctor role, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// ==================== POST /patient/grants/:clinicId/revoke ====================

	t.Run("POST /patient/grants/:clinicId/revoke - revokes an active grant", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/patient/grants/"+clinicID.String()+"/revoke", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("expected status 200 OK, got %d. Body: %s", w.Code, w.Body.String())
		}

		var resp map[string]string
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("failed to unmarshal response: %v", err)
		}
		if resp["status"] != "revoked" {
			t.Errorf("expected status 'revoked', got '%s'", resp["status"])
		}

		// Verify the grant was actually revoked
		ar := repo.requests[approvedRequestID]
		if ar.RevokedAt == nil {
			t.Error("expected RevokedAt to be set after revocation")
		}
	})

	t.Run("POST /patient/grants/:clinicId/revoke - returns 404 for non-existent grant", func(t *testing.T) {
		fakeClinicID := uuid.New()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/patient/grants/"+fakeClinicID.String()+"/revoke", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusNotFound {
			t.Fatalf("expected status 404 Not Found, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	t.Run("POST /patient/grants/:clinicId/revoke - returns 404 for already revoked grant", func(t *testing.T) {
		// The clinicID grant was already revoked in the previous test
		req := httptest.NewRequest(http.MethodPost, "/api/v1/patient/grants/"+clinicID.String()+"/revoke", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusNotFound {
			t.Fatalf("expected status 404 Not Found for already revoked grant, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	t.Run("POST /patient/grants/:clinicId/revoke - requires authentication", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/patient/grants/"+otherClinicID.String()+"/revoke", nil)
		// No cookie
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusUnauthorized {
			t.Fatalf("expected status 401 Unauthorized, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	t.Run("POST /patient/grants/:clinicId/revoke - requires patient role", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/patient/grants/"+otherClinicID.String()+"/revoke", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: doctorToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusForbidden {
			t.Fatalf("expected status 403 Forbidden for doctor role, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	t.Run("POST /patient/grants/:clinicId/revoke - invalid clinic ID returns 400", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/api/v1/patient/grants/not-a-uuid/revoke", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		if w.Code != http.StatusBadRequest {
			t.Fatalf("expected status 400 Bad Request, got %d. Body: %s", w.Code, w.Body.String())
		}
	})

	// ==================== Verify revocation persists ====================

	t.Run("GET /patient/grants - revoked grant no longer appears", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/patient/grants", nil)
		req.AddCookie(&http.Cookie{Name: "access_token", Value: patientToken})
		w := httptest.NewRecorder()

		r.ServeHTTP(w, req)

		var resp map[string][]AccessRequest
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("failed to unmarshal response: %v", err)
		}

		for _, g := range resp["grants"] {
			if g.ID == approvedRequestID {
				t.Error("revoked grant should not appear in active grants list")
			}
		}

		// Only the other clinic's grant should remain
		if len(resp["grants"]) != 1 {
			t.Fatalf("expected 1 remaining grant after revocation, got %d", len(resp["grants"]))
		}
		if resp["grants"][0].ID != otherApprovedID {
			t.Errorf("expected remaining grant to be %s, got %s", otherApprovedID, resp["grants"][0].ID)
		}
	})
}
