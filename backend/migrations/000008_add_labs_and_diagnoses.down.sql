DROP TABLE IF EXISTS lab_results;
DROP TABLE IF EXISTS diagnoses;

-- We don't drop encounters here because it belongs to another domain logically,
-- even though we might have created it IF NOT EXISTS.

DO $$
BEGIN
    DROP TYPE IF EXISTS lab_flag_enum;
    DROP TYPE IF EXISTS lab_category_enum;
    DROP TYPE IF EXISTS diagnosis_type_enum;
    -- Not dropping encounter_status
END $$;
