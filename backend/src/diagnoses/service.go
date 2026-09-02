package diagnoses

import (
	"context"
	"database/sql"
	"errors"
	"log"

	appErrors "afyamind-backend/src/shared/errors"
	"github.com/google/uuid"
)

type Service interface {
	CreateDiagnosis(ctx context.Context, encounterID uuid.UUID, req CreateDiagnosisRequest) (*Diagnosis, *appErrors.AppError)
	GetEncounterDiagnoses(ctx context.Context, encounterID uuid.UUID) ([]*Diagnosis, *appErrors.AppError)
}

type service struct {
	db   *sql.DB
	repo Repository
}

func NewService(db *sql.DB, repo Repository) Service {
	return &service{
		db:   db,
		repo: repo,
	}
}

func (s *service) checkEncounterStatus(ctx context.Context, encounterID uuid.UUID) *appErrors.AppError {
	var status string
	err := s.db.QueryRowContext(ctx, "SELECT status FROM encounters WHERE id = $1", encounterID).Scan(&status)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return appErrors.ErrNotFound("Encounter not found")
		}
		log.Printf("ERROR: checkEncounterStatus failed for encounter %s: %v", encounterID, err)
		return appErrors.ErrInternal("Database error checking encounter status")
	}

	if status == "closed" {
		return appErrors.ErrConflict("Encounter is closed")
	}
	return nil
}

func (s *service) CreateDiagnosis(ctx context.Context, encounterID uuid.UUID, req CreateDiagnosisRequest) (*Diagnosis, *appErrors.AppError) {
	if err := s.checkEncounterStatus(ctx, encounterID); err != nil {
		return nil, err
	}

	d := &Diagnosis{
		EncounterID:   encounterID,
		DiagnosisText: req.DiagnosisText,
		DiagnosisType: req.DiagnosisType,
	}

	if req.ICDCode != "" {
		d.ICDCode = &req.ICDCode
	}
	if req.Notes != "" {
		d.Notes = &req.Notes
	}

	createdDiagnosis, err := s.repo.Create(ctx, d)
	if err != nil {
		log.Printf("ERROR: CreateDiagnosis failed for encounter %s: %v", encounterID, err)
		return nil, appErrors.ErrInternal("Failed to create diagnosis")
	}

	return createdDiagnosis, nil
}

func (s *service) GetEncounterDiagnoses(ctx context.Context, encounterID uuid.UUID) ([]*Diagnosis, *appErrors.AppError) {
	// First check if encounter exists
	var exists bool
	err := s.db.QueryRowContext(ctx, "SELECT EXISTS(SELECT 1 FROM encounters WHERE id = $1)", encounterID).Scan(&exists)
	if err != nil {
		log.Printf("ERROR: GetEncounterDiagnoses encounter check failed for %s: %v", encounterID, err)
		return nil, appErrors.ErrInternal("Database error checking encounter")
	}
	if !exists {
		return nil, appErrors.ErrNotFound("Encounter not found")
	}

	diagnoses, err := s.repo.FindByEncounterID(ctx, encounterID)
	if err != nil {
		log.Printf("ERROR: FindByEncounterID failed for encounter %s: %v", encounterID, err)
		return nil, appErrors.ErrInternal("Failed to fetch diagnoses")
	}

	return diagnoses, nil
}

