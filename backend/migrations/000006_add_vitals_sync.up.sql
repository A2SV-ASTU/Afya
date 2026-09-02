-- Add client_id to vital_signs for mobile batch up-sync deduplication
ALTER TABLE vital_signs ADD COLUMN IF NOT EXISTS client_id UUID;

-- Enforce per-patient uniqueness on client_id, but only where client_id is not NULL
CREATE UNIQUE INDEX IF NOT EXISTS idx_vital_signs_client_id_patient
    ON vital_signs(patient_id, client_id)
    WHERE client_id IS NOT NULL;

-- Server-side delivery ledger for doctor-recorded vitals down-sync
CREATE TABLE IF NOT EXISTS vitals_sync_acks (
    patient_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vital_id      UUID NOT NULL REFERENCES vital_signs(id) ON DELETE CASCADE,
    acked_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (patient_id, vital_id)
);
