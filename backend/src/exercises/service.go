package exercises

import (
	"context"
	"fmt"

	"github.com/A2SV-ASTU/AfyaMind/backend/src/audit"
	"github.com/google/uuid"
)

// Service encapsulates exercise business logic.
type Service struct {
	repo   *Repository
	logger audit.Logger
}

// NewService creates a new exercises Service.
func NewService(repo *Repository, logger audit.Logger) *Service {
	return &Service{repo: repo, logger: logger}
}

// --- Public operations ---

// ListPublished returns all PUBLISHED exercises, optionally filtered by language.
func (s *Service) ListPublished(ctx context.Context, language string) ([]Exercise, error) {
	return s.repo.ListPublished(ctx, language)
}

// GetBySlug returns a PUBLISHED exercise with its ordered steps.
func (s *Service) GetBySlug(ctx context.Context, slug string) (*Exercise, []ExerciseStep, error) {
	ex, err := s.repo.GetBySlug(ctx, slug)
	if err != nil {
		return nil, nil, err
	}
	if ex == nil {
		return nil, nil, fmt.Errorf("not_found")
	}
	steps, err := s.repo.ListStepsByExerciseID(ctx, ex.ID)
	if err != nil {
		return nil, nil, err
	}
	return ex, steps, nil
}

// StartExercise creates or resumes an ExerciseCompletion.
func (s *Service) StartExercise(ctx context.Context, userID, exerciseID string) (*ExerciseCompletion, error) {
	// Verify exercise exists and is PUBLISHED
	ex, err := s.repo.GetByID(ctx, exerciseID)
	if err != nil {
		return nil, err
	}
	if ex == nil || ex.Status != "PUBLISHED" {
		return nil, fmt.Errorf("not_found")
	}

	// Resume if already IN_PROGRESS
	existing, err := s.repo.GetInProgressCompletion(ctx, userID, exerciseID)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return existing, nil
	}

	id := "cmp_" + uuid.New().String()[:4]
	return s.repo.CreateCompletion(ctx, id, exerciseID, userID)
}

// UpdateProgress updates progress on the user's in-progress completion.
func (s *Service) UpdateProgress(ctx context.Context, userID, exerciseID string, progress int) (*ExerciseCompletion, error) {
	comp, err := s.repo.GetInProgressCompletion(ctx, userID, exerciseID)
	if err != nil {
		return nil, err
	}
	if comp == nil {
		return nil, fmt.Errorf("not_found")
	}
	return s.repo.UpdateProgress(ctx, comp.ID, progress)
}

// CompleteExercise marks the user's in-progress completion as COMPLETED.
func (s *Service) CompleteExercise(ctx context.Context, userID, exerciseID string) (*ExerciseCompletion, error) {
	comp, err := s.repo.GetInProgressCompletion(ctx, userID, exerciseID)
	if err != nil {
		return nil, err
	}
	if comp == nil {
		return nil, fmt.Errorf("not_found")
	}
	return s.repo.MarkCompleted(ctx, comp.ID)
}

// ListCompletionHistory returns the user's exercise completions.
func (s *Service) ListCompletionHistory(ctx context.Context, userID string) ([]ExerciseCompletion, error) {
	return s.repo.ListCompletionsByUser(ctx, userID)
}

// --- Admin operations ---

// ListAll returns all exercises (all statuses) for admin.
func (s *Service) ListAll(ctx context.Context) ([]Exercise, error) {
	return s.repo.ListAll(ctx)
}

// GetByIDAdmin returns a single exercise (any status) with steps for admin.
func (s *Service) GetByIDAdmin(ctx context.Context, id string) (*Exercise, []ExerciseStep, error) {
	ex, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, nil, err
	}
	if ex == nil {
		return nil, nil, fmt.Errorf("not_found")
	}
	steps, err := s.repo.ListStepsByExerciseID(ctx, ex.ID)
	if err != nil {
		return nil, nil, err
	}
	return ex, steps, nil
}

