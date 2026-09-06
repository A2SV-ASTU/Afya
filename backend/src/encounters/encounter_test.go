package encounters

import (
	"context"
	"testing"
	"time"

	"afyamind-backend/src/users"

	"github.com/google/uuid"
)

type mockRepository struct {
	encounters map[uuid.UUID]*Encounter
}

func newMockRepository() *mockRepository {
	return &mockRepository{
		encounters: make(map[uuid.UUID]*Encounter),
	}
}

func (m *mockRepository) Create(ctx context.Context, patientID, clinicID, doctorID uuid.UUID) (*Encounter, error) {
	enc := &Encounter{
		ID:               uuid.New(),
		PatientID:        patientID,
		ClinicID:         clinicID,
		OpenedByDoctorID: doctorID,
		Status:           StatusOpen,
		StartedAt:        time.Now(),
		CreatedAt:        time.Now(),
	}
	m.encounters[enc.ID] = enc
	return enc, nil
}

func (m *mockRepository) FindByID(ctx context.Context, id uuid.UUID) (*Encounter, error) {
	enc, ok := m.encounters[id]
	if !ok {
		return nil, nil
	}
	return enc, nil
}

func (m *mockRepository) HasOpenEncounter(ctx context.Context, patientID uuid.UUID) (bool, error) {
	for _, enc := range m.encounters {
		if enc.PatientID == patientID && enc.Status == StatusOpen {
			return true, nil
		}
	}
	return false, nil
}

func (m *mockRepository) ListByPatientID(ctx context.Context, patientID uuid.UUID, limit, offset int) ([]Encounter, int, error) {
	var list []Encounter
	for _, enc := range m.encounters {
		if enc.PatientID == patientID {
			list = append(list, *enc)
		}
	}
	return list, len(list), nil
}

func (m *mockRepository) CloseEncounter(ctx context.Context, id uuid.UUID) (*Encounter, error) {
	enc, ok := m.encounters[id]
	if !ok {
		return nil, nil
	}
	now := time.Now()
	enc.Status = StatusClosed
	enc.EndedAt = &now
	return enc, nil
}

func (m *mockRepository) GetAggregatedEncounter(ctx context.Context, id uuid.UUID) (*AggregatedEncounterResponse, error) {
	enc, ok := m.encounters[id]
	if !ok {
		return nil, nil
	}
	return &AggregatedEncounterResponse{
		Encounter:     *enc,
		Vitals:        []VitalSignDTO{},
		Labs:          []LabResultDTO{},
		Diagnoses:     []DiagnosisDTO{},
		Prescriptions: []PrescriptionDTO{},
	}, nil
}

func (m *mockRepository) GetMedicalHistorySummary(ctx context.Context, encounterID uuid.UUID) (*MedicalHistoryResponse, error) {
	enc, ok := m.encounters[encounterID]
	if !ok {
		return nil, nil
	}
	return &MedicalHistoryResponse{
		EncounterID:  enc.ID,
		Date:         enc.StartedAt,
		Prescription: []MedicalHistoryPrescriptionItem{},
	}, nil
}

type mockUserRepo struct {
	clinicID uuid.UUID
}

func (mu *mockUserRepo) Create(ctx context.Context, user *users.User) error { return nil }
func (mu *mockUserRepo) FindByID(ctx context.Context, id uuid.UUID) (*users.User, error) {
	return &users.User{
		ID:       id,
		Role:     users.RoleDoctor,
		ClinicID: &mu.clinicID,
	}, nil
}
func (mu *mockUserRepo) FindByEmail(ctx context.Context, email string) (*users.User, error) {
	return nil, nil
}
func (mu *mockUserRepo) FindByPhone(ctx context.Context, phone string) (*users.User, error) {
	return nil, nil
}
func (mu *mockUserRepo) FindByLogin(ctx context.Context, login string) (*users.User, error) {
	return nil, nil
}
func (mu *mockUserRepo) UpdateProfile(ctx context.Context, id uuid.UUID, req users.UpdateProfileRequest) (*users.User, error) {
	return nil, nil
}
func (mu *mockUserRepo) UpdatePassword(ctx context.Context, id uuid.UUID, passwordHash string) error {
	return nil
}
func (mu *mockUserRepo) DeleteAccount(ctx context.Context, id uuid.UUID) error { return nil }
func (mu *mockUserRepo) MarkEmailVerified(ctx context.Context, id uuid.UUID) error { return nil }


func TestEncounterService_Lifecycle(t *testing.T) {
	repo := newMockRepository()
	clinicID := uuid.New()
	userRepo := &mockUserRepo{clinicID: clinicID}
	svc := NewService(repo, userRepo)

	doctorID := uuid.New()
	patientID := uuid.New()

	// 1. Open Encounter
	res, err := svc.OpenEncounter(context.Background(), doctorID, patientID)
	if err != nil {
		t.Fatalf("unexpected error opening encounter: %v", err)
	}
	if res.Encounter.Status != StatusOpen {
		t.Errorf("expected status 'open', got '%s'", res.Encounter.Status)
	}

	encounterID := res.Encounter.ID

	// 1b. Try opening second encounter for same patient -> Expect 409 Conflict (open_encounter_exists)
	_, err = svc.OpenEncounter(context.Background(), doctorID, patientID)
	if err == nil {
		t.Fatal("expected error opening second active encounter for patient, got nil")
	}

	// 2. Get Encounter Aggregated
	agg, err := svc.GetEncounterByID(context.Background(), encounterID)
	if err != nil {
		t.Fatalf("unexpected error getting encounter: %v", err)
	}
	if agg.Encounter.ID != encounterID {
		t.Errorf("expected encounter ID %s, got %s", encounterID, agg.Encounter.ID)
	}

	// 3. List Patient Encounters
	list, total, err := svc.ListPatientEncounters(context.Background(), patientID, 1, 10)
	if err != nil {
		t.Fatalf("unexpected error listing encounters: %v", err)
	}
	if total != 1 || len(list) != 1 {
		t.Errorf("expected 1 encounter, got total=%d, len=%d", total, len(list))
	}

	// 4. Close Encounter
	closedRes, err := svc.CloseEncounter(context.Background(), encounterID)
	if err != nil {
		t.Fatalf("unexpected error closing encounter: %v", err)
	}
	if closedRes.Encounter.Status != StatusClosed {
		t.Errorf("expected status 'closed', got '%s'", closedRes.Encounter.Status)
	}

	// 5. Try closing again -> Expect conflict error
	_, err = svc.CloseEncounter(context.Background(), encounterID)
	if err == nil {
		t.Fatal("expected error when closing an already closed encounter, got nil")
	}

	// 6. Get Medical History Summary
	medHist, err := svc.GetMedicalHistory(context.Background(), encounterID)
	if err != nil {
		t.Fatalf("unexpected error getting medical history: %v", err)
	}
	if medHist.EncounterID != encounterID {
		t.Errorf("expected encounter ID %s, got %s", encounterID, medHist.EncounterID)
	}
}
