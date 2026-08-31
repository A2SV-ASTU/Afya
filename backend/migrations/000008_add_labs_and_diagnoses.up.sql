-- Create encounter_status ENUM if it does not exist (needed if encounters is created here)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'encounter_status') THEN
        CREATE TYPE encounter_status AS ENUM ('open', 'closed');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'diagnosis_type_enum') THEN
        CREATE TYPE diagnosis_type_enum AS ENUM ('provisional', 'final');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lab_category_enum') THEN
        CREATE TYPE lab_category_enum AS ENUM ('laboratory', 'imaging', 'pathology', 'other');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lab_flag_enum') THEN
        CREATE TYPE lab_flag_enum AS ENUM ('normal', 'abnormal', 'critical');
    END IF;
END $$;

-- Ensure encounters table exists for foreign key constraints (just in case Dev A's migration hasn't run)
CREATE TABLE IF NOT EXISTS encounters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
    opened_by_doctor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status encounter_status NOT NULL DEFAULT 'open',
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_encounters_patient_id ON encounters(patient_id);
CREATE INDEX IF NOT EXISTS idx_encounters_clinic_id ON encounters(clinic_id);

-- Create diagnoses table
CREATE TABLE IF NOT EXISTS diagnoses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id UUID NOT NULL REFERENCES encounters(id) ON DELETE CASCADE,
    diagnosis_text TEXT NOT NULL,
    icd_code VARCHAR(50),
    diagnosis_type diagnosis_type_enum NOT NULL,
    notes TEXT,
    diagnosed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_diagnoses_encounter_id ON diagnoses(encounter_id);

-- Create lab_results table
CREATE TABLE IF NOT EXISTS lab_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id UUID NOT NULL REFERENCES encounters(id) ON DELETE CASCADE,
    test_name VARCHAR(255) NOT NULL,
    category lab_category_enum NOT NULL,
    summary_notes TEXT,
    measurements JSONB NOT NULL DEFAULT '{}'::jsonb,
    flag lab_flag_enum,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lab_results_encounter_id ON lab_results(encounter_id);
