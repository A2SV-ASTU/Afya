package encounters

import (
	"context"
	"net/http"

	"afyamind-backend/src/shared/errors"
	"afyamind-backend/src/users"

	"github.com/google/uuid"
)

type Service interface {
	OpenEncounter(ctx context.Context, doctorID, patientID uuid.UUID) (*EncounterResponse, error)
	GetEncounterByID(ctx context.Context, id uuid.UUID) (*AggregatedEncounterResponse, error)
	ListPatientEncounters(ctx context.Context, patientID uuid.UUID, page, limit int) ([]Encounter, int, error)
	CloseEncounter(ctx context.Context, id uuid.UUID) (*EncounterResponse, error)
	GetMedicalHistory(ctx context.Context, encounterID uuid.UUID) (*MedicalHistoryResponse, error)
}

type service struct {
	repo     Repository
	userRepo users.Repository
}

func NewService(repo Repository, userRepo users.Repository) Service {
	return &service{
		repo:     repo,
		userRepo: userRepo,
	}
}

func (s *service) OpenEncounter(ctx context.Context, doctorID, patientID uuid.UUID) (*EncounterResponse, error) {
	doctorUser, err := s.userRepo.FindByID(ctx, doctorID)
	if err != nil {
		return nil, errors.ErrInternal("Failed to load doctor profile")
	}
	if doctorUser == nil || doctorUser.ClinicID == nil {
		return nil, errors.ErrForbiddenGrant()
	}

	hasOpen, err := s.repo.HasOpenEncounter(ctx, patientID)
	if err != nil {
		return nil, errors.ErrInternal("Failed to check patient active encounter status")
	}
	if hasOpen {
		return nil, errors.NewAppError(http.StatusConflict, "open_encounter_exists", "Patient already has an active open encounter. Close current encounter first.")
	}

	enc, err := s.repo.Create(ctx, patientID, *doctorUser.ClinicID, doctorID)
	if err != nil {
		return nil, errors.ErrInternal("Failed to create encounter")
	}

	return &EncounterResponse{Encounter: *enc}, nil
}

func (s *service) GetEncounterByID(ctx context.Context, id uuid.UUID) (*AggregatedEncounterResponse, error) {
	agg, err := s.repo.GetAggregatedEncounter(ctx, id)
	if err != nil {
		return nil, errors.ErrInternal("Failed to load aggregated encounter")
	}
	if agg == nil {
		return nil, errors.ErrNotFound("Encounter")
	}

	return agg, nil
}

func (s *service) ListPatientEncounters(ctx context.Context, patientID uuid.UUID, page, limit int) ([]Encounter, int, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	offset := (page - 1) * limit

	encounters, total, err := s.repo.ListByPatientID(ctx, patientID, limit, offset)
	if err != nil {
		return nil, 0, errors.ErrInternal("Failed to list encounters")
	}

	return encounters, total, nil
}

func (s *service) CloseEncounter(ctx context.Context, id uuid.UUID) (*EncounterResponse, error) {
	enc, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return nil, errors.ErrInternal("Failed to lookup encounter")
	}
	if enc == nil {
		return nil, errors.ErrNotFound("Encounter")
	}

	if enc.Status == StatusClosed {
		return nil, errors.NewAppError(http.StatusConflict, "encounter_closed", "Encounter is already closed")
	}

	closed, err := s.repo.CloseEncounter(ctx, id)
	if err != nil {
		return nil, errors.ErrInternal("Failed to close encounter")
	}

	return &EncounterResponse{Encounter: *closed}, nil
}

func (s *service) GetMedicalHistory(ctx context.Context, encounterID uuid.UUID) (*MedicalHistoryResponse, error) {
	medHist, err := s.repo.GetMedicalHistorySummary(ctx, encounterID)
	if err != nil {
		return nil, errors.ErrInternal("Failed to load medical history")
	}
	if medHist == nil {
		return nil, errors.ErrNotFound("Encounter")
	}

	return medHist, nil
}