// CreateExercise creates a new exercise (defaults to DRAFT).
func (s *Service) CreateExercise(ctx context.Context, actorID, slug, title, description, language string) (*Exercise, error) {
	id := "exr_" + uuid.New().String()[:8]
	ex, err := s.repo.Create(ctx, id, slug, title, description, language)
	if err != nil {
		return nil, err
	}
	if s.logger != nil {
		_ = s.logger.Log(ctx, actorID, "CREATE", "EXERCISE", ex.ID, map[string]interface{}{"title": title})
	}
	return ex, nil
}

// UpdateExercise updates fields on an exercise.
func (s *Service) UpdateExercise(ctx context.Context, actorID, id string, slug, title, description, language *string) (*Exercise, error) {
	existing, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, fmt.Errorf("not_found")
	}
	ex, err := s.repo.Update(ctx, id, slug, title, description, language)
	if err != nil {
		return nil, err
	}
	if s.logger != nil {
		_ = s.logger.Log(ctx, actorID, "UPDATE", "EXERCISE", id, nil)
	}
	return ex, nil
}

// UpdateExerciseStatus toggles status between DRAFT and PUBLISHED.
func (s *Service) UpdateExerciseStatus(ctx context.Context, actorID, id, status string) (*Exercise, error) {
	if status != "DRAFT" && status != "PUBLISHED" {
		return nil, fmt.Errorf("validation_error")
	}
	existing, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, fmt.Errorf("not_found")
	}
	ex, err := s.repo.UpdateStatus(ctx, id, status)
	if err != nil {
		return nil, err
	}
	action := "PUBLISH"
	if status == "DRAFT" {
		action = "UNPUBLISH"
	}
	if s.logger != nil {
		_ = s.logger.Log(ctx, actorID, action, "EXERCISE", id, map[string]interface{}{"previous_status": existing.Status})
	}
	return ex, nil
}

// CreateStep adds a step to an exercise.
func (s *Service) CreateStep(ctx context.Context, actorID, exerciseID, stepType, title string, instruction *string, durationSeconds, sortOrder int) (*ExerciseStep, error) {
	existing, err := s.repo.GetByID(ctx, exerciseID)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, fmt.Errorf("not_found")
	}
	id := "stp_" + uuid.New().String()[:4]
	step, err := s.repo.CreateStep(ctx, id, exerciseID, stepType, title, instruction, durationSeconds, sortOrder)
	if err != nil {
		return nil, err
	}
	if s.logger != nil {
		_ = s.logger.Log(ctx, actorID, "CREATE", "EXERCISE", exerciseID, map[string]interface{}{"step_id": id})
	}
	return step, nil
}

// UpdateStep updates fields on a step.
func (s *Service) UpdateStep(ctx context.Context, actorID, id string, stepType, title, instruction *string, durationSeconds, sortOrder *int) (*ExerciseStep, error) {
	existing, err := s.repo.GetStepByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, fmt.Errorf("not_found")
	}
	step, err := s.repo.UpdateStep(ctx, id, stepType, title, instruction, durationSeconds, sortOrder)
	if err != nil {
		return nil, err
	}
	if s.logger != nil {
		_ = s.logger.Log(ctx, actorID, "UPDATE", "EXERCISE", existing.ExerciseID, map[string]interface{}{"step_id": id})
	}
	return step, nil
}

// DeleteStep removes a step.
func (s *Service) DeleteStep(ctx context.Context, actorID, id string) error {
	existing, err := s.repo.GetStepByID(ctx, id)
	if err != nil {
		return err
	}
	if existing == nil {
		return fmt.Errorf("not_found")
	}
	if err := s.repo.DeleteStep(ctx, id); err != nil {
		return err
	}
	if s.logger != nil {
		_ = s.logger.Log(ctx, actorID, "DELETE", "EXERCISE", existing.ExerciseID, map[string]interface{}{"step_id": id})
	}
	return nil
}
