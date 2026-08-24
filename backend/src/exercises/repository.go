package exercises

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"github.com/A2SV-ASTU/AfyaMind/backend/src/database"
)

// Repository handles all exercise, step, and completion database queries.
type Repository struct {
	db database.DBTX
}

// NewRepository creates a new exercises Repository.
func NewRepository(db database.DBTX) *Repository {
	return &Repository{db: db}
}

// --- Exercise Queries ---

// ListPublished returns all PUBLISHED exercises, optionally filtered by language.
func (r *Repository) ListPublished(ctx context.Context, language string) ([]Exercise, error) {
	query := `SELECT id, slug, title, description, language, status, created_at, updated_at
		FROM exercises WHERE status = 'PUBLISHED'`
	args := []interface{}{}
	if language != "" {
		query += ` AND language = $1`
		args = append(args, language)
	}
	query += ` ORDER BY title ASC`

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("list published exercises: %w", err)
	}
	defer rows.Close()
	return scanExercises(rows)
}

// ListAll returns all exercises (all statuses) for admin.
func (r *Repository) ListAll(ctx context.Context) ([]Exercise, error) {
	query := `SELECT id, slug, title, description, language, status, created_at, updated_at
		FROM exercises ORDER BY title ASC`
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("list all exercises: %w", err)
	}
	defer rows.Close()
	return scanExercises(rows)
}

// GetBySlug returns a single PUBLISHED exercise by slug.
func (r *Repository) GetBySlug(ctx context.Context, slug string) (*Exercise, error) {
	query := `SELECT id, slug, title, description, language, status, created_at, updated_at
		FROM exercises WHERE slug = $1 AND status = 'PUBLISHED'`
	return r.scanOneExercise(ctx, query, slug)
}

// GetByID returns a single exercise by ID (any status, for admin).
func (r *Repository) GetByID(ctx context.Context, id string) (*Exercise, error) {
	query := `SELECT id, slug, title, description, language, status, created_at, updated_at
		FROM exercises WHERE id = $1`
	return r.scanOneExercise(ctx, query, id)
}

// Create inserts a new exercise with status defaulting to DRAFT.
func (r *Repository) Create(ctx context.Context, id, slug, title, description, language string) (*Exercise, error) {
	query := `INSERT INTO exercises (id, slug, title, description, language, status, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, 'DRAFT', NOW(), NOW())
		RETURNING id, slug, title, description, language, status, created_at, updated_at`
	return r.scanOneExercise(ctx, query, id, slug, title, description, language)
}

// Update updates fields on an exercise. Only non-nil fields are updated.
func (r *Repository) Update(ctx context.Context, id string, slug, title, description, language *string) (*Exercise, error) {
	setClauses := []string{}
	args := []interface{}{}
	argIdx := 1

	if slug != nil {
		setClauses = append(setClauses, fmt.Sprintf("slug = $%d", argIdx))
		args = append(args, *slug)
		argIdx++
	}
	if title != nil {
		setClauses = append(setClauses, fmt.Sprintf("title = $%d", argIdx))
		args = append(args, *title)
		argIdx++
	}
	if description != nil {
		setClauses = append(setClauses, fmt.Sprintf("description = $%d", argIdx))
		args = append(args, *description)
		argIdx++
	}
	if language != nil {
		setClauses = append(setClauses, fmt.Sprintf("language = $%d", argIdx))
		args = append(args, *language)
		argIdx++
	}
	if len(setClauses) == 0 {
		return r.GetByID(ctx, id)
	}
	setClauses = append(setClauses, "updated_at = NOW()")
	args = append(args, id)

	query := fmt.Sprintf(`UPDATE exercises SET %s WHERE id = $%d
		RETURNING id, slug, title, description, language, status, created_at, updated_at`,
		strings.Join(setClauses, ", "), argIdx)
	return r.scanOneExercise(ctx, query, args...)
}

// UpdateStatus toggles an exercise's status between DRAFT and PUBLISHED.
func (r *Repository) UpdateStatus(ctx context.Context, id, status string) (*Exercise, error) {
	query := `UPDATE exercises SET status = $1, updated_at = NOW() WHERE id = $2
		RETURNING id, slug, title, description, language, status, created_at, updated_at`
	return r.scanOneExercise(ctx, query, status, id)
}

