package diagnoses

import (
	"context"
	"regexp"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
)

func TestPostgresRepository_Create(t *testing.T) {
	db, mock, err := sqlmock.New()
	assert.NoError(t, err)
	defer db.Close()

	repo := NewRepository(db)
	ctx := context.Background()

	t.Run("success", func(t *testing.T) {
		encounterID := uuid.New()
		icd := "J20.9"
		notes := "Patient reports coughing."
		diag := &Diagnosis{
			EncounterID:   encounterID,
			DiagnosisText: "Acute Bronchitis",
			DiagnosisType: "provisional",
			ICDCode:       &icd,
			Notes:         &notes,
		}

		expectedID := uuid.New()
		expectedTime := time.Now()

		mock.ExpectQuery(regexp.QuoteMeta(`INSERT INTO diagnoses`)).
			WithArgs(encounterID, "Acute Bronchitis", &icd, "provisional", &notes).
			WillReturnRows(sqlmock.NewRows([]string{"id", "diagnosed_at"}).AddRow(expectedID, expectedTime))

		createdDiag, err := repo.Create(ctx, diag)
		assert.NoError(t, err)
		assert.NotNil(t, createdDiag)
		assert.Equal(t, expectedID, createdDiag.ID)
		assert.Equal(t, expectedTime, createdDiag.DiagnosedAt)
	})

	t.Run("missing required fields", func(t *testing.T) {
		diag := &Diagnosis{DiagnosisText: ""}
		createdDiag, err := repo.Create(ctx, diag)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "missing required fields")
		assert.Nil(t, createdDiag)
	})
}

func TestPostgresRepository_FindByEncounterID(t *testing.T) {
	db, mock, err := sqlmock.New()
	assert.NoError(t, err)
	defer db.Close()

	repo := NewRepository(db)
	ctx := context.Background()

	t.Run("success", func(t *testing.T) {
		encounterID := uuid.New()
		id := uuid.New()
		diagnosedAt := time.Now()
		icd := "J20.9"
		notes := "Patient reports coughing."

		rows := sqlmock.NewRows([]string{"id", "encounter_id", "diagnosis_text", "icd_code", "diagnosis_type", "notes", "diagnosed_at"}).
			AddRow(id, encounterID, "Acute Bronchitis", &icd, "provisional", &notes, diagnosedAt)

		mock.ExpectQuery(regexp.QuoteMeta(`SELECT id, encounter_id, diagnosis_text, icd_code, diagnosis_type, notes, diagnosed_at FROM diagnoses WHERE encounter_id = $1 ORDER BY diagnosed_at ASC`)).
			WithArgs(encounterID).
			WillReturnRows(rows)

		results, err := repo.FindByEncounterID(ctx, encounterID)
		assert.NoError(t, err)
		assert.Len(t, results, 1)
		assert.Equal(t, "Acute Bronchitis", results[0].DiagnosisText)
	})

	t.Run("empty results", func(t *testing.T) {
		encounterID := uuid.New()
		rows := sqlmock.NewRows([]string{"id", "encounter_id", "diagnosis_text", "icd_code", "diagnosis_type", "notes", "diagnosed_at"})

		mock.ExpectQuery(regexp.QuoteMeta(`SELECT id, encounter_id, diagnosis_text, icd_code, diagnosis_type, notes, diagnosed_at FROM diagnoses WHERE encounter_id = $1 ORDER BY diagnosed_at ASC`)).
			WithArgs(encounterID).
			WillReturnRows(rows)

		results, err := repo.FindByEncounterID(ctx, encounterID)
		assert.NoError(t, err)
		assert.NotNil(t, results)
		assert.Len(t, results, 0)
	})
}
