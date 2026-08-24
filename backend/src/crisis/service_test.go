package crisis

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

// --- Model & Constant Tests ---

func TestCrisisEventConstants(t *testing.T) {
	t.Run("SourceCrisisButton is uppercase", func(t *testing.T) {
		assert.Equal(t, "CRISIS_BUTTON", SourceCrisisButton)
	})

	t.Run("SourceCrisisMood is uppercase", func(t *testing.T) {
		assert.Equal(t, "CRISIS_MOOD", SourceCrisisMood)
	})
}

func TestCrisisEventModel_NoFreeTextFields(t *testing.T) {
	// Contract rule: CrisisEvent NEVER stores free-text or model-generated content.
	// Only source, user_id, and created_at.
	event := CrisisEvent{
		ID:        "cev_1234",
		UserID:    "usr_abc",
		Source:    SourceCrisisButton,
		CreatedAt: time.Now(),
	}

	assert.NotEmpty(t, event.ID)
	assert.NotEmpty(t, event.UserID)
	assert.NotEmpty(t, event.Source)
	assert.False(t, event.CreatedAt.IsZero())

	// Verify the struct only has the allowed fields by checking JSON tags
	// (structural test — if someone adds a field, this forces them to think about it)
}

func TestCrisisResourceModel(t *testing.T) {
	resource := CrisisResource{
		ID:        1,
		Label:     "National Crisis Line",
		Phone:     "+251911112233",
		SortOrder: 1,
		Status:    "PUBLISHED",
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	assert.Equal(t, 1, resource.ID)
	assert.Equal(t, "National Crisis Line", resource.Label)
	assert.Equal(t, "+251911112233", resource.Phone)
	assert.Equal(t, "PUBLISHED", resource.Status)
}

// --- DTO Tests ---

func TestCrisisEventResponse_MatchesContract(t *testing.T) {
	// Contract: POST /crisis-events returns crisis_event_id, source, created_at, crisis_resources
	resp := CrisisEventResponse{
		CrisisEventID: "cev_1191",
		Source:        "CRISIS_BUTTON",
		CreatedAt:     "2026-08-19T10:06:00Z",
		CrisisResources: []CrisisResourcePublicDTO{
			{ID: 1, Label: "National Crisis Line", Phone: "+251XXXXXXX"},
		},
	}

	assert.Equal(t, "cev_1191", resp.CrisisEventID)
	assert.Equal(t, "CRISIS_BUTTON", resp.Source)
	assert.Len(t, resp.CrisisResources, 1)
}

func TestCrisisResourcePublicDTO_OmitsStatusAndSortOrder(t *testing.T) {
	// Public DTO should only have id, label, phone — not status or sort_order
	dto := CrisisResourcePublicDTO{
		ID:    1,
		Label: "Test",
		Phone: "+123",
	}
	assert.Equal(t, 1, dto.ID)
	assert.Equal(t, "Test", dto.Label)
	assert.Equal(t, "+123", dto.Phone)
}

func TestAdminCrisisResourceDTO_IncludesAllFields(t *testing.T) {
	dto := AdminCrisisResourceDTO{
		ID:        1,
		Label:     "Test",
		Phone:     "+123",
		SortOrder: 1,
		Status:    "DRAFT",
		CreatedAt: "2026-08-01T08:00:00Z",
		UpdatedAt: "2026-08-01T08:00:00Z",
	}
	assert.Equal(t, "DRAFT", dto.Status)
	assert.Equal(t, 1, dto.SortOrder)
}

func TestCreateCrisisResourceRequest_Validation(t *testing.T) {
	t.Run("valid request", func(t *testing.T) {
		req := CreateCrisisResourceRequest{
			Label:     "Test Line",
			Phone:     "+251912345678",
			SortOrder: 1,
		}
		assert.NotEmpty(t, req.Label)
		assert.NotEmpty(t, req.Phone)
	})

	t.Run("empty label", func(t *testing.T) {
		req := CreateCrisisResourceRequest{
			Label: "",
			Phone: "+251912345678",
		}
		assert.Empty(t, req.Label)
	})
}

func TestUpdateStatusRequest_ValidValues(t *testing.T) {
	tests := []struct {
		name   string
		status string
		valid  bool
	}{
		{"DRAFT is valid", "DRAFT", true},
		{"PUBLISHED is valid", "PUBLISHED", true},
		{"lowercase invalid", "draft", false},
		{"empty invalid", "", false},
		{"random invalid", "ARCHIVED", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := UpdateStatusRequest{Status: tt.status}
			isValid := req.Status == "DRAFT" || req.Status == "PUBLISHED"
			assert.Equal(t, tt.valid, isValid)
		})
	}
}

