package prescriptions

import (
	"context"
	"database/sql"
	"errors"

	"afyamind-backend/src/database"
	"afyamind-backend/src/shared/auth"
	appErrors "afyamind-backend/src/shared/errors"

	"github.com/google/uuid"
)

type Service interface {
	CreatePrescription(ctx context.Context, user *auth.UserContext, encounterID uuid.UUID, req CreatePrescriptionRequest) (*PrescriptionResponse, error)
	ListPrescriptions(ctx context.Context, user *auth.UserContext, encounterID uuid.UUID) ([]PrescriptionResponse, error)
	UpdatePrescription(ctx context.Context, user *auth.UserContext, prescriptionID uuid.UUID, req UpdatePrescriptionRequest) (*PrescriptionResponse, error)
	CompletePrescription(ctx context.Context, user *auth.UserContext, prescriptionID uuid.UUID, req CompletePrescriptionRequest) error
	DeactivatePrescription(ctx context.Context, user *auth.UserContext, prescriptionID uuid.UUID) error
}

// txFunc is the transaction helper — replaceable in tests.
type txFunc func(ctx context.Context, db *sql.DB, fn func(database.DBTX) error) error

type service struct {
	db   *sql.DB
	repo Repository
	txFn txFunc
}

func NewService(db *sql.DB, repo Repository) Service {
	return &service{db: db, repo: repo, txFn: database.WithTransaction}
}

func (s *service) requireOpenEncounter(ctx context.Context, encounterID uuid.UUID) error {
	status, err := s.repo.FindEncounterStatus(ctx, encounterID)
	if err != nil {
		if errors.Is(err, ErrEncounterNotFound) {
			return appErrors.ErrNotFound("encounter")
		}
		return appErrors.ErrInternal(err.Error())
	}
	if status != "open" {
		return appErrors.ErrConflict("encounter is closed; no further edits allowed")
	}
	return nil
}

func (s *service) CreatePrescription(ctx context.Context, user *auth.UserContext, encounterID uuid.UUID, req CreatePrescriptionRequest) (*PrescriptionResponse, error) {
	if user.Role != "doctor" {
		return nil, appErrors.ErrForbiddenRole()
	}
	if err := s.requireOpenEncounter(ctx, encounterID); err != nil {
		return nil, err
	}

	p := &Prescription{EncounterID: encounterID, Notes: req.Notes}

	items := make([]PrescriptionItem, len(req.Items))
	for i, r := range req.Items {
		items[i] = PrescriptionItem{
			MedicationName: r.MedicationName,
			Dose:           r.Dose,
			Route:          r.Route,
			Frequency:      r.Frequency,
			DurationValue:  r.DurationValue,
			DurationUnit:   r.DurationUnit,
			Instructions:   r.Instructions,
		}
	}

	if err := s.txFn(ctx, s.db, func(tx database.DBTX) error {
		return s.repo.CreateWithItems(ctx, tx, p, items)
	}); err != nil {
		return nil, appErrors.ErrInternal(err.Error())
	}

	return &PrescriptionResponse{Prescription: *p, Items: items}, nil
}

func (s *service) ListPrescriptions(ctx context.Context, user *auth.UserContext, encounterID uuid.UUID) ([]PrescriptionResponse, error) {
	prescriptions, err := s.repo.ListByEncounterID(ctx, encounterID)
	if err != nil {
		return nil, appErrors.ErrInternal(err.Error())
	}

	out := make([]PrescriptionResponse, 0, len(prescriptions))
	for _, p := range prescriptions {
		items, err := s.repo.FindItemsByPrescriptionID(ctx, p.ID)
		if err != nil {
			return nil, appErrors.ErrInternal(err.Error())
		}
		out = append(out, PrescriptionResponse{Prescription: p, Items: items})
	}
	return out, nil
}

func (s *service) UpdatePrescription(ctx context.Context, user *auth.UserContext, prescriptionID uuid.UUID, req UpdatePrescriptionRequest) (*PrescriptionResponse, error) {
	if user.Role != "doctor" {
		return nil, appErrors.ErrForbiddenRole()
	}

	encounterID, err := s.repo.FindEncounterIDByPrescription(ctx, prescriptionID)
	if err != nil {
		if errors.Is(err, ErrPrescriptionNotFound) {
			return nil, appErrors.ErrNotFound("prescription")
		}
		return nil, appErrors.ErrInternal(err.Error())
	}

	if err := s.requireOpenEncounter(ctx, encounterID); err != nil {
		return nil, err
	}

	if req.Notes != nil {
		if err := s.repo.UpdateNotes(ctx, prescriptionID, req.Notes); err != nil {
			return nil, appErrors.ErrInternal(err.Error())
		}
	}

	if req.Items != nil {
		newItems := make([]PrescriptionItem, len(req.Items))
		for i, r := range req.Items {
			newItems[i] = PrescriptionItem{
				MedicationName: r.MedicationName,
				Dose:           r.Dose,
				Route:          r.Route,
				Frequency:      r.Frequency,
				DurationValue:  r.DurationValue,
				DurationUnit:   r.DurationUnit,
				Instructions:   r.Instructions,
			}
		}
		if err := s.txFn(ctx, s.db, func(tx database.DBTX) error {
			return s.repo.ReplaceItems(ctx, tx, prescriptionID, newItems)
		}); err != nil {
			return nil, appErrors.ErrInternal(err.Error())
		}
	}

	p, err := s.repo.FindByID(ctx, prescriptionID)
	if err != nil {
		return nil, appErrors.ErrInternal(err.Error())
	}
	items, err := s.repo.FindItemsByPrescriptionID(ctx, prescriptionID)
	if err != nil {
		return nil, appErrors.ErrInternal(err.Error())
	}
	return &PrescriptionResponse{Prescription: *p, Items: items}, nil
}

func (s *service) CompletePrescription(ctx context.Context, user *auth.UserContext, prescriptionID uuid.UUID, req CompletePrescriptionRequest) error {
	if user.Role != "patient" {
		return appErrors.ErrForbiddenRole()
	}

	if len(req.ItemIDs) == 0 {
		return s.repo.UpdateAllActiveItemsStatus(ctx, prescriptionID, ItemStatusCompleted)
	}

	for _, rawID := range req.ItemIDs {
		itemID, err := uuid.Parse(rawID)
		if err != nil {
			continue
		}
		err = s.repo.UpdateItemStatus(ctx, itemID, ItemStatusCompleted)
		if err != nil && !errors.Is(err, ErrPrescriptionNotFound) {
			return appErrors.ErrInternal(err.Error())
		}
	}
	return nil
}

func (s *service) DeactivatePrescription(ctx context.Context, user *auth.UserContext, prescriptionID uuid.UUID) error {
	if user.Role != "doctor" {
		return appErrors.ErrForbiddenRole()
	}
	return s.repo.UpdateAllActiveItemsStatus(ctx, prescriptionID, ItemStatusDeactivated)
}
