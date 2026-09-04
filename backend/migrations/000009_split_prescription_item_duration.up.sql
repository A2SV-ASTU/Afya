-- Migration 000009 UP: Create duration_unit ENUM type and split duration in prescription_items

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'duration_unit') THEN
        CREATE TYPE duration_unit AS ENUM ('day', 'week', 'month', 'year');
    END IF;
END $$;

ALTER TABLE prescription_items 
ADD COLUMN IF NOT EXISTS duration_value INT,
ADD COLUMN IF NOT EXISTS duration_unit duration_unit;

-- Data conversion: Parse existing text duration strings into duration_value and duration_unit if column exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'prescription_items' AND column_name = 'duration'
    ) THEN
        EXECUTE '
            UPDATE prescription_items
            SET 
              duration_value = COALESCE(
                (NULLIF(regexp_replace(duration, ''[^0-9]'', '''', ''g''), ''''))::INT, 
                1
              ),
              duration_unit = CASE 
                WHEN LOWER(duration) LIKE ''%week%'' THEN ''week''::duration_unit
                WHEN LOWER(duration) LIKE ''%month%'' THEN ''month''::duration_unit
                WHEN LOWER(duration) LIKE ''%year%'' THEN ''year''::duration_unit
                ELSE ''day''::duration_unit
              END
            WHERE duration_value IS NULL OR duration_unit IS NULL;
        ';
    ELSE
        UPDATE prescription_items
        SET 
            duration_value = COALESCE(duration_value, 1),
            duration_unit = COALESCE(duration_unit, 'day'::duration_unit)
        WHERE duration_value IS NULL OR duration_unit IS NULL;
    END IF;
END $$;


-- Enforce constraints & defaults
ALTER TABLE prescription_items 
ALTER COLUMN duration_value SET NOT NULL,
ALTER COLUMN duration_value SET DEFAULT 1,
ALTER COLUMN duration_unit SET NOT NULL,
ALTER COLUMN duration_unit SET DEFAULT 'day'::duration_unit;

-- Drop legacy duration column
ALTER TABLE prescription_items 
DROP COLUMN IF EXISTS duration;
