package clinicalevaluations

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/google/uuid"
)

type Repository interface {
	Create(ctx context.Context, eval *ClinicalEvaluation) error
	FindByEncounterID(ctx context.Context, encounterID uuid.UUID) (*ClinicalEvaluation, error)
}

type repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) Repository {
	return &repository{db: db}
}

func (r *repository) Create(ctx context.Context, eval *ClinicalEvaluation) error {
	query := `
		INSERT INTO clinical_evaluations (
			encounter_id, chief_complaint, history_of_present_illness,
			past_admissions, family_history, allergies_notes,
			general_appearance, system_examination, created_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
		RETURNING id, created_at
	`

	var sysExamJSON []byte
	var err error
	if eval.SystemExamination != nil {
		sysExamJSON, err = json.Marshal(eval.SystemExamination)
		if err != nil {
			return fmt.Errorf("failed to marshal system_examination: %w", err)
		}
	}

	var rawSysExam []byte
	err = r.db.QueryRowContext(
		ctx, query,
		eval.EncounterID,
		eval.ChiefComplaint,
		eval.HistoryOfPresentIllness,
		eval.PastAdmissions,
		eval.FamilyHistory,
		eval.AllergiesNotes,
		eval.GeneralAppearance,
		sysExamJSON,
	).Scan(&eval.ID, &eval.CreatedAt)

	if err != nil {
		return fmt.Errorf("failed to insert clinical_evaluation: %w", err)
	}

	if len(rawSysExam) > 0 {
		var parsed interface{}
		_ = json.Unmarshal(rawSysExam, &parsed)
		eval.SystemExamination = parsed
	}

	return nil
}

func (r *repository) FindByEncounterID(ctx context.Context, encounterID uuid.UUID) (*ClinicalEvaluation, error) {
	query := `
		SELECT id, encounter_id, chief_complaint, history_of_present_illness,
		       past_admissions, family_history, allergies_notes,
		       general_appearance, system_examination, created_at
		FROM clinical_evaluations
		WHERE encounter_id = $1
	`

	eval := &ClinicalEvaluation{}
	var pastAdm, familyHist, allergyNotes, genApp sql.NullString
	var rawSysExam []byte

	err := r.db.QueryRowContext(ctx, query, encounterID).Scan(
		&eval.ID,
		&eval.EncounterID,
		&eval.ChiefComplaint,
		&eval.HistoryOfPresentIllness,
		&pastAdm,
		&familyHist,
		&allergyNotes,
		&genApp,
		&rawSysExam,
		&eval.CreatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to scan clinical_evaluation: %w", err)
	}

	if pastAdm.Valid {
		eval.PastAdmissions = &pastAdm.String
	}
	if familyHist.Valid {
		eval.FamilyHistory = &familyHist.String
	}
	if allergyNotes.Valid {
		eval.AllergiesNotes = &allergyNotes.String
	}
	if genApp.Valid {
		eval.GeneralAppearance = &genApp.String
	}
	if len(rawSysExam) > 0 {
		var parsed interface{}
		_ = json.Unmarshal(rawSysExam, &parsed)
		eval.SystemExamination = parsed
	}

	return eval, nil
}
