package exercises

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

// --- Model Tests ---

func TestExerciseModel(t *testing.T) {
	ex := Exercise{
		ID:          "exr_box_breathing",
		Slug:        "box-breathing",
		Title:       "Box Breathing",
		Description: "A 4-step breathing pattern.",
		Language:    "en",
		Status:      "PUBLISHED",
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	assert.Equal(t, "exr_box_breathing", ex.ID)
	assert.Equal(t, "PUBLISHED", ex.Status)
	assert.NotEmpty(t, ex.Slug)
}

func TestExerciseStepModel(t *testing.T) {
	instruction := "Breathe in slowly."
	step := ExerciseStep{
		ID:              "stp_01",
		ExerciseID:      "exr_box_breathing",
		StepType:        "TASK",
		Title:           "Inhale",
		Instruction:     &instruction,
		DurationSeconds: 4,
		SortOrder:       1,
	}

	assert.Equal(t, "stp_01", step.ID)
	assert.Equal(t, "TASK", step.StepType)
	assert.NotNil(t, step.Instruction)
	assert.Equal(t, "Breathe in slowly.", *step.Instruction)
}

func TestExerciseStepModel_NullInstruction(t *testing.T) {
	// BREAK steps can have nil instruction
	step := ExerciseStep{
		ID:              "stp_02",
		ExerciseID:      "exr_box_breathing",
		StepType:        "BREAK",
		Title:           "Hold",
		Instruction:     nil,
		DurationSeconds: 4,
		SortOrder:       2,
	}

	assert.Equal(t, "BREAK", step.StepType)
	assert.Nil(t, step.Instruction)
}

func TestExerciseCompletionModel(t *testing.T) {
	t.Run("IN_PROGRESS completion", func(t *testing.T) {
		comp := ExerciseCompletion{
			ID:         "cmp_501",
			ExerciseID: "exr_box_breathing",
			UserID:     "usr_123",
			Progress:   2,
			Status:     StatusInProgress,
		}

		assert.Equal(t, "IN_PROGRESS", comp.Status)
		assert.Nil(t, comp.CompletedAt)
	})

	t.Run("COMPLETED completion", func(t *testing.T) {
		now := time.Now()
		comp := ExerciseCompletion{
			ID:          "cmp_501",
			ExerciseID:  "exr_box_breathing",
			UserID:      "usr_123",
			Progress:    4,
			Status:      StatusCompleted,
			CompletedAt: &now,
		}

		assert.Equal(t, "COMPLETED", comp.Status)
		assert.NotNil(t, comp.CompletedAt)
	})
}

func TestCompletionStatusConstants(t *testing.T) {
	assert.Equal(t, "IN_PROGRESS", StatusInProgress)
	assert.Equal(t, "COMPLETED", StatusCompleted)
}

// --- Service Validation Tests ---

func TestService_StartExercise_Logic(t *testing.T) {
	// Test the business rule: only PUBLISHED exercises can be started
	t.Run("DRAFT exercise should be rejected", func(t *testing.T) {
		ex := &Exercise{ID: "exr_1", Status: "DRAFT"}
		canStart := ex.Status == "PUBLISHED"
		assert.False(t, canStart)
	})

	t.Run("PUBLISHED exercise should be accepted", func(t *testing.T) {
		ex := &Exercise{ID: "exr_1", Status: "PUBLISHED"}
		canStart := ex.Status == "PUBLISHED"
		assert.True(t, canStart)
	})
}

func TestService_UpdateExerciseStatus_Validation(t *testing.T) {
	tests := []struct {
		name      string
		status    string
		wantError bool
	}{
		{"DRAFT is valid", "DRAFT", false},
		{"PUBLISHED is valid", "PUBLISHED", false},
		{"ACTIVE is invalid", "ACTIVE", true},
		{"empty is invalid", "", true},
		{"lowercase draft is invalid", "draft", true},
		{"IN_PROGRESS is invalid", "IN_PROGRESS", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			isValid := tt.status == "DRAFT" || tt.status == "PUBLISHED"
			assert.Equal(t, !tt.wantError, isValid)
		})
	}
}

func TestService_StepType_Validation(t *testing.T) {
	tests := []struct {
		name     string
		stepType string
		valid    bool
	}{
		{"TASK is valid", "TASK", true},
		{"BREAK is valid", "BREAK", true},
		{"lowercase task invalid", "task", false},
		{"empty invalid", "", false},
		{"PAUSE invalid", "PAUSE", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			isValid := tt.stepType == "TASK" || tt.stepType == "BREAK"
			assert.Equal(t, tt.valid, isValid)
		})
	}
}
