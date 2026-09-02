package vitals

import (
	"context"
	"errors"
	"testing"
	"time"

	"afyamind-backend/src/shared/auth"
	sharedErr "afyamind-backend/src/shared/errors"

	"github.com/google/uuid"
)

// ---------------------------------------------------------------------------
// Mock Repository
// ---------------------------------------------------------------------------

type mockRepo struct {
	insertErr           error
	upsertID            uuid.UUID
	upsertCreated       bool
	upsertErr           error
	listByPatientVitals []VitalSign
	listByPatientErr    error
	listUnackedVitals   []VitalSign
	listUnackedErr      error
	ackErr              error
	findPatientIDResult uuid.UUID
	findPatientIDErr    error
}

func (m *mockRepo) Insert(ctx context.Context, v *VitalSign) error {
	if m.insertErr != nil {
		return m.insertErr
	}
	v.ID = uuid.New()
	return nil
}

func (m *mockRepo) UpsertByClientID(ctx context.Context, v *VitalSign) (uuid.UUID, bool, error) {
	if m.upsertErr != nil {
		return uuid.Nil, false, m.upsertErr
	}
	id := m.upsertID
	if id == uuid.Nil {
		id = uuid.New()
	}
	return id, m.upsertCreated, nil
}

func (m *mockRepo) ListByPatient(ctx context.Context, patientID uuid.UUID, from, to *time.Time, source *VitalSource) ([]VitalSign, error) {
	if m.listByPatientErr != nil {
		return nil, m.listByPatientErr
	}
	return m.listByPatientVitals, nil
}

func (m *mockRepo) ListUnackedClinicVitals(ctx context.Context, patientID uuid.UUID, since *time.Time) ([]VitalSign, error) {
	if m.listUnackedErr != nil {
		return nil, m.listUnackedErr
	}
	return m.listUnackedVitals, nil
}

func (m *mockRepo) AckVitals(ctx context.Context, patientID uuid.UUID, vitalIDs []uuid.UUID) error {
	return m.ackErr
}

func (m *mockRepo) FindPatientIDByEncounter(ctx context.Context, encounterID uuid.UUID) (uuid.UUID, error) {
	return m.findPatientIDResult, m.findPatientIDErr
}

// ---------------------------------------------------------------------------
// TestRecordEncounterVitals
// ---------------------------------------------------------------------------

func TestRecordEncounterVitals(t *testing.T) {
	encounterID := uuid.New()
	patientID := uuid.New()
	doctorID := uuid.New()
	dbErr := errors.New("db error")
	pulse := 72
	req := RecordEncounterVitalsRequest{Pulse: &pulse}

	tests := []struct {
		name          string
		user          *auth.UserContext
		repo          *mockRepo
		expectedError string
	}{
		{
			name:          "doctor records vitals successfully",
			user:          &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo:          &mockRepo{findPatientIDResult: patientID},
			expectedError: "",
		},
		{
			name:          "patient cannot record encounter vitals",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			repo:          &mockRepo{findPatientIDResult: patientID},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name:          "clinic_admin cannot record encounter vitals",
			user:          &auth.UserContext{Role: "clinic_admin"},
			repo:          &mockRepo{findPatientIDResult: patientID},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name:          "encounter not found returns not_found error",
			user:          &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo:          &mockRepo{findPatientIDErr: ErrVitalNotFound},
			expectedError: sharedErr.ErrNotFound("encounter").Error(),
		},
		{
			name:          "repository insert error is wrapped as internal",
			user:          &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo:          &mockRepo{findPatientIDResult: patientID, insertErr: dbErr},
			expectedError: sharedErr.ErrInternal(dbErr.Error()).Error(),
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := NewService(tt.repo)
			v, err := svc.RecordEncounterVitals(context.Background(), tt.user, encounterID, req)

			if tt.expectedError == "" {
				if err != nil {
					t.Fatalf("expected no error, got: %v", err)
				}
				if v == nil {
					t.Fatal("expected non-nil VitalSign")
				}
				if v.Source != SourceClinic {
					t.Errorf("expected source %q, got %q", SourceClinic, v.Source)
				}
				if v.PatientID != patientID {
					t.Errorf("expected patientID %v, got %v", patientID, v.PatientID)
				}
			} else {
				if err == nil {
					t.Fatalf("expected error %q, got nil", tt.expectedError)
				}
				if err.Error() != tt.expectedError {
					t.Errorf("expected error %q, got %q", tt.expectedError, err.Error())
				}
			}
		})
	}
}

// ---------------------------------------------------------------------------
// TestLogPatientVital
// ---------------------------------------------------------------------------

