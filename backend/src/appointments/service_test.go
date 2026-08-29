package appointments

import (
	"context"
	"errors"
	"testing"
	"time"

	accessrequests "afyamind-backend/src/access-requests"
	"afyamind-backend/src/shared/auth"
	sharedErr "afyamind-backend/src/shared/errors"
	"github.com/google/uuid"
)

type mockARRepo struct {
	accessrequests.Repository
	err error
}

func (m *mockARRepo) FindActiveGrant(ctx context.Context, clinicID, patientID uuid.UUID) (*accessrequests.AccessRequest, error) {
	if m.err != nil {
		return nil, m.err
	}
	return nil, nil // Error check is what matters
}

type mockRepository struct {
	appointments []Appointment
	err          error
}

func (m *mockRepository) Create(ctx context.Context, appt *Appointment) error {
	if m.err != nil {
		return m.err
	}
	m.appointments = append(m.appointments, *appt)
	return nil
}

func (m *mockRepository) FindByPatientID(ctx context.Context, patientID uuid.UUID, status *AppointmentStatus) ([]Appointment, error) {
	if m.err != nil {
		return nil, m.err
	}
	var result []Appointment
	for _, a := range m.appointments {
		if a.PatientID == patientID && (status == nil || a.Status == *status) {
			result = append(result, a)
		}
	}
	return result, nil
}

func TestCreateAppointment(t *testing.T) {
	clinicID := uuid.New()
	doctorID := uuid.New()
	patientID := uuid.New()
	dbErr := errors.New("db error")

	req := CreateAppointmentRequest{
		PatientID:   patientID,
		ScheduledAt: time.Now().Add(24 * time.Hour),
	}

	tests := []struct {
		name          string
		user          *auth.UserContext
		mockRepo      *mockRepository
		mockAR        *mockARRepo
		expectedError error
	}{
		{
			name:          "doctor successfully creating appointment",
			user:          &auth.UserContext{ID: doctorID, Role: "doctor", ClinicID: &clinicID},
			mockRepo:      &mockRepository{},
			mockAR:        &mockARRepo{},
			expectedError: nil,
		},
		{
			name:          "doctor creating without access grant",
			user:          &auth.UserContext{ID: doctorID, Role: "doctor", ClinicID: &clinicID},
			mockRepo:      &mockRepository{},
			mockAR:        &mockARRepo{err: errors.New("no grant")},
			expectedError: sharedErr.ErrForbiddenGrant(),
		},
		{
			name:          "doctor missing clinic ID",
			user:          &auth.UserContext{ID: doctorID, Role: "doctor", ClinicID: nil},
			mockRepo:      &mockRepository{},
			mockAR:        &mockARRepo{},
			expectedError: sharedErr.ErrForbiddenRole(),
		},
		{
			name:          "patient attempting to schedule",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			mockRepo:      &mockRepository{},
			mockAR:        &mockARRepo{},
			expectedError: sharedErr.ErrForbiddenRole(),
		},
		{
			name:          "clinic admin attempting to schedule",
			user:          &auth.UserContext{Role: "clinic_admin", ClinicID: &clinicID},
			mockRepo:      &mockRepository{},
			mockAR:        &mockARRepo{},
			expectedError: sharedErr.ErrForbiddenRole(),
		},
		{
			name:          "database error on create",
			user:          &auth.UserContext{ID: doctorID, Role: "doctor", ClinicID: &clinicID},
			mockRepo:      &mockRepository{err: dbErr},
			mockAR:        &mockARRepo{},
			expectedError: dbErr,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := NewService(tt.mockRepo, tt.mockAR)
			appt, err := svc.CreateAppointment(context.Background(), tt.user, req)
			if (err != nil && tt.expectedError == nil) || (err == nil && tt.expectedError != nil) || (err != nil && tt.expectedError != nil && err.Error() != tt.expectedError.Error()) {
				t.Errorf("expected error %v, got %v", tt.expectedError, err)
			}
			if err == nil {
				if appt.PatientID != patientID {
					t.Errorf("expected patient ID %v, got %v", patientID, appt.PatientID)
				}
				if appt.Status != StatusScheduled {
					t.Errorf("expected status %s, got %s", StatusScheduled, appt.Status)
				}
				if appt.ClinicID != *tt.user.ClinicID {
					t.Errorf("expected clinic ID from user context")
				}
				if appt.DoctorID != tt.user.ID {
					t.Errorf("expected doctor ID from user context")
				}
			}
		})
	}
}

