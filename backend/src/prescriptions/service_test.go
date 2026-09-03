package prescriptions

import (
	"context"
	"database/sql"
	"errors"
	"testing"

	"afyamind-backend/src/database"
	"afyamind-backend/src/shared/auth"
	sharedErr "afyamind-backend/src/shared/errors"

	"github.com/google/uuid"
)

// ---------------------------------------------------------------------------
// Mock Repository
// ---------------------------------------------------------------------------

type mockPrescriptionRepo struct {
	// stubbed returns
	encounterStatus          string
	encounterStatusErr       error
	encounterIDByPrescription uuid.UUID
	encounterIDErr           error
	createWithItemsErr       error
	listByEncounterResult    []Prescription
	listByEncounterErr       error
	findItemsResult          []PrescriptionItem
	findItemsErr             error
	findByIDResult           *Prescription
	findByIDErr              error
	updateNotesErr           error
	replaceItemsErr          error
	updateItemStatusErr      error
	updateAllActiveItemsErr  error
}

func (m *mockPrescriptionRepo) FindEncounterStatus(ctx context.Context, encounterID uuid.UUID) (string, error) {
	return m.encounterStatus, m.encounterStatusErr
}

func (m *mockPrescriptionRepo) FindEncounterIDByPrescription(ctx context.Context, prescriptionID uuid.UUID) (uuid.UUID, error) {
	return m.encounterIDByPrescription, m.encounterIDErr
}

func (m *mockPrescriptionRepo) CreateWithItems(ctx context.Context, tx database.DBTX, p *Prescription, items []PrescriptionItem) error {
	if m.createWithItemsErr != nil {
		return m.createWithItemsErr
	}
	p.ID = uuid.New()
	for i := range items {
		items[i].ID = uuid.New()
	}
	return nil
}

func (m *mockPrescriptionRepo) ListByEncounterID(ctx context.Context, encounterID uuid.UUID) ([]Prescription, error) {
	return m.listByEncounterResult, m.listByEncounterErr
}

func (m *mockPrescriptionRepo) FindItemsByPrescriptionID(ctx context.Context, prescriptionID uuid.UUID) ([]PrescriptionItem, error) {
	return m.findItemsResult, m.findItemsErr
}

func (m *mockPrescriptionRepo) FindByID(ctx context.Context, id uuid.UUID) (*Prescription, error) {
	return m.findByIDResult, m.findByIDErr
}

func (m *mockPrescriptionRepo) UpdateNotes(ctx context.Context, id uuid.UUID, notes *string) error {
	return m.updateNotesErr
}

func (m *mockPrescriptionRepo) ReplaceItems(ctx context.Context, tx database.DBTX, prescriptionID uuid.UUID, items []PrescriptionItem) error {
	return m.replaceItemsErr
}

func (m *mockPrescriptionRepo) UpdateItemStatus(ctx context.Context, itemID uuid.UUID, status PrescriptionItemStatus) error {
	return m.updateItemStatusErr
}

func (m *mockPrescriptionRepo) UpdateAllActiveItemsStatus(ctx context.Context, prescriptionID uuid.UUID, status PrescriptionItemStatus) error {
	return m.updateAllActiveItemsErr
}

// ---------------------------------------------------------------------------
// noopTx is a test-safe transaction function that calls fn directly with a
// nil DBTX. This is safe because mockPrescriptionRepo ignores the tx argument.
func noopTx(_ context.Context, _ *sql.DB, fn func(database.DBTX) error) error {
	return fn(nil)
}

func newTestService(repo *mockPrescriptionRepo) Service {
	return &service{db: nil, repo: repo, txFn: noopTx}
}

// ---------------------------------------------------------------------------
// TestCreatePrescription
// ---------------------------------------------------------------------------