// Delete removes an exercise by ID.
func (r *Repository) Delete(ctx context.Context, id string) error {
	result, err := r.db.ExecContext(ctx, `DELETE FROM exercises WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("delete exercise: %w", err)
	}
	n, _ := result.RowsAffected()
	if n == 0 {
		return fmt.Errorf("not_found")
	}
	return nil
}

// --- Step Queries ---

// ListStepsByExerciseID returns all steps for an exercise, ordered by sort_order.
func (r *Repository) ListStepsByExerciseID(ctx context.Context, exerciseID string) ([]ExerciseStep, error) {
	query := `SELECT id, exercise_id, step_type, title, instruction, duration_seconds, sort_order
		FROM exercise_steps WHERE exercise_id = $1 ORDER BY sort_order ASC`
	rows, err := r.db.QueryContext(ctx, query, exerciseID)
	if err != nil {
		return nil, fmt.Errorf("list steps: %w", err)
	}
	defer rows.Close()

	var steps []ExerciseStep
	for rows.Next() {
		var s ExerciseStep
		if err := rows.Scan(&s.ID, &s.ExerciseID, &s.StepType, &s.Title, &s.Instruction, &s.DurationSeconds, &s.SortOrder); err != nil {
			return nil, fmt.Errorf("scan step: %w", err)
		}
		steps = append(steps, s)
	}
	return steps, rows.Err()
}

// CreateStep inserts a new exercise step.
func (r *Repository) CreateStep(ctx context.Context, id, exerciseID, stepType, title string, instruction *string, durationSeconds, sortOrder int) (*ExerciseStep, error) {
	query := `INSERT INTO exercise_steps (id, exercise_id, step_type, title, instruction, duration_seconds, sort_order)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, exercise_id, step_type, title, instruction, duration_seconds, sort_order`
	var s ExerciseStep
	err := r.db.QueryRowContext(ctx, query, id, exerciseID, stepType, title, instruction, durationSeconds, sortOrder).Scan(
		&s.ID, &s.ExerciseID, &s.StepType, &s.Title, &s.Instruction, &s.DurationSeconds, &s.SortOrder)
	if err != nil {
		return nil, fmt.Errorf("create step: %w", err)
	}
	return &s, nil
}

// UpdateStep updates fields on a step. Only non-nil fields are updated.
func (r *Repository) UpdateStep(ctx context.Context, id string, stepType, title, instruction *string, durationSeconds, sortOrder *int) (*ExerciseStep, error) {
	setClauses := []string{}
	args := []interface{}{}
	argIdx := 1

	if stepType != nil {
		setClauses = append(setClauses, fmt.Sprintf("step_type = $%d", argIdx))
		args = append(args, *stepType)
		argIdx++
	}
	if title != nil {
		setClauses = append(setClauses, fmt.Sprintf("title = $%d", argIdx))
		args = append(args, *title)
		argIdx++
	}
	if instruction != nil {
		setClauses = append(setClauses, fmt.Sprintf("instruction = $%d", argIdx))
		args = append(args, *instruction)
		argIdx++
	}
	if durationSeconds != nil {
		setClauses = append(setClauses, fmt.Sprintf("duration_seconds = $%d", argIdx))
		args = append(args, *durationSeconds)
		argIdx++
	}
	if sortOrder != nil {
		setClauses = append(setClauses, fmt.Sprintf("sort_order = $%d", argIdx))
		args = append(args, *sortOrder)
		argIdx++
	}
	if len(setClauses) == 0 {
		return r.GetStepByID(ctx, id)
	}
	args = append(args, id)
	query := fmt.Sprintf(`UPDATE exercise_steps SET %s WHERE id = $%d
		RETURNING id, exercise_id, step_type, title, instruction, duration_seconds, sort_order`,
		strings.Join(setClauses, ", "), argIdx)

	var s ExerciseStep
	err := r.db.QueryRowContext(ctx, query, args...).Scan(
		&s.ID, &s.ExerciseID, &s.StepType, &s.Title, &s.Instruction, &s.DurationSeconds, &s.SortOrder)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("update step: %w", err)
	}
	return &s, nil
}

// GetStepByID returns a single step by ID.
func (r *Repository) GetStepByID(ctx context.Context, id string) (*ExerciseStep, error) {
	query := `SELECT id, exercise_id, step_type, title, instruction, duration_seconds, sort_order
		FROM exercise_steps WHERE id = $1`
	var s ExerciseStep
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&s.ID, &s.ExerciseID, &s.StepType, &s.Title, &s.Instruction, &s.DurationSeconds, &s.SortOrder)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get step: %w", err)
	}
	return &s, nil
}

// DeleteStep removes a step by ID.
func (r *Repository) DeleteStep(ctx context.Context, id string) error {
	result, err := r.db.ExecContext(ctx, `DELETE FROM exercise_steps WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("delete step: %w", err)
	}
	n, _ := result.RowsAffected()
	if n == 0 {
		return fmt.Errorf("not_found")
	}
	return nil
}

// --- Completion Queries ---