func TestLogPatientVital(t *testing.T) {
	patientID := uuid.New()
	pulse := 80
	req := LogPatientVitalRequest{Pulse: &pulse}
	dbErr := errors.New("db error")

	tests := []struct {
		name          string
		user          *auth.UserContext
		repo          *mockRepo
		expectedError string
	}{
		{
			name:          "patient logs own vital successfully",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			repo:          &mockRepo{},
			expectedError: "",
		},
		{
			name:          "doctor cannot log patient vital via this path",
			user:          &auth.UserContext{ID: uuid.New(), Role: "doctor"},
			repo:          &mockRepo{},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name:          "repository error is wrapped as internal",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			repo:          &mockRepo{insertErr: dbErr},
			expectedError: sharedErr.ErrInternal(dbErr.Error()).Error(),
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := NewService(tt.repo)
			v, err := svc.LogPatientVital(context.Background(), tt.user, req)

			if tt.expectedError == "" {
				if err != nil {
					t.Fatalf("expected no error, got: %v", err)
				}
				if v.Source != SourcePatient {
					t.Errorf("expected source %q, got %q", SourcePatient, v.Source)
				}
				if v.PatientID != patientID {
					t.Errorf("expected patientID %v from user context", patientID)
				}
			} else {
				if err == nil {
					t.Fatalf("expected error %q, got nil", tt.expectedError)
				}
				if err.Error() != tt.expectedError {
					t.Errorf("expected error %q, got %q", tt.expectedError, err.Error())
				}
			}
		})
	}
}

// ---------------------------------------------------------------------------
// TestListPatientVitals
// ---------------------------------------------------------------------------