func TestCreatePrescription(t *testing.T) {
	encounterID := uuid.New()
	doctorID := uuid.New()
	patientID := uuid.New()

	validReq := CreatePrescriptionRequest{
		Items: []CreatePrescriptionItemRequest{
			{
				MedicationName: "Amoxicillin",
				Dose:           "500mg",
				Route:          RouteOral,
				Frequency:      FreqTDS,
				DurationValue: 7,
				DurationUnit:  DurationUnitDay,
			},
		},
	}

	tests := []struct {
		name          string
		user          *auth.UserContext
		repo          *mockPrescriptionRepo
		expectedError string
	}{
		{
			name: "doctor creates prescription successfully",
			user: &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo: &mockPrescriptionRepo{
				encounterStatus: "open",
			},
			expectedError: "",
		},
		{
			name:          "patient cannot create prescription",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			repo:          &mockPrescriptionRepo{encounterStatus: "open"},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name:          "clinic_admin cannot create prescription",
			user:          &auth.UserContext{Role: "clinic_admin"},
			repo:          &mockPrescriptionRepo{encounterStatus: "open"},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name: "closed encounter is rejected",
			user: &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo: &mockPrescriptionRepo{
				encounterStatus: "closed",
			},
			expectedError: sharedErr.ErrConflict("encounter is closed; no further edits allowed").Error(),
		},
		{
			name: "encounter not found returns not_found",
			user: &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo: &mockPrescriptionRepo{
				encounterStatusErr: ErrEncounterNotFound,
			},
			expectedError: sharedErr.ErrNotFound("encounter").Error(),
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := newTestService(tt.repo)
			resp, err := svc.CreatePrescription(context.Background(), tt.user, encounterID, validReq)

			if tt.expectedError == "" {
				if err != nil {
					t.Fatalf("expected no error, got: %v", err)
				}
				if resp == nil {
					t.Fatal("expected non-nil PrescriptionResponse")
				}
				if len(resp.Items) != 1 {
					t.Errorf("expected 1 item, got %d", len(resp.Items))
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
// TestListPrescriptions
// ---------------------------------------------------------------------------

func TestListPrescriptions(t *testing.T) {
	encounterID := uuid.New()
	prescriptionID := uuid.New()

	seedPrescriptions := []Prescription{
		{ID: prescriptionID, EncounterID: encounterID},
	}
	seedItems := []PrescriptionItem{
		{ID: uuid.New(), PrescriptionID: prescriptionID, MedicationName: "Ibuprofen"},
	}

	dbErr := errors.New("db error")

	tests := []struct {
		name          string
		repo          *mockPrescriptionRepo
		expectedCount int
		expectedError string
	}{
		{
			name: "lists prescriptions with items successfully",
			repo: &mockPrescriptionRepo{
				listByEncounterResult: seedPrescriptions,
				findItemsResult:       seedItems,
			},
			expectedCount: 1,
		},
		{
			name:          "repository error on list",
			repo:          &mockPrescriptionRepo{listByEncounterErr: dbErr},
			expectedError: sharedErr.ErrInternal(dbErr.Error()).Error(),
		},
		{
			name: "empty encounter returns empty slice",
			repo: &mockPrescriptionRepo{
				listByEncounterResult: []Prescription{},
			},
			expectedCount: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := newTestService(tt.repo)
			res, err := svc.ListPrescriptions(context.Background(), &auth.UserContext{Role: "doctor"}, encounterID)

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
				t.Errorf("expected %d prescriptions, got %d", tt.expectedCount, len(res))
			}
		})
	}
}

// ---------------------------------------------------------------------------
// TestUpdatePrescription
// ---------------------------------------------------------------------------

func TestUpdatePrescription(t *testing.T) {
	doctorID := uuid.New()
	patientID := uuid.New()
	prescriptionID := uuid.New()
	encounterID := uuid.New()
	newNotes := "take with food"

	updatedPrescription := &Prescription{ID: prescriptionID, EncounterID: encounterID, Notes: &newNotes}

	tests := []struct {
		name          string
		user          *auth.UserContext
		repo          *mockPrescriptionRepo
		req           UpdatePrescriptionRequest
		expectedError string
	}{
		{
			name: "doctor updates notes only",
			user: &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo: &mockPrescriptionRepo{
				encounterIDByPrescription: encounterID,
				encounterStatus:          "open",
				findByIDResult:           updatedPrescription,
				findItemsResult:          []PrescriptionItem{},
			},
			req:           UpdatePrescriptionRequest{Notes: &newNotes},
			expectedError: "",
		},
		{
			name:          "patient cannot update prescription",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			repo:          &mockPrescriptionRepo{},
			req:           UpdatePrescriptionRequest{Notes: &newNotes},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name: "prescription not found returns not_found",
			user: &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo: &mockPrescriptionRepo{
				encounterIDErr: ErrPrescriptionNotFound,
			},
			req:           UpdatePrescriptionRequest{Notes: &newNotes},
			expectedError: sharedErr.ErrNotFound("prescription").Error(),
		},
		{
			name: "closed encounter prescription update is allowed",
			user: &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo: &mockPrescriptionRepo{
				encounterIDByPrescription: encounterID,
				encounterStatus:          "closed",
				findByIDResult:           updatedPrescription,
				findItemsResult:          []PrescriptionItem{},
			},
			req:           UpdatePrescriptionRequest{Notes: &newNotes},
			expectedError: "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := newTestService(tt.repo)
			resp, err := svc.UpdatePrescription(context.Background(), tt.user, prescriptionID, tt.req)

			if tt.expectedError == "" {
				if err != nil {
					t.Fatalf("expected no error, got: %v", err)
				}
				if resp == nil {
					t.Fatal("expected non-nil PrescriptionResponse")
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
// TestCompletePrescription
// ---------------------------------------------------------------------------

func TestCompletePrescription(t *testing.T) {
	patientID := uuid.New()
	doctorID := uuid.New()
	prescriptionID := uuid.New()
	itemID := uuid.New()

	tests := []struct {
		name          string
		user          *auth.UserContext
		repo          *mockPrescriptionRepo
		req           CompletePrescriptionRequest
		expectedError string
	}{
		{
			name:          "patient completes all items (empty item IDs list)",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			repo:          &mockPrescriptionRepo{},
			req:           CompletePrescriptionRequest{ItemIDs: []string{}},
			expectedError: "",
		},
		{
			name:          "patient completes specific items",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			repo:          &mockPrescriptionRepo{},
			req:           CompletePrescriptionRequest{ItemIDs: []string{itemID.String()}},
			expectedError: "",
		},
		{
			name:          "doctor cannot mark prescription as completed",
			user:          &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo:          &mockPrescriptionRepo{},
			req:           CompletePrescriptionRequest{},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name:          "invalid item UUID is skipped without error",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			repo:          &mockPrescriptionRepo{},
			req:           CompletePrescriptionRequest{ItemIDs: []string{"not-a-valid-uuid"}},
			expectedError: "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := newTestService(tt.repo)
			err := svc.CompletePrescription(context.Background(), tt.user, prescriptionID, tt.req)

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

// ---------------------------------------------------------------------------
// TestDeactivatePrescription
// ---------------------------------------------------------------------------

func TestDeactivatePrescription(t *testing.T) {
	doctorID := uuid.New()
	patientID := uuid.New()
	prescriptionID := uuid.New()
	dbErr := errors.New("db error")

	tests := []struct {
		name          string
		user          *auth.UserContext
		repo          *mockPrescriptionRepo
		expectedError string
	}{
		{
			name:          "doctor deactivates successfully",
			user:          &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo:          &mockPrescriptionRepo{},
			expectedError: "",
		},
		{
			name:          "patient cannot deactivate prescription",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			repo:          &mockPrescriptionRepo{},
			expectedError: sharedErr.ErrForbiddenRole().Error(),
		},
		{
			name:          "repository error propagates",
			user:          &auth.UserContext{ID: doctorID, Role: "doctor"},
			repo:          &mockPrescriptionRepo{updateAllActiveItemsErr: dbErr},
			expectedError: dbErr.Error(),
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := newTestService(tt.repo)
			err := svc.DeactivatePrescription(context.Background(), tt.user, prescriptionID)

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
