package appointments

import (
	"context"
	"time"

	accessrequests "afyamind-backend/src/access-requests"
	"afyamind-backend/src/shared/auth"
	"afyamind-backend/src/shared/errors"
	"github.com/google/uuid"
)

type Service interface {
	CreateAppointment(ctx context.Context, user *auth.UserContext, req CreateAppointmentRequest) (*Appointment, error)
	GetPatientAppointments(ctx context.Context, user *auth.UserContext, patientID uuid.UUID, status *AppointmentStatus) ([]Appointment, error)
}

type service struct {
	repo   Repository
	arRepo accessrequests.Repository
}

func NewService(repo Repository, arRepo accessrequests.Repository) Service {
	return &service{repo: repo, arRepo: arRepo}
}

func (s *service) CreateAppointment(ctx context.Context, user *auth.UserContext, req CreateAppointmentRequest) (*Appointment, error) {
	if user.Role != "doctor" || user.ClinicID == nil {
		return nil, errors.ErrForbiddenRole()
	}

	_, err := s.arRepo.FindActiveGrant(ctx, *user.ClinicID, req.PatientID)
	if err != nil {
		return nil, errors.ErrForbiddenGrant()
	}

	appt := &Appointment{
		ID:          uuid.New(),
		ClinicID:    *user.ClinicID,
		DoctorID:    user.ID,
		PatientID:   req.PatientID,
		ScheduledAt: req.ScheduledAt,
		Status:      StatusScheduled,
		Notes:       req.Notes,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	err = s.repo.Create(ctx, appt)
	if err != nil {
		return nil, err
	}

	return appt, nil
}

func (s *service) GetPatientAppointments(ctx context.Context, user *auth.UserContext, patientID uuid.UUID, status *AppointmentStatus) ([]Appointment, error) {
	// Patients can only view their own appointments
	if user.Role == "patient" && user.ID != patientID {
		return nil, errors.ErrForbiddenRole()
	}

	appointments, err := s.repo.FindByPatientID(ctx, patientID, status)
	if err != nil {
		return nil, err
	}

	if appointments == nil {
		return []Appointment{}, nil
	}

	return appointments, nil
}
