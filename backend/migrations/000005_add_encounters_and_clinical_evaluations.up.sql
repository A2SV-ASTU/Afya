-- Create ENUM types for encounters and clinical data
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'encounter_status') THEN
        CREATE TYPE encounter_status AS ENUM ('open', 'closed');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vital_source') THEN
        CREATE TYPE vital_source AS ENUM ('clinic', 'patient');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'diagnosis_type') THEN
        CREATE TYPE diagnosis_type AS ENUM ('provisional', 'final');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lab_category') THEN
        CREATE TYPE lab_category AS ENUM ('laboratory', 'imaging', 'pathology', 'other');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lab_flag') THEN
        CREATE TYPE lab_flag AS ENUM ('normal', 'abnormal', 'critical');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'prescription_route') THEN
        CREATE TYPE prescription_route AS ENUM ('oral', 'iv', 'im', 'subcutaneous', 'topical', 'other');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'prescription_frequency') THEN
        CREATE TYPE prescription_frequency AS ENUM ('OD', 'BD', 'TDS', 'QID', 'QHS', 'PRN', 'STAT', 'Q4H', 'Q6H', 'Q8H', 'Q12H');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'prescription_item_status') THEN
        CREATE TYPE prescription_item_status AS ENUM ('active', 'deactivated', 'completed');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'duration_unit') THEN
        CREATE TYPE duration_unit AS ENUM ('day', 'week', 'month', 'year');
    END IF;
END $$;

-- Create encounters table
CREATE TABLE IF NOT EXISTS encounters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
    opened_by_doctor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    status encounter_status NOT NULL DEFAULT 'open',
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_encounters_patient_id ON encounters(patient_id);
CREATE INDEX IF NOT EXISTS idx_encounters_clinic_id ON encounters(clinic_id);
CREATE INDEX IF NOT EXISTS idx_encounters_opened_by_doctor_id ON encounters(opened_by_doctor_id);

-- Create clinical_evaluations table
CREATE TABLE IF NOT EXISTS clinical_evaluations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id UUID NOT NULL UNIQUE REFERENCES encounters(id) ON DELETE CASCADE,
    chief_complaint TEXT NOT NULL,
    history_of_present_illness TEXT NOT NULL,
    past_admissions TEXT,
    family_history TEXT,
    allergies_notes TEXT,
    general_appearance TEXT,
    system_examination JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_clinical_evaluations_encounter_id ON clinical_evaluations(encounter_id);

-- Create vital_signs table
CREATE TABLE IF NOT EXISTS vital_signs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id UUID REFERENCES encounters(id) ON DELETE CASCADE,
    patient_id UUID REFERENCES users(id) ON DELETE CASCADE,
    source vital_source NOT NULL,
    systolic_bp INTEGER,
    diastolic_bp INTEGER,
    pulse INTEGER,
    respiratory_rate INTEGER,
    temperature DECIMAL(5,2),
    spo2 DECIMAL(5,2),
    blood_sugar DECIMAL(5,2),
    weight DECIMAL(5,2),
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vital_signs_encounter_id ON vital_signs(encounter_id);
CREATE INDEX IF NOT EXISTS idx_vital_signs_patient_id ON vital_signs(patient_id);

-- Create diagnoses table
CREATE TABLE IF NOT EXISTS diagnoses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id UUID NOT NULL REFERENCES encounters(id) ON DELETE CASCADE,
    diagnosis_text TEXT NOT NULL,
    icd_code VARCHAR(100),
    diagnosis_type diagnosis_type NOT NULL DEFAULT 'provisional',
    notes TEXT,
    diagnosed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_diagnoses_encounter_id ON diagnoses(encounter_id);

-- Create lab_results table
CREATE TABLE IF NOT EXISTS lab_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id UUID NOT NULL REFERENCES encounters(id) ON DELETE CASCADE,
    test_name VARCHAR(255) NOT NULL,
    category lab_category NOT NULL DEFAULT 'laboratory',
    summary_notes TEXT,
    measurements JSONB,
    flag lab_flag,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lab_results_encounter_id ON lab_results(encounter_id);

-- Create prescriptions table
CREATE TABLE IF NOT EXISTS prescriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id UUID NOT NULL REFERENCES encounters(id) ON DELETE CASCADE,
    notes TEXT,
    prescribed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_prescriptions_encounter_id ON prescriptions(encounter_id);

-- Create prescription_items table
CREATE TABLE IF NOT EXISTS prescription_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prescription_id UUID NOT NULL REFERENCES prescriptions(id) ON DELETE CASCADE,
    medication_name VARCHAR(255) NOT NULL,
    dose VARCHAR(100) NOT NULL,
    route prescription_route NOT NULL DEFAULT 'oral',
    frequency prescription_frequency NOT NULL DEFAULT 'OD',
    duration_value INT NOT NULL DEFAULT 1,
    duration_unit duration_unit NOT NULL DEFAULT 'day',
    status prescription_item_status NOT NULL DEFAULT 'active',
    instructions TEXT,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_prescription_items_prescription_id ON prescription_items(prescription_id);
