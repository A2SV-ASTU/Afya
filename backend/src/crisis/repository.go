package crisis

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"github.com/A2SV-ASTU/AfyaMind/backend/src/database"
)

// Repository handles all crisis_resource and crisis_event database queries.
type Repository struct {
	db database.DBTX
}

// NewRepository creates a new crisis Repository.
func NewRepository(db database.DBTX) *Repository {
	return &Repository{db: db}
}

// WithTx returns a new Repository that uses the given transaction.
func (r *Repository) WithTx(tx database.DBTX) *Repository {
	return &Repository{db: tx}
}

// --- Crisis Resource Queries ---

// ListPublishedResources returns all PUBLISHED crisis resources ordered by sort_order.
func (r *Repository) ListPublishedResources(ctx context.Context) ([]CrisisResource, error) {
	query := `
		SELECT id, label, phone, sort_order, status, created_at, updated_at
		FROM crisis_resources
		WHERE status = 'PUBLISHED'
		ORDER BY sort_order ASC
	`
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("list published resources: %w", err)
	}
	defer rows.Close()

	var resources []CrisisResource
	for rows.Next() {
		var cr CrisisResource
		if err := rows.Scan(&cr.ID, &cr.Label, &cr.Phone, &cr.SortOrder, &cr.Status, &cr.CreatedAt, &cr.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan resource: %w", err)
		}
		resources = append(resources, cr)
	}
	return resources, rows.Err()
}

// ListAllResources returns all crisis resources (all statuses) for admin.
func (r *Repository) ListAllResources(ctx context.Context) ([]CrisisResource, error) {
	query := `
		SELECT id, label, phone, sort_order, status, created_at, updated_at
		FROM crisis_resources
		ORDER BY sort_order ASC
	`
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("list all resources: %w", err)
	}
	defer rows.Close()

	var resources []CrisisResource
	for rows.Next() {
		var cr CrisisResource
		if err := rows.Scan(&cr.ID, &cr.Label, &cr.Phone, &cr.SortOrder, &cr.Status, &cr.CreatedAt, &cr.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan resource: %w", err)
		}
		resources = append(resources, cr)
	}
	return resources, rows.Err()
}

// GetResourceByID returns a single crisis resource by ID.
func (r *Repository) GetResourceByID(ctx context.Context, id int) (*CrisisResource, error) {
	query := `
		SELECT id, label, phone, sort_order, status, created_at, updated_at
		FROM crisis_resources
		WHERE id = $1
	`
	var cr CrisisResource
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&cr.ID, &cr.Label, &cr.Phone, &cr.SortOrder, &cr.Status, &cr.CreatedAt, &cr.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get resource by id: %w", err)
	}
	return &cr, nil
}

// CreateResource inserts a new crisis resource with status defaulting to DRAFT.
func (r *Repository) CreateResource(ctx context.Context, label, phone string, sortOrder int) (*CrisisResource, error) {
	query := `
		INSERT INTO crisis_resources (label, phone, sort_order, status, created_at, updated_at)
		VALUES ($1, $2, $3, 'DRAFT', NOW(), NOW())
		RETURNING id, label, phone, sort_order, status, created_at, updated_at
	`
	var cr CrisisResource
	err := r.db.QueryRowContext(ctx, query, label, phone, sortOrder).Scan(
		&cr.ID, &cr.Label, &cr.Phone, &cr.SortOrder, &cr.Status, &cr.CreatedAt, &cr.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("create resource: %w", err)
	}
	return &cr, nil
}

