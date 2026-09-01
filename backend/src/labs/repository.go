package labs

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
)

type Repository interface {
	Create(ctx context.Context, l *LabResult) (*LabResult, error)
	FindByEncounterID(ctx context.Context, encounterID uuid.UUID) ([]*LabResult, error)
}

type postgresRepository struct {
	db *sql.DB
}

// NewRepository creates a new repository. In tests, use sqlmock with *sql.DB.
func NewRepository(db *sql.DB) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Create(ctx context.Context, l *LabResult) (*LabResult, error) {
	if l.EncounterID == uuid.Nil || l.TestName == "" || l.Category == "" {
		return nil, fmt.Errorf("invalid lab result: missing required fields")
	}

	measurementsJSON, err := json.Marshal(l.Measurements)
	if err != nil {
		return nil, fmt.Errorf("marshal lab measurements: %w", err)
	}

	query := `
		INSERT INTO lab_results (encounter_id, test_name, category, summary_notes, measurements, flag)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at
	`
	var id uuid.UUID
	var createdAt time.Time
	err = r.db.QueryRowContext(
		ctx,
		query,
		l.EncounterID,
		l.TestName,
		l.Category,
		l.SummaryNotes,
		measurementsJSON,
		l.Flag,
	).Scan(&id, &createdAt)

	if err != nil {
		return nil, fmt.Errorf("insert lab_result: %w", err)
	}

	l.ID = id
	l.CreatedAt = createdAt
	return l, nil
}

func (r *postgresRepository) FindByEncounterID(ctx context.Context, encounterID uuid.UUID) ([]*LabResult, error) {
	query := `
		SELECT id, encounter_id, test_name, category, summary_notes, measurements, flag, created_at
		FROM lab_results
		WHERE encounter_id = $1
		ORDER BY created_at ASC
	`
	rows, err := r.db.QueryContext(ctx, query, encounterID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*LabResult
	for rows.Next() {
		var l LabResult
		var measurementsJSON []byte
		if err := rows.Scan(
			&l.ID,
			&l.EncounterID,
			&l.TestName,
			&l.Category,
			&l.SummaryNotes,
			&measurementsJSON,
			&l.Flag,
			&l.CreatedAt,
		); err != nil {
			return nil, err
		}

		if measurementsJSON == nil {
			l.Measurements = map[string]interface{}{}
		} else {
			if err := json.Unmarshal(measurementsJSON, &l.Measurements); err != nil {
				return nil, fmt.Errorf("unmarshal measurements for lab_result id %v: %w", l.ID, err)
			}
		}

		results = append(results, &l)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	if results == nil {
		results = []*LabResult{}
	}

	return results, nil
}
