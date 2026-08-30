package clinicalevaluations

import (
	"context"
	"testing"
	"time"

	"afyamind-backend/src/encounters"
	appErrors "afyamind-backend/src/shared/errors"

	"github.com/google/uuid"
)

type mockRepository struct {
	evaluations map[uuid.UUID]*ClinicalEvaluation
}

func newMockRepository() *mockRepository {
	return &mockRepository{
		evaluations: make(map[uuid.UUID]*ClinicalEvaluation),
	}
}

func (m *mockRepository) Create(ctx context.Context, eval *ClinicalEvaluation) error {
	eval.ID = uuid.New()
	eval.CreatedAt = time.Now()
	m.evaluations[eval.EncounterID] = eval
	return nil
}

func (m *mockRepository) FindByEncounterID(ctx context.Context, encounterID uuid.UUID) (*ClinicalEvaluation, error) {
	eval, ok := m.evaluations[encounterID]
	if !ok {
		return nil, nil
	}
	return eval, nil
}

type mockEncounterRepo struct {
	encounters map[uuid.UUID]*encounters.Encounter
}

func newMockEncounterRepo() *mockEncounterRepo {
	return &mockEncounterRepo{encounters: make(map[uuid.UUID]*encounters.Encounter)}
}

func (me *mockEncounterRepo) Create(ctx context.Context, patientID, clinicID, doctorID uuid.UUID) (*encounters.Encounter, error) {
	return nil, nil
}

func (me *mockEncounterRepo) FindByID(ctx context.Context, id uuid.UUID) (*encounters.Encounter, error) {
	enc, ok := me.encounters[id]
	if !ok {
		return nil, nil
	}
	return enc, nil
}

func (me *mockEncounterRepo) HasOpenEncounter(ctx context.Context, patientID uuid.UUID) (bool, error) {
	for _, enc := range me.encounters {
		if enc.PatientID == patientID && enc.Status == encounters.StatusOpen {
			return true, nil
		}
	}
	return false, nil
}

func (me *mockEncounterRepo) ListByPatientID(ctx context.Context, patientID uuid.UUID, limit, offset int) ([]encounters.Encounter, int, error) {
	return nil, 0, nil
}

func (me *mockEncounterRepo) CloseEncounter(ctx context.Context, id uuid.UUID) (*encounters.Encounter, error) {
	return nil, nil
}

func (me *mockEncounterRepo) GetAggregatedEncounter(ctx context.Context, id uuid.UUID) (*encounters.AggregatedEncounterResponse, error) {
	return nil, nil
}

func (me *mockEncounterRepo) GetMedicalHistorySummary(ctx context.Context, encounterID uuid.UUID) (*encounters.MedicalHistoryResponse, error) {
	return nil, nil
}

func TestClinicalEvaluations_Lifecycle(t *testing.T) {
	repo := newMockRepository()
	encRepo := newMockEncounterRepo()
	svc := NewService(repo, encRepo)

	openEncounterID := uuid.New()
	encRepo.encounters[openEncounterID] = &encounters.Encounter{
		ID:     openEncounterID,
		Status: encounters.StatusOpen,
	}

	closedEncounterID := uuid.New()
	encRepo.encounters[closedEncounterID] = &encounters.Encounter{
		ID:     closedEncounterID,
		Status: encounters.StatusClosed,
	}

	// 1. Create evaluation for open encounter -> Success
	req := CreateClinicalEvaluationRequest{
		ChiefComplaint:          "Severe headache",
		HistoryOfPresentIllness: "Started 2 days ago",
	}
	res, err := svc.CreateEvaluation(context.Background(), openEncounterID, req)
	if err != nil {
		t.Fatalf("unexpected error creating evaluation: %v", err)
	}
	if res.ClinicalEvaluation.ChiefComplaint != "Severe headache" {
		t.Errorf("expected chief_complaint 'Severe headache', got '%s'", res.ClinicalEvaluation.ChiefComplaint)
	}

	// 2. Try creating duplicate evaluation -> Expect 409 conflict (clinical_evaluation_already_exists)
	_, err = svc.CreateEvaluation(context.Background(), openEncounterID, req)
	if err == nil {
		t.Fatal("expected error creating duplicate evaluation, got nil")
	}
	appErr, ok := err.(*appErrors.AppError)
	if !ok || appErr.Code != "clinical_evaluation_already_exists" {
		t.Errorf("expected code 'clinical_evaluation_already_exists', got '%v'", err)
	}

	// 3. Try creating evaluation for closed encounter -> Expect 409 conflict (encounter_closed)
	_, err = svc.CreateEvaluation(context.Background(), closedEncounterID, req)
	if err == nil {
		t.Fatal("expected error creating evaluation for closed encounter, got nil")
	}
	appErr, ok = err.(*appErrors.AppError)
	if !ok || appErr.Code != "encounter_closed" {
		t.Errorf("expected code 'encounter_closed', got '%v'", err)
	}

	// 4. Get evaluation -> Success
	getRes, err := svc.GetEvaluation(context.Background(), openEncounterID)
	if err != nil {
		t.Fatalf("unexpected error getting evaluation: %v", err)
	}
	if getRes.ClinicalEvaluation.EncounterID != openEncounterID {
		t.Errorf("expected encounter ID %s, got %s", openEncounterID, getRes.ClinicalEvaluation.EncounterID)
	}

	// 5. Get missing evaluation -> Expect 404 not found (clinical_evaluation_not_found)
	_, err = svc.GetEvaluation(context.Background(), uuid.New())
	if err == nil {
		t.Fatal("expected error getting missing evaluation, got nil")
	}
	appErr, ok = err.(*appErrors.AppError)
	if !ok || appErr.Code != "clinical_evaluation_not_found" {
		t.Errorf("expected code 'clinical_evaluation_not_found', got '%v'", err)
	}
}