func TestGetPatientAppointments(t *testing.T) {
	patientID := uuid.New()
	otherPatientID := uuid.New()
	dbErr := errors.New("db error")

	scheduledStatus := StatusScheduled
	cancelledStatus := StatusCancelled

	seedAppointments := []Appointment{
		{ID: uuid.New(), PatientID: patientID, Status: StatusScheduled},
		{ID: uuid.New(), PatientID: patientID, Status: StatusCancelled},
		{ID: uuid.New(), PatientID: otherPatientID, Status: StatusScheduled},
	}

	tests := []struct {
		name          string
		user          *auth.UserContext
		mockRepo      *mockRepository
		patientQuery  uuid.UUID
		statusFilter  *AppointmentStatus
		expectedError error
		expectedCount int
	}{
		{
			name:          "patient gets own appointments (no filter)",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			mockRepo:      &mockRepository{appointments: seedAppointments},
			patientQuery:  patientID,
			statusFilter:  nil,
			expectedError: nil,
			expectedCount: 2,
		},
		{
			name:          "patient gets own appointments (with filter)",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			mockRepo:      &mockRepository{appointments: seedAppointments},
			patientQuery:  patientID,
			statusFilter:  &scheduledStatus,
			expectedError: nil,
			expectedCount: 1,
		},
		{
			name:          "patient filtering by empty result",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			mockRepo:      &mockRepository{appointments: seedAppointments},
			patientQuery:  patientID,
			statusFilter:  &cancelledStatus,
			expectedError: nil,
			expectedCount: 1,
		},
		{
			name:          "patient attempting to get another's appointments",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			mockRepo:      &mockRepository{appointments: seedAppointments},
			patientQuery:  otherPatientID,
			statusFilter:  nil,
			expectedError: sharedErr.ErrForbiddenRole(),
			expectedCount: 0,
		},
		{
			name:          "doctor gets patient appointments (grant guard happens in route layer)",
			user:          &auth.UserContext{ID: uuid.New(), Role: "doctor"},
			mockRepo:      &mockRepository{appointments: seedAppointments},
			patientQuery:  patientID,
			statusFilter:  nil,
			expectedError: nil,
			expectedCount: 2,
		},
		{
			name:          "database error",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			mockRepo:      &mockRepository{err: dbErr},
			patientQuery:  patientID,
			statusFilter:  nil,
			expectedError: dbErr,
			expectedCount: 0,
		},
		{
			name:          "empty results returns empty array not nil",
			user:          &auth.UserContext{ID: patientID, Role: "patient"},
			mockRepo:      &mockRepository{appointments: []Appointment{}},
			patientQuery:  patientID,
			statusFilter:  nil,
			expectedError: nil,
			expectedCount: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc := NewService(tt.mockRepo, &mockARRepo{})
			res, err := svc.GetPatientAppointments(context.Background(), tt.user, tt.patientQuery, tt.statusFilter)
			if (err != nil && tt.expectedError == nil) || (err == nil && tt.expectedError != nil) || (err != nil && tt.expectedError != nil && err.Error() != tt.expectedError.Error()) {
				t.Errorf("expected error %v, got %v", tt.expectedError, err)
			}
			if err == nil {
				if len(res) != tt.expectedCount {
					t.Errorf("expected %d appointments, got %d", tt.expectedCount, len(res))
				}
				if res == nil {
					t.Errorf("expected non-nil array")
				}
			}
		})
	}
}
