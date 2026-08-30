DROP TABLE IF EXISTS vitals_sync_acks;
DROP INDEX IF EXISTS idx_vital_signs_client_id_patient;
ALTER TABLE vital_signs DROP COLUMN IF EXISTS client_id;