// GetInProgressCompletion returns the user's IN_PROGRESS completion for an exercise, if any.
func (r *Repository) GetInProgressCompletion(ctx context.Context, userID, exerciseID string) (*ExerciseCompletion, error) {
	query := `SELECT id, exercise_id, user_id, progress, status, completed_at, created_at, updated_at
		FROM exercise_completions WHERE user_id = $1 AND exercise_id = $2 AND status = 'IN_PROGRESS'`
	var c ExerciseCompletion
	err := r.db.QueryRowContext(ctx, query, userID, exerciseID).Scan(
		&c.ID, &c.ExerciseID, &c.UserID, &c.Progress, &c.Status, &c.CompletedAt, &c.CreatedAt, &c.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get in-progress completion: %w", err)
	}
	return &c, nil
}

// CreateCompletion inserts a new exercise completion.
func (r *Repository) CreateCompletion(ctx context.Context, id, exerciseID, userID string) (*ExerciseCompletion, error) {
	query := `INSERT INTO exercise_completions (id, exercise_id, user_id, progress, status, created_at, updated_at)
		VALUES ($1, $2, $3, 0, 'IN_PROGRESS', NOW(), NOW())
		RETURNING id, exercise_id, user_id, progress, status, completed_at, created_at, updated_at`
	var c ExerciseCompletion
	err := r.db.QueryRowContext(ctx, query, id, exerciseID, userID).Scan(
		&c.ID, &c.ExerciseID, &c.UserID, &c.Progress, &c.Status, &c.CompletedAt, &c.CreatedAt, &c.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("create completion: %w", err)
	}
	return &c, nil
}

// UpdateProgress updates the progress on an exercise completion.
func (r *Repository) UpdateProgress(ctx context.Context, id string, progress int) (*ExerciseCompletion, error) {
	query := `UPDATE exercise_completions SET progress = $1, updated_at = NOW()
		WHERE id = $2 RETURNING id, exercise_id, user_id, progress, status, completed_at, created_at, updated_at`
	var c ExerciseCompletion
	err := r.db.QueryRowContext(ctx, query, progress, id).Scan(
		&c.ID, &c.ExerciseID, &c.UserID, &c.Progress, &c.Status, &c.CompletedAt, &c.CreatedAt, &c.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("update progress: %w", err)
	}
	return &c, nil
}

// MarkCompleted marks a completion as COMPLETED with a timestamp.
func (r *Repository) MarkCompleted(ctx context.Context, id string) (*ExerciseCompletion, error) {
	query := `UPDATE exercise_completions SET status = 'COMPLETED', completed_at = NOW(), updated_at = NOW()
		WHERE id = $1 RETURNING id, exercise_id, user_id, progress, status, completed_at, created_at, updated_at`
	var c ExerciseCompletion
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&c.ID, &c.ExerciseID, &c.UserID, &c.Progress, &c.Status, &c.CompletedAt, &c.CreatedAt, &c.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("mark completed: %w", err)
	}
	return &c, nil
}

// ListCompletionsByUser returns all completions for a user.
func (r *Repository) ListCompletionsByUser(ctx context.Context, userID string) ([]ExerciseCompletion, error) {
	query := `SELECT id, exercise_id, user_id, progress, status, completed_at, created_at, updated_at
		FROM exercise_completions WHERE user_id = $1 ORDER BY created_at DESC`
	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("list completions: %w", err)
	}
	defer rows.Close()

	var completions []ExerciseCompletion
	for rows.Next() {
		var c ExerciseCompletion
		if err := rows.Scan(&c.ID, &c.ExerciseID, &c.UserID, &c.Progress, &c.Status, &c.CompletedAt, &c.CreatedAt, &c.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan completion: %w", err)
		}
		completions = append(completions, c)
	}
	return completions, rows.Err()
}

// --- Helpers ---

func scanExercises(rows *sql.Rows) ([]Exercise, error) {
	var exercises []Exercise
	for rows.Next() {
		var e Exercise
		if err := rows.Scan(&e.ID, &e.Slug, &e.Title, &e.Description, &e.Language, &e.Status, &e.CreatedAt, &e.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan exercise: %w", err)
		}
		exercises = append(exercises, e)
	}
	return exercises, rows.Err()
}

func (r *Repository) scanOneExercise(ctx context.Context, query string, args ...interface{}) (*Exercise, error) {
	var e Exercise
	err := r.db.QueryRowContext(ctx, query, args...).Scan(
		&e.ID, &e.Slug, &e.Title, &e.Description, &e.Language, &e.Status, &e.CreatedAt, &e.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("scan exercise: %w", err)
	}
	return &e, nil
}
