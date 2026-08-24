-- Exercises & Exercise Progress tables
-- Migration: 000002_exercises.up.sql

CREATE TABLE IF NOT EXISTS exercises (
    id          VARCHAR(50) PRIMARY KEY,
    slug        VARCHAR(100) NOT NULL UNIQUE,
    title       VARCHAR(255) NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    language    VARCHAR(10) NOT NULL DEFAULT 'en',
    status      VARCHAR(20) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'PUBLISHED')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_exercises_status ON exercises(status);
CREATE INDEX idx_exercises_language ON exercises(language);
CREATE INDEX idx_exercises_slug ON exercises(slug);

CREATE TABLE IF NOT EXISTS exercise_steps (
    id               VARCHAR(50) PRIMARY KEY,
    exercise_id      VARCHAR(50) NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    step_type        VARCHAR(20) NOT NULL CHECK (step_type IN ('TASK', 'BREAK')),
    title            VARCHAR(255) NOT NULL,
    instruction      TEXT,
    duration_seconds INTEGER NOT NULL DEFAULT 0,
    sort_order       INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_exercise_steps_exercise_id ON exercise_steps(exercise_id);

CREATE TABLE IF NOT EXISTS exercise_completions (
    id           VARCHAR(50) PRIMARY KEY,
    exercise_id  VARCHAR(50) NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    user_id      VARCHAR(50) NOT NULL,
    progress     INTEGER NOT NULL DEFAULT 0,
    status       VARCHAR(20) NOT NULL DEFAULT 'IN_PROGRESS' CHECK (status IN ('IN_PROGRESS', 'COMPLETED')),
    completed_at TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_exercise_completions_user_id ON exercise_completions(user_id);
CREATE INDEX idx_exercise_completions_exercise_user ON exercise_completions(exercise_id, user_id);
