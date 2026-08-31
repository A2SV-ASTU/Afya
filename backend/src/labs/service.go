package labs

import (
	"context"
	"database/sql"
	"errors"

	appErrors "afyamind-backend/src/shared/errors"
	"github.com/google/uuid"
)

type Service interface {
	CreateLabResult(ctx context.Context, encounterID uuid.UUID, req CreateLabResultRequest) (*LabResult, *appErrors.AppError)
	GetEncounterLabResults(ctx context.Context, encounterID uuid.UUID) ([]*LabResult, *appErrors.AppError)
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
		return appErrors.ErrInternal("Database error checking encounter status")
	}

	if status == "closed" {
		return appErrors.ErrConflict("Encounter is closed")
	}
	return nil
}

func (s *service) CreateLabResult(ctx context.Context, encounterID uuid.UUID, req CreateLabResultRequest) (*LabResult, *appErrors.AppError) {
	if err := s.checkEncounterStatus(ctx, encounterID); err != nil {
		return nil, err
	}

	l := &LabResult{
		EncounterID:  encounterID,
		TestName:     req.TestName,
		Category:     req.Category,
		SummaryNotes: req.SummaryNotes,
	}

	if req.Measurements != nil {
		l.Measurements = req.Measurements
	} else {
		l.Measurements = make(map[string]interface{})
	}

	if req.Flag != "" {
		l.Flag = &req.Flag
	}

	if err := s.repo.Create(ctx, l); err != nil {
		return nil, appErrors.ErrInternal("Failed to create lab result")
	}

	return l, nil
}

func (s *service) GetEncounterLabResults(ctx context.Context, encounterID uuid.UUID) ([]*LabResult, *appErrors.AppError) {
	// First check if encounter exists
	var exists bool
	err := s.db.QueryRowContext(ctx, "SELECT EXISTS(SELECT 1 FROM encounters WHERE id = $1)", encounterID).Scan(&exists)
	if err != nil {
		return nil, appErrors.ErrInternal("Database error checking encounter")
	}
	if !exists {
		return nil, appErrors.ErrNotFound("Encounter not found")
	}

	results, err := s.repo.FindByEncounterID(ctx, encounterID)
	if err != nil {
		return nil, appErrors.ErrInternal("Failed to fetch lab results")
	}

	return results, nil
}
