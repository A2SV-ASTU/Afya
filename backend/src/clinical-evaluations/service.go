package clinicalevaluations

import (
	"context"
	"net/http"

	"afyamind-backend/src/encounters"
	"afyamind-backend/src/shared/errors"

	"github.com/google/uuid"
)

type Service interface {
	CreateEvaluation(ctx context.Context, encounterID uuid.UUID, req CreateClinicalEvaluationRequest) (*ClinicalEvaluationResponse, error)
	GetEvaluation(ctx context.Context, encounterID uuid.UUID) (*ClinicalEvaluationResponse, error)
}

type service struct {
	repo    Repository
	encRepo encounters.Repository
}

func NewService(repo Repository, encRepo encounters.Repository) Service {
	return &service{
		repo:    repo,
		encRepo: encRepo,
	}
}

func (s *service) CreateEvaluation(ctx context.Context, encounterID uuid.UUID, req CreateClinicalEvaluationRequest) (*ClinicalEvaluationResponse, error) {
	enc, err := s.encRepo.FindByID(ctx, encounterID)
	if err != nil {
		return nil, errors.ErrInternal("Failed to check encounter")
	}
	if enc == nil {
		return nil, errors.ErrNotFound("Encounter")
	}

	if enc.Status == encounters.StatusClosed {
		return nil, errors.NewAppError(http.StatusConflict, "encounter_closed", "Cannot add clinical evaluation to a closed encounter")
	}

	existing, err := s.repo.FindByEncounterID(ctx, encounterID)
	if err != nil {
		return nil, errors.ErrInternal("Failed to check existing evaluation")
	}
	if existing != nil {
		return nil, errors.NewAppError(http.StatusConflict, "clinical_evaluation_already_exists", "Clinical evaluation already exists for this encounter")
	}

	eval := &ClinicalEvaluation{
		EncounterID:             encounterID,
		ChiefComplaint:          req.ChiefComplaint,
		HistoryOfPresentIllness: req.HistoryOfPresentIllness,
		PastAdmissions:          req.PastAdmissions,
		FamilyHistory:           req.FamilyHistory,
		AllergiesNotes:          req.AllergiesNotes,
		GeneralAppearance:       req.GeneralAppearance,
		SystemExamination:       req.SystemExamination,
	}

	if err := s.repo.Create(ctx, eval); err != nil {
		return nil, errors.ErrInternal("Failed to create clinical evaluation")
	}

	return &ClinicalEvaluationResponse{ClinicalEvaluation: *eval}, nil
}

func (s *service) GetEvaluation(ctx context.Context, encounterID uuid.UUID) (*ClinicalEvaluationResponse, error) {
	eval, err := s.repo.FindByEncounterID(ctx, encounterID)
	if err != nil {
		return nil, errors.ErrInternal("Failed to load clinical evaluation")
	}
	if eval == nil {
		return nil, errors.NewAppError(http.StatusNotFound, "clinical_evaluation_not_found", "Clinical evaluation not found")
	}

	return &ClinicalEvaluationResponse{ClinicalEvaluation: *eval}, nil
}
