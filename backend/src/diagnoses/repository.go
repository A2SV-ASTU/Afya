package diagnoses

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
)

type Repository interface {
	Create(ctx context.Context, d *Diagnosis) error
	FindByEncounterID(ctx context.Context, encounterID uuid.UUID) ([]*Diagnosis, error)
}

type postgresRepository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) Repository {
	return &postgresRepository{db: db}
}

func (r *postgresRepository) Create(ctx context.Context, d *Diagnosis) error {
	query := `
		INSERT INTO diagnoses (encounter_id, diagnosis_text, icd_code, diagnosis_type, notes)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, diagnosed_at
	`
	err := r.db.QueryRowContext(
		ctx,
		query,
		d.EncounterID,
		d.DiagnosisText,
		d.ICDCode,
		d.DiagnosisType,
		d.Notes,
	).Scan(&d.ID, &d.DiagnosedAt)
	return err
}

func (r *postgresRepository) FindByEncounterID(ctx context.Context, encounterID uuid.UUID) ([]*Diagnosis, error) {
	query := `
		SELECT id, encounter_id, diagnosis_text, icd_code, diagnosis_type, notes, diagnosed_at
		FROM diagnoses
		WHERE encounter_id = $1
		ORDER BY diagnosed_at ASC
	`
	rows, err := r.db.QueryContext(ctx, query, encounterID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var diagnoses []*Diagnosis
	for rows.Next() {
		var d Diagnosis
		if err := rows.Scan(
			&d.ID,
			&d.EncounterID,
			&d.DiagnosisText,
			&d.ICDCode,
			&d.DiagnosisType,
			&d.Notes,
			&d.DiagnosedAt,
		); err != nil {
			return nil, err
		}
		diagnoses = append(diagnoses, &d)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	if diagnoses == nil {
		diagnoses = []*Diagnosis{}
	}

	return diagnoses, nil
}
