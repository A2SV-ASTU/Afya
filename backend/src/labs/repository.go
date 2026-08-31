package labs

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/google/uuid"
)

type Repository interface {
	Create(ctx context.Context, l *LabResult) error
	FindByEncounterID(ctx context.Context, encounterID uuid.UUID) ([]*LabResult, error)
}

type postgresRepository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Create(ctx context.Context, l *LabResult) error {
	measurementsJSON, err := json.Marshal(l.Measurements)
	if err != nil {
		return err
	}

	query := `
		INSERT INTO lab_results (encounter_id, test_name, category, summary_notes, measurements, flag)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at
	`
	err = r.db.QueryRowContext(
		ctx,
		query,
		l.EncounterID,
		l.TestName,
		l.Category,
		l.SummaryNotes,
		measurementsJSON,
		l.Flag,
	).Scan(&l.ID, &l.CreatedAt)
	return err
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

		if err := json.Unmarshal(measurementsJSON, &l.Measurements); err != nil {
			// If unmarshal fails, set an empty map to avoid panic
			l.Measurements = make(map[string]interface{})
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
