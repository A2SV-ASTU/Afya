package prescriptions

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"afyamind-backend/src/database"

	"github.com/google/uuid"
)

var (
	ErrPrescriptionNotFound = errors.New("prescription not found")
	ErrEncounterNotFound    = errors.New("encounter not found")
)

type Repository interface {
	CreateWithItems(ctx context.Context, tx database.DBTX, p *Prescription, items []PrescriptionItem) error
	FindByID(ctx context.Context, id uuid.UUID) (*Prescription, error)
	FindItemsByPrescriptionID(ctx context.Context, prescriptionID uuid.UUID) ([]PrescriptionItem, error)
	ListByEncounterID(ctx context.Context, encounterID uuid.UUID) ([]Prescription, error)
	UpdateNotes(ctx context.Context, id uuid.UUID, notes *string) error
	ReplaceItems(ctx context.Context, tx database.DBTX, prescriptionID uuid.UUID, items []PrescriptionItem) error
	UpdateItemStatus(ctx context.Context, itemID uuid.UUID, status PrescriptionItemStatus) error
	UpdateAllActiveItemsStatus(ctx context.Context, prescriptionID uuid.UUID, status PrescriptionItemStatus) error
	FindEncounterStatus(ctx context.Context, encounterID uuid.UUID) (string, error)
	FindEncounterIDByPrescription(ctx context.Context, prescriptionID uuid.UUID) (uuid.UUID, error)
}

type repository struct {
	db database.DBTX
}

func NewRepository(db database.DBTX) Repository {
	return &repository{db: db}
}

func (r *repository) CreateWithItems(ctx context.Context, tx database.DBTX, p *Prescription, items []PrescriptionItem) error {
	err := tx.QueryRowContext(ctx, `
		INSERT INTO prescriptions (encounter_id, notes, prescribed_at)
		VALUES ($1, $2, NOW())
		RETURNING id, prescribed_at`,
		p.EncounterID, p.Notes,
	).Scan(&p.ID, &p.PrescribedAt)
	if err != nil {
		return fmt.Errorf("insert prescription header: %w", err)
	}

	for i := range items {
		items[i].PrescriptionID = p.ID
		items[i].Status = ItemStatusActive
		err := tx.QueryRowContext(ctx, `
			INSERT INTO prescription_items
				(prescription_id, medication_name, dose, route, frequency,
				 duration, status, instructions, started_at)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,NOW())
			RETURNING id, started_at`,
			p.ID,
			items[i].MedicationName, items[i].Dose,
			string(items[i].Route), string(items[i].Frequency),
			items[i].Duration, string(items[i].Status), items[i].Instructions,
		).Scan(&items[i].ID, &items[i].StartedAt)
		if err != nil {
			return fmt.Errorf("insert prescription item %d: %w", i, err)
		}
	}
	return nil
}

func (r *repository) FindByID(ctx context.Context, id uuid.UUID) (*Prescription, error) {
	var p Prescription
	err := r.db.QueryRowContext(ctx,
		`SELECT id, encounter_id, notes, prescribed_at FROM prescriptions WHERE id = $1`, id,
	).Scan(&p.ID, &p.EncounterID, &p.Notes, &p.PrescribedAt)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrPrescriptionNotFound
		}
		return nil, err
	}
	return &p, nil
}

func (r *repository) FindItemsByPrescriptionID(ctx context.Context, prescriptionID uuid.UUID) ([]PrescriptionItem, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, prescription_id, medication_name, dose, route, frequency,
		       duration, status, instructions, started_at
		FROM prescription_items
		WHERE prescription_id = $1`, prescriptionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []PrescriptionItem
	for rows.Next() {
		var item PrescriptionItem
		if err := rows.Scan(
			&item.ID, &item.PrescriptionID, &item.MedicationName, &item.Dose,
			&item.Route, &item.Frequency, &item.Duration, &item.Status,
			&item.Instructions, &item.StartedAt,
		); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	if items == nil {
		return []PrescriptionItem{}, nil
	}
	return items, nil
}

func (r *repository) ListByEncounterID(ctx context.Context, encounterID uuid.UUID) ([]Prescription, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, encounter_id, notes, prescribed_at
		FROM prescriptions
		WHERE encounter_id = $1
		ORDER BY prescribed_at DESC`, encounterID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var out []Prescription
	for rows.Next() {
		var p Prescription
		if err := rows.Scan(&p.ID, &p.EncounterID, &p.Notes, &p.PrescribedAt); err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	if out == nil {
		return []Prescription{}, nil
	}
	return out, nil
}

func (r *repository) UpdateNotes(ctx context.Context, id uuid.UUID, notes *string) error {
	res, err := r.db.ExecContext(ctx,
		`UPDATE prescriptions SET notes = $1 WHERE id = $2`, notes, id)
	if err != nil {
		return err
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return ErrPrescriptionNotFound
	}
	return nil
}

func (r *repository) ReplaceItems(ctx context.Context, tx database.DBTX, prescriptionID uuid.UUID, items []PrescriptionItem) error {
	if _, err := tx.ExecContext(ctx,
		`DELETE FROM prescription_items WHERE prescription_id = $1`, prescriptionID,
	); err != nil {
		return fmt.Errorf("delete old items: %w", err)
	}

	for i := range items {
		items[i].PrescriptionID = prescriptionID
		items[i].Status = ItemStatusActive
		err := tx.QueryRowContext(ctx, `
			INSERT INTO prescription_items
				(prescription_id, medication_name, dose, route, frequency,
				 duration, status, instructions, started_at)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,NOW())
			RETURNING id, started_at`,
			prescriptionID,
			items[i].MedicationName, items[i].Dose,
			string(items[i].Route), string(items[i].Frequency),
			items[i].Duration, string(items[i].Status), items[i].Instructions,
		).Scan(&items[i].ID, &items[i].StartedAt)
		if err != nil {
			return fmt.Errorf("insert replacement item %d: %w", i, err)
		}
	}
	return nil
}

func (r *repository) UpdateItemStatus(ctx context.Context, itemID uuid.UUID, status PrescriptionItemStatus) error {
	res, err := r.db.ExecContext(ctx,
		`UPDATE prescription_items SET status = $1 WHERE id = $2`,
		string(status), itemID)
	if err != nil {
		return err
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return ErrPrescriptionNotFound
	}
	return nil
}

func (r *repository) UpdateAllActiveItemsStatus(ctx context.Context, prescriptionID uuid.UUID, status PrescriptionItemStatus) error {
	_, err := r.db.ExecContext(ctx,
		`UPDATE prescription_items SET status = $1
		 WHERE prescription_id = $2 AND status = 'active'`,
		string(status), prescriptionID)
	return err
}

func (r *repository) FindEncounterStatus(ctx context.Context, encounterID uuid.UUID) (string, error) {
	var status string
	err := r.db.QueryRowContext(ctx,
		`SELECT status FROM encounters WHERE id = $1`, encounterID,
	).Scan(&status)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return "", ErrEncounterNotFound
		}
		return "", err
	}
	return status, nil
}

func (r *repository) FindEncounterIDByPrescription(ctx context.Context, prescriptionID uuid.UUID) (uuid.UUID, error) {
	var eid uuid.UUID
	err := r.db.QueryRowContext(ctx,
		`SELECT encounter_id FROM prescriptions WHERE id = $1`, prescriptionID,
	).Scan(&eid)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return uuid.Nil, ErrPrescriptionNotFound
		}
		return uuid.Nil, err
	}
	return eid, nil
}