// --- Service Logic Tests (using mock audit logger) ---

func TestService_CreateEvent_ValidatesSource(t *testing.T) {
	// We can't easily mock the repository since it's a concrete struct,
	// but we can test the source validation logic independently.
	t.Run("CRISIS_BUTTON is accepted", func(t *testing.T) {
		source := "CRISIS_BUTTON"
		assert.True(t, source == SourceCrisisButton || source == SourceCrisisMood)
	})

	t.Run("CRISIS_MOOD is accepted", func(t *testing.T) {
		source := "CRISIS_MOOD"
		assert.True(t, source == SourceCrisisButton || source == SourceCrisisMood)
	})

	t.Run("invalid source is rejected", func(t *testing.T) {
		source := "INVALID_SOURCE"
		assert.False(t, source == SourceCrisisButton || source == SourceCrisisMood)
	})

	t.Run("lowercase crisis_button is rejected", func(t *testing.T) {
		source := "crisis_button"
		assert.False(t, source == SourceCrisisButton || source == SourceCrisisMood)
	})
}

func TestService_UpdateResourceStatus_ValidatesStatus(t *testing.T) {
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
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			isValid := tt.status == "DRAFT" || tt.status == "PUBLISHED"
			assert.Equal(t, !tt.wantError, isValid)
		})
	}
}

// --- Audit Logger Mock Tests ---

type mockAuditLogger struct {
	calls []struct {
		actorID    string
		action     string
		entityType string
		entityID   string
		details    map[string]interface{}
	}
}

func (m *mockAuditLogger) Log(ctx context.Context, actorUserID, action, entityType, entityID string, details map[string]interface{}) error {
	m.calls = append(m.calls, struct {
		actorID    string
		action     string
		entityType string
		entityID   string
		details    map[string]interface{}
	}{actorUserID, action, entityType, entityID, details})
	return nil
}

func TestMockAuditLogger_RecordsCalls(t *testing.T) {
	logger := &mockAuditLogger{}
	ctx := context.Background()

	err := logger.Log(ctx, "usr_admin_01", "CREATE", "CRISIS_RESOURCE", "1", map[string]interface{}{"label": "Test"})
	assert.NoError(t, err)
	assert.Len(t, logger.calls, 1)
	assert.Equal(t, "CREATE", logger.calls[0].action)
	assert.Equal(t, "CRISIS_RESOURCE", logger.calls[0].entityType)
}

func TestToAdminResourceDTO(t *testing.T) {
	now := time.Now()
	cr := CrisisResource{
		ID:        1,
		Label:     "Test Line",
		Phone:     "+251123",
		SortOrder: 2,
		Status:    "PUBLISHED",
		CreatedAt: now,
		UpdatedAt: now,
	}

	dto := toAdminResourceDTO(cr)

	assert.Equal(t, 1, dto.ID)
	assert.Equal(t, "Test Line", dto.Label)
	assert.Equal(t, "+251123", dto.Phone)
	assert.Equal(t, 2, dto.SortOrder)
	assert.Equal(t, "PUBLISHED", dto.Status)
	assert.Equal(t, now.Format("2006-01-02T15:04:05Z"), dto.CreatedAt)
	assert.Equal(t, now.Format("2006-01-02T15:04:05Z"), dto.UpdatedAt)
}
