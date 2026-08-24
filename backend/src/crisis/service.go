package crisis

import (
	"context"
	"fmt"

	"github.com/A2SV-ASTU/AfyaMind/backend/src/audit"
	"github.com/google/uuid"
)

// Service encapsulates crisis business logic.
type Service struct {
	repo   *Repository
	logger audit.Logger
}

// NewService creates a new crisis Service.
func NewService(repo *Repository, logger audit.Logger) *Service {
	return &Service{repo: repo, logger: logger}
}

// --- Public operations ---

// ListPublishedResources returns all PUBLISHED crisis resources, ordered by sort_order.
func (s *Service) ListPublishedResources(ctx context.Context) ([]CrisisResource, error) {
	return s.repo.ListPublishedResources(ctx)
}

// CreateEvent records that a user entered the crisis flow.
// When called from POST /crisis-events, source must be "CRISIS_BUTTON".
// When called internally by moods.service, source is "CRISIS_MOOD".
// This is the single entry point for creating crisis events — both HTTP and internal callers use it.
func (s *Service) CreateEvent(ctx context.Context, userID, source string) (*CrisisEvent, error) {
	if source != SourceCrisisButton && source != SourceCrisisMood {
		return nil, fmt.Errorf("invalid source: must be %q or %q", SourceCrisisButton, SourceCrisisMood)
	}

	id := "cev_" + uuid.New().String()[:4]
	event, err := s.repo.CreateEvent(ctx, id, userID, source)
	if err != nil {
		return nil, fmt.Errorf("create crisis event: %w", err)
	}
	return event, nil
}

// --- Admin operations ---

// ListAllResources returns all crisis resources (all statuses) for admin.
func (s *Service) ListAllResources(ctx context.Context) ([]CrisisResource, error) {
	return s.repo.ListAllResources(ctx)
}

// GetResourceByID returns a single crisis resource by ID for admin.
func (s *Service) GetResourceByID(ctx context.Context, id int) (*CrisisResource, error) {
	resource, err := s.repo.GetResourceByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if resource == nil {
		return nil, fmt.Errorf("not_found")
	}
	return resource, nil
}

// CreateResource creates a new crisis resource with status defaulting to DRAFT.
// Automatically creates an audit log entry.
func (s *Service) CreateResource(ctx context.Context, actorID, label, phone string, sortOrder int) (*CrisisResource, error) {
	resource, err := s.repo.CreateResource(ctx, label, phone, sortOrder)
	if err != nil {
		return nil, fmt.Errorf("create resource: %w", err)
	}

	// Audit log
	if s.logger != nil {
		_ = s.logger.Log(ctx, actorID, "CREATE", "CRISIS_RESOURCE", fmt.Sprintf("%d", resource.ID), map[string]interface{}{
			"label": label,
		})
	}

	return resource, nil
}

// UpdateResource updates fields on a crisis resource.
// Automatically creates an audit log entry.
func (s *Service) UpdateResource(ctx context.Context, actorID string, id int, label *string, phone *string, sortOrder *int) (*CrisisResource, error) {
	// Verify resource exists
	existing, err := s.repo.GetResourceByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, fmt.Errorf("not_found")
	}

	resource, err := s.repo.UpdateResource(ctx, id, label, phone, sortOrder)
	if err != nil {
		return nil, fmt.Errorf("update resource: %w", err)
	}

	// Audit log
	if s.logger != nil {
		_ = s.logger.Log(ctx, actorID, "UPDATE", "CRISIS_RESOURCE", fmt.Sprintf("%d", id), nil)
	}

	return resource, nil
}

// UpdateResourceStatus toggles a crisis resource's status (DRAFT ↔ PUBLISHED).
// Automatically creates an audit log entry.
func (s *Service) UpdateResourceStatus(ctx context.Context, actorID string, id int, status string) (*CrisisResource, error) {
	if status != "DRAFT" && status != "PUBLISHED" {
		return nil, fmt.Errorf("validation_error: status must be DRAFT or PUBLISHED")
	}

	existing, err := s.repo.GetResourceByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, fmt.Errorf("not_found")
	}

	resource, err := s.repo.UpdateResourceStatus(ctx, id, status)
	if err != nil {
		return nil, fmt.Errorf("update resource status: %w", err)
	}

	// Audit log — record previous status for traceability
	action := "PUBLISH"
	if status == "DRAFT" {
		action = "UNPUBLISH"
	}
	if s.logger != nil {
		_ = s.logger.Log(ctx, actorID, action, "CRISIS_RESOURCE", fmt.Sprintf("%d", id), map[string]interface{}{
			"previous_status": existing.Status,
		})
	}

	return resource, nil
}

// DeleteResource removes a crisis resource by ID.
// Automatically creates an audit log entry.
func (s *Service) DeleteResource(ctx context.Context, actorID string, id int) error {
	existing, err := s.repo.GetResourceByID(ctx, id)
	if err != nil {
		return err
	}
	if existing == nil {
		return fmt.Errorf("not_found")
	}

	if err := s.repo.DeleteResource(ctx, id); err != nil {
		return fmt.Errorf("delete resource: %w", err)
	}

	// Audit log
	if s.logger != nil {
		_ = s.logger.Log(ctx, actorID, "DELETE", "CRISIS_RESOURCE", fmt.Sprintf("%d", id), map[string]interface{}{
			"label": existing.Label,
		})
	}

	return nil
}

// ListEvents returns crisis events with optional source and user_id filters (admin).
func (s *Service) ListEvents(ctx context.Context, source, userID string) ([]CrisisEvent, error) {
	return s.repo.ListEvents(ctx, source, userID)
}

// GetEventByID returns a single crisis event by ID (admin).
func (s *Service) GetEventByID(ctx context.Context, id string) (*CrisisEvent, error) {
	event, err := s.repo.GetEventByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if event == nil {
		return nil, fmt.Errorf("not_found")
	}
	return event, nil
}
