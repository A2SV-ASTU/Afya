package vitals

import (
	"context"
	"time"

	"afyamind-backend/src/shared/auth"
	appErrors "afyamind-backend/src/shared/errors"

	"github.com/google/uuid"
)

type Service interface {
	RecordEncounterVitals(ctx context.Context, user *auth.UserContext, encounterID uuid.UUID, req RecordEncounterVitalsRequest) (*VitalSign, error)
	LogPatientVital(ctx context.Context, user *auth.UserContext, req LogPatientVitalRequest) (*VitalSign, error)
	ListPatientVitals(ctx context.Context, user *auth.UserContext, patientID uuid.UUID, q ListVitalsQuery) ([]VitalSign, error)
	SyncPatientVitals(ctx context.Context, user *auth.UserContext, req SyncVitalsRequest) (SyncVitalsResponse, error)
	GetDoctorSyncVitals(ctx context.Context, user *auth.UserContext, since *time.Time) ([]VitalSign, error)
	AckDoctorVitals(ctx context.Context, user *auth.UserContext, req AckVitalsRequest) error
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) RecordEncounterVitals(ctx context.Context, user *auth.UserContext, encounterID uuid.UUID, req RecordEncounterVitalsRequest) (*VitalSign, error) {
	if user.Role != "doctor" {
		return nil, appErrors.ErrForbiddenRole()
	}

	patientID, err := s.repo.FindPatientIDByEncounter(ctx, encounterID)
	if err != nil {
		return nil, appErrors.ErrNotFound("encounter")
	}

	recordedAt := time.Now()
	if req.RecordedAt != nil {
		recordedAt = *req.RecordedAt
	}

	v := &VitalSign{
		EncounterID:     &encounterID,
		PatientID:       patientID,
		Source:          SourceClinic,
		ClientID:        nil,
		SystolicBP:      req.SystolicBP,
		DiastolicBP:     req.DiastolicBP,
		Pulse:           req.Pulse,
		RespiratoryRate: req.RespiratoryRate,
		Temperature:     req.Temperature,
		SpO2:            req.SpO2,
		BloodSugar:      req.BloodSugar,
		Weight:          req.Weight,
		RecordedAt:      recordedAt,
	}

	if err := s.repo.Insert(ctx, v); err != nil {
		return nil, appErrors.ErrInternal(err.Error())
	}
	return v, nil
}

func (s *service) LogPatientVital(ctx context.Context, user *auth.UserContext, req LogPatientVitalRequest) (*VitalSign, error) {
	if user.Role != "patient" {
		return nil, appErrors.ErrForbiddenRole()
	}

	recordedAt := time.Now()
	if req.RecordedAt != nil {
		recordedAt = *req.RecordedAt
	}

	v := &VitalSign{
		PatientID:       user.ID,
		Source:          SourcePatient,
		ClientID:        nil,
		SystolicBP:      req.SystolicBP,
		DiastolicBP:     req.DiastolicBP,
		Pulse:           req.Pulse,
		RespiratoryRate: req.RespiratoryRate,
		Temperature:     req.Temperature,
		SpO2:            req.SpO2,
		BloodSugar:      req.BloodSugar,
		Weight:          req.Weight,
		RecordedAt:      recordedAt,
	}

	if err := s.repo.Insert(ctx, v); err != nil {
		return nil, appErrors.ErrInternal(err.Error())
	}
	return v, nil
}

func (s *service) ListPatientVitals(ctx context.Context, user *auth.UserContext, patientID uuid.UUID, q ListVitalsQuery) ([]VitalSign, error) {
	if user.Role == "patient" && user.ID != patientID {
		return nil, appErrors.ErrForbiddenRole()
	}
	return s.repo.ListByPatient(ctx, patientID, q.From, q.To, q.Source)
}

func (s *service) SyncPatientVitals(ctx context.Context, user *auth.UserContext, req SyncVitalsRequest) (SyncVitalsResponse, error) {
	if user.Role != "patient" {
		return SyncVitalsResponse{}, appErrors.ErrForbiddenRole()
	}

	results := make([]SyncVitalResult, 0, len(req.Vitals))
	for _, entry := range req.Vitals {
		cid := entry.ClientID
		recordedAt := time.Now()
		if entry.RecordedAt != nil {
			recordedAt = *entry.RecordedAt
		}

		v := &VitalSign{
			PatientID:       user.ID,
			Source:          SourcePatient,
			ClientID:        &cid,
			SystolicBP:      entry.SystolicBP,
			DiastolicBP:     entry.DiastolicBP,
			Pulse:           entry.Pulse,
			RespiratoryRate: entry.RespiratoryRate,
			Temperature:     entry.Temperature,
			SpO2:            entry.SpO2,
			BloodSugar:      entry.BloodSugar,
			Weight:          entry.Weight,
			RecordedAt:      recordedAt,
		}

		id, created, err := s.repo.UpsertByClientID(ctx, v)
		if err != nil {
			return SyncVitalsResponse{}, appErrors.ErrInternal(err.Error())
		}
		results = append(results, SyncVitalResult{ClientID: cid, ID: id, Created: created})
	}

	return SyncVitalsResponse{Results: results}, nil
}

func (s *service) GetDoctorSyncVitals(ctx context.Context, user *auth.UserContext, since *time.Time) ([]VitalSign, error) {
	if user.Role != "patient" {
		return nil, appErrors.ErrForbiddenRole()
	}
	return s.repo.ListUnackedClinicVitals(ctx, user.ID, since)
}

func (s *service) AckDoctorVitals(ctx context.Context, user *auth.UserContext, req AckVitalsRequest) error {
	if user.Role != "patient" {
		return appErrors.ErrForbiddenRole()
	}
	return s.repo.AckVitals(ctx, user.ID, req.SyncedIDs)
}
