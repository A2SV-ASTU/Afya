package labs

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
		flag := "normal"
		lab := &LabResult{
			EncounterID:  encounterID,
			TestName:     "Blood Test",
			Category:     "laboratory",
			SummaryNotes: "All good",
			Measurements: map[string]interface{}{"wbc": 5.5},
			Flag:         &flag,
		}

		expectedID := uuid.New()
		expectedTime := time.Now()

		mock.ExpectQuery(regexp.QuoteMeta(`INSERT INTO lab_results`)).
			WithArgs(encounterID, "Blood Test", "laboratory", "All good", sqlmock.AnyArg(), &flag).
			WillReturnRows(sqlmock.NewRows([]string{"id", "created_at"}).AddRow(expectedID, expectedTime))

		createdLab, err := repo.Create(ctx, lab)
		assert.NoError(t, err)
		assert.NotNil(t, createdLab)
		assert.Equal(t, expectedID, createdLab.ID)
		assert.Equal(t, expectedTime, createdLab.CreatedAt)
	})

	t.Run("missing required fields", func(t *testing.T) {
		lab := &LabResult{TestName: ""}
		createdLab, err := repo.Create(ctx, lab)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "missing required fields")
		assert.Nil(t, createdLab)
	})
}

func TestPostgresRepository_FindByEncounterID(t *testing.T) {
	db, mock, err := sqlmock.New()
	assert.NoError(t, err)
	defer db.Close()

	repo := NewRepository(db)
	ctx := context.Background()

	t.Run("success with valid json", func(t *testing.T) {
		encounterID := uuid.New()
		id := uuid.New()
		createdAt := time.Now()
		flag := "normal"

		rows := sqlmock.NewRows([]string{"id", "encounter_id", "test_name", "category", "summary_notes", "measurements", "flag", "created_at"}).
			AddRow(id, encounterID, "Blood Test", "laboratory", "All good", []byte(`{"wbc": 5.5}`), &flag, createdAt)

		mock.ExpectQuery(regexp.QuoteMeta(`SELECT id, encounter_id, test_name, category, summary_notes, measurements, flag, created_at FROM lab_results WHERE encounter_id = $1 ORDER BY created_at ASC`)).
			WithArgs(encounterID).
			WillReturnRows(rows)

		results, err := repo.FindByEncounterID(ctx, encounterID)
		assert.NoError(t, err)
		assert.Len(t, results, 1)
		assert.Equal(t, 5.5, results[0].Measurements["wbc"])
	})

	t.Run("success with null json", func(t *testing.T) {
		encounterID := uuid.New()
		id := uuid.New()
		createdAt := time.Now()

		rows := sqlmock.NewRows([]string{"id", "encounter_id", "test_name", "category", "summary_notes", "measurements", "flag", "created_at"}).
			AddRow(id, encounterID, "Blood Test", "laboratory", "All good", nil, nil, createdAt)

		mock.ExpectQuery(regexp.QuoteMeta(`SELECT id, encounter_id, test_name, category, summary_notes, measurements, flag, created_at FROM lab_results WHERE encounter_id = $1 ORDER BY created_at ASC`)).
			WithArgs(encounterID).
			WillReturnRows(rows)

		results, err := repo.FindByEncounterID(ctx, encounterID)
		assert.NoError(t, err)
		assert.Len(t, results, 1)
		assert.NotNil(t, results[0].Measurements)
		assert.Len(t, results[0].Measurements, 0)
	})

	t.Run("error with invalid json", func(t *testing.T) {
		encounterID := uuid.New()
		id := uuid.New()
		createdAt := time.Now()

		rows := sqlmock.NewRows([]string{"id", "encounter_id", "test_name", "category", "summary_notes", "measurements", "flag", "created_at"}).
			AddRow(id, encounterID, "Blood Test", "laboratory", "All good", []byte(`{invalid}`), nil, createdAt)

		mock.ExpectQuery(regexp.QuoteMeta(`SELECT id, encounter_id, test_name, category, summary_notes, measurements, flag, created_at FROM lab_results WHERE encounter_id = $1 ORDER BY created_at ASC`)).
			WithArgs(encounterID).
			WillReturnRows(rows)

		results, err := repo.FindByEncounterID(ctx, encounterID)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "unmarshal measurements")
		assert.Nil(t, results)
	})
}
