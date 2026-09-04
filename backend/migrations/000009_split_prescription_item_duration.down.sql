-- Migration 000009 DOWN: Revert splitting duration into duration_value and duration_unit

ALTER TABLE prescription_items 
ADD COLUMN IF NOT EXISTS duration VARCHAR(100);

UPDATE prescription_items 
SET duration = duration_value || ' ' || duration_unit || (CASE WHEN duration_value > 1 THEN 's' ELSE '' END)
WHERE duration IS NULL;

ALTER TABLE prescription_items 
ALTER COLUMN duration SET NOT NULL,
ALTER COLUMN duration SET DEFAULT '7 days';

ALTER TABLE prescription_items 
DROP COLUMN IF EXISTS duration_value,
DROP COLUMN IF EXISTS duration_unit;

DROP TYPE IF EXISTS duration_unit;