func TestListPatientVitals(t *testing.T) {
	patientID := uuid.New()
	otherID := uuid.New()
	seed := []VitalSign{{ID: uuid.New(), PatientID: patientID, Source: SourceClinic}}

	tests := []struct {
		name          string
		user          *auth.UserContext
		queryID       uuid.UUID
		repo          *mockRepo
		expectedCount int
		expectedError string
	}{
		{
			name:          "patient lists own vitals",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			queryID:       patientID,
			repo:          &mockRepo{listByPatientVitals: seed},
			expectedCount: 1,
		},
		{
			name:          "patient cannot list another patient vitals",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			queryID:       otherID,
			repo:          &mockRepo{listByPatientVitals: seed},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name:          "doctor can list any patient vitals",
			user:          &auth.UserContext{ID: uuid.New(), Role: "doctor"},
			queryID:       patientID,
			repo:          &mockRepo{listByPatientVitals: seed},
			expectedCount: 1,
		},
		{
			name:          "empty result returns empty slice",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			queryID:       patientID,
			repo:          &mockRepo{listByPatientVitals: []VitalSign{}},
			expectedCount: 0,
		},
		{
			name:          "repository error propagates",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			queryID:       patientID,
			repo:          &mockRepo{listByPatientErr: errors.New("db down")},
			expectedError: "db down",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := NewService(tt.repo)
			res, err := svc.ListPatientVitals(context.Background(), tt.user, tt.queryID, ListVitalsQuery{})

			if tt.expectedError != "" {
				if err == nil {
					t.Fatalf("expected error %q, got nil", tt.expectedError)
				}
				if err.Error() != tt.expectedError {
					t.Errorf("expected error %q, got %q", tt.expectedError, err.Error())
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if len(res) != tt.expectedCount {
				t.Errorf("expected %d vitals, got %d", tt.expectedCount, len(res))
			}
		})
	}
}

// ---------------------------------------------------------------------------
// TestSyncPatientVitals
// ---------------------------------------------------------------------------

func TestSyncPatientVitals(t *testing.T) {
	patientID := uuid.New()
	clientID := uuid.New()
	pulse := 70

	validEntry := SyncVitalEntry{
		ClientID: clientID,
		Pulse:    &pulse,
	}

	tests := []struct {
		name          string
		user          *auth.UserContext
		req           SyncVitalsRequest
		repo          *mockRepo
		expectedError string
		expectedLen   int
	}{
		{
			name:        "patient syncs new vital (created=true)",
			user:        &auth.UserContext{ID: patientID, Role: "patient"},
			req:         SyncVitalsRequest{Vitals: []SyncVitalEntry{validEntry}},
			repo:        &mockRepo{upsertCreated: true},
			expectedLen: 1,
		},
		{
			name:        "patient syncs duplicate vital (idempotent, created=false)",
			user:        &auth.UserContext{ID: patientID, Role: "patient"},
			req:         SyncVitalsRequest{Vitals: []SyncVitalEntry{validEntry}},
			repo:        &mockRepo{upsertCreated: false, upsertID: uuid.New()},
			expectedLen: 1,
		},
		{
			name:          "doctor cannot use patient sync endpoint",
			user:          &auth.UserContext{ID: uuid.New(), Role: "doctor"},
			req:           SyncVitalsRequest{Vitals: []SyncVitalEntry{validEntry}},
			repo:          &mockRepo{},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name:          "upsert error is wrapped as internal",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			req:           SyncVitalsRequest{Vitals: []SyncVitalEntry{validEntry}},
			repo:          &mockRepo{upsertErr: errors.New("conflict")},
			expectedError: sharedErr.ErrInternal("conflict").Error(),
		},
		{
			name:        "empty batch returns empty results",
			user:        &auth.UserContext{ID: patientID, Role: "patient"},
			req:         SyncVitalsRequest{Vitals: []SyncVitalEntry{}},
			repo:        &mockRepo{},
			expectedLen: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := NewService(tt.repo)
			resp, err := svc.SyncPatientVitals(context.Background(), tt.user, tt.req)

			if tt.expectedError != "" {
				if err == nil {
					t.Fatalf("expected error %q, got nil", tt.expectedError)
				}
				if err.Error() != tt.expectedError {
					t.Errorf("expected error %q, got %q", tt.expectedError, err.Error())
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if len(resp.Results) != tt.expectedLen {
				t.Errorf("expected %d results, got %d", tt.expectedLen, len(resp.Results))
			}
			if tt.expectedLen > 0 && resp.Results[0].ClientID != clientID {
				t.Errorf("expected clientID %q, got %q", clientID, resp.Results[0].ClientID)
			}
		})
	}
}

// ---------------------------------------------------------------------------
// TestGetDoctorSyncVitals
// ---------------------------------------------------------------------------

func TestGetDoctorSyncVitals(t *testing.T) {
	patientID := uuid.New()
	seed := []VitalSign{{ID: uuid.New(), PatientID: patientID, Source: SourceClinic}}

	tests := []struct {
		name          string
		user          *auth.UserContext
		repo          *mockRepo
		expectedError string
		expectedLen   int
	}{
		{
			name:        "patient retrieves unacked clinic vitals",
			user:        &auth.UserContext{ID: patientID, Role: "patient"},
			repo:        &mockRepo{listUnackedVitals: seed},
			expectedLen: 1,
		},
		{
			name:          "doctor cannot call patient-side sync endpoint",
			user:          &auth.UserContext{ID: uuid.New(), Role: "doctor"},
			repo:          &mockRepo{},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name:        "empty unacked vitals returns empty slice",
			user:        &auth.UserContext{ID: patientID, Role: "patient"},
			repo:        &mockRepo{listUnackedVitals: []VitalSign{}},
			expectedLen: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := NewService(tt.repo)
			res, err := svc.GetDoctorSyncVitals(context.Background(), tt.user, nil)

			if tt.expectedError != "" {
				if err == nil {
					t.Fatalf("expected error %q, got nil", tt.expectedError)
				}
				if err.Error() != tt.expectedError {
					t.Errorf("expected error %q, got %q", tt.expectedError, err.Error())
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if len(res) != tt.expectedLen {
				t.Errorf("expected %d vitals, got %d", tt.expectedLen, len(res))
			}
		})
	}
}

// ---------------------------------------------------------------------------
// TestAckDoctorVitals
// ---------------------------------------------------------------------------

func TestAckDoctorVitals(t *testing.T) {
	patientID := uuid.New()
	vitalID := uuid.New()

	tests := []struct {
		name          string
		user          *auth.UserContext
		repo          *mockRepo
		expectedError string
	}{
		{
			name:          "patient acks successfully",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			repo:          &mockRepo{},
			expectedError: "",
		},
		{
			name:          "doctor cannot ack vitals",
			user:          &auth.UserContext{ID: uuid.New(), Role: "doctor"},
			repo:          &mockRepo{},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name:          "repository ack error propagates",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			repo:          &mockRepo{ackErr: errors.New("db error")},
			expectedError: "db error",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := NewService(tt.repo)
			err := svc.AckDoctorVitals(context.Background(), tt.user, AckVitalsRequest{SyncedIDs: []uuid.UUID{vitalID}})

			if tt.expectedError == "" {
				if err != nil {
					t.Fatalf("expected no error, got: %v", err)
				}
			} else {
				if err == nil {
					t.Fatalf("expected error %q, got nil", tt.expectedError)
				}
				if err.Error() != tt.expectedError {
					t.Errorf("expected error %q, got %q", tt.expectedError, err.Error())
				}
			}
		})
	}
}