// UpdateResource updates fields on a crisis resource. Only non-nil fields are updated.
func (r *Repository) UpdateResource(ctx context.Context, id int, label *string, phone *string, sortOrder *int) (*CrisisResource, error) {
	setClauses := []string{}
	args := []interface{}{}
	argIdx := 1

	if label != nil {
		setClauses = append(setClauses, fmt.Sprintf("label = $%d", argIdx))
		args = append(args, *label)
		argIdx++
	}
	if phone != nil {
		setClauses = append(setClauses, fmt.Sprintf("phone = $%d", argIdx))
		args = append(args, *phone)
		argIdx++
	}
	if sortOrder != nil {
		setClauses = append(setClauses, fmt.Sprintf("sort_order = $%d", argIdx))
		args = append(args, *sortOrder)
		argIdx++
	}

	if len(setClauses) == 0 {
		return r.GetResourceByID(ctx, id)
	}

	setClauses = append(setClauses, "updated_at = NOW()")
	args = append(args, id)

	query := fmt.Sprintf(`
		UPDATE crisis_resources
		SET %s
		WHERE id = $%d
		RETURNING id, label, phone, sort_order, status, created_at, updated_at
	`, strings.Join(setClauses, ", "), argIdx)

	var cr CrisisResource
	err := r.db.QueryRowContext(ctx, query, args...).Scan(
		&cr.ID, &cr.Label, &cr.Phone, &cr.SortOrder, &cr.Status, &cr.CreatedAt, &cr.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("update resource: %w", err)
	}
	return &cr, nil
}

// UpdateResourceStatus toggles a crisis resource's status between DRAFT and PUBLISHED.
func (r *Repository) UpdateResourceStatus(ctx context.Context, id int, status string) (*CrisisResource, error) {
	query := `
		UPDATE crisis_resources
		SET status = $1, updated_at = NOW()
		WHERE id = $2
		RETURNING id, label, phone, sort_order, status, created_at, updated_at
	`
	var cr CrisisResource
	err := r.db.QueryRowContext(ctx, query, status, id).Scan(
		&cr.ID, &cr.Label, &cr.Phone, &cr.SortOrder, &cr.Status, &cr.CreatedAt, &cr.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("update resource status: %w", err)
	}
	return &cr, nil
}

// DeleteResource removes a crisis resource by ID.
func (r *Repository) DeleteResource(ctx context.Context, id int) error {
	query := `DELETE FROM crisis_resources WHERE id = $1`
	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("delete resource: %w", err)
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("delete resource rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("resource not found")
	}
	return nil
}

// --- Crisis Event Queries ---

// CreateEvent inserts a new crisis event. Called both from POST /crisis-events
// and internally by moods.service for CRISIS_MOOD.
func (r *Repository) CreateEvent(ctx context.Context, id, userID, source string) (*CrisisEvent, error) {
	query := `
		INSERT INTO crisis_events (id, user_id, source, created_at)
		VALUES ($1, $2, $3, NOW())
		RETURNING id, user_id, source, created_at
	`
	var ce CrisisEvent
	err := r.db.QueryRowContext(ctx, query, id, userID, source).Scan(
		&ce.ID, &ce.UserID, &ce.Source, &ce.CreatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("create event: %w", err)
	}
	return &ce, nil
}

// ListEvents returns crisis events with optional filtering by source and user_id.
func (r *Repository) ListEvents(ctx context.Context, source, userID string) ([]CrisisEvent, error) {
	query := `SELECT id, user_id, source, created_at FROM crisis_events WHERE 1=1`
	args := []interface{}{}
	argIdx := 1

	if source != "" {
		query += fmt.Sprintf(" AND source = $%d", argIdx)
		args = append(args, source)
		argIdx++
	}
	if userID != "" {
		query += fmt.Sprintf(" AND user_id = $%d", argIdx)
		args = append(args, userID)
		argIdx++
	}

	query += " ORDER BY created_at DESC"

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("list events: %w", err)
	}
	defer rows.Close()

	var events []CrisisEvent
	for rows.Next() {
		var ce CrisisEvent
		if err := rows.Scan(&ce.ID, &ce.UserID, &ce.Source, &ce.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan event: %w", err)
		}
		events = append(events, ce)
	}
	return events, rows.Err()
}

// GetEventByID returns a single crisis event by ID.
func (r *Repository) GetEventByID(ctx context.Context, id string) (*CrisisEvent, error) {
	query := `SELECT id, user_id, source, created_at FROM crisis_events WHERE id = $1`
	var ce CrisisEvent
	err := r.db.QueryRowContext(ctx, query, id).Scan(&ce.ID, &ce.UserID, &ce.Source, &ce.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get event by id: %w", err)
	}
	return &ce, nil
}
