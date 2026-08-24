-- Crisis Resources & Crisis Events tables
-- Migration: 000003_crisis.up.sql

CREATE TABLE IF NOT EXISTS crisis_resources (
    id         SERIAL PRIMARY KEY,
    label      VARCHAR(255) NOT NULL,
    phone      VARCHAR(50) NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    status     VARCHAR(20) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'PUBLISHED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_crisis_resources_status ON crisis_resources(status);
CREATE INDEX idx_crisis_resources_sort_order ON crisis_resources(sort_order);

CREATE TABLE IF NOT EXISTS crisis_events (
    id         VARCHAR(50) PRIMARY KEY,
    user_id    VARCHAR(50) NOT NULL,
    source     VARCHAR(20) NOT NULL CHECK (source IN ('CRISIS_BUTTON', 'CRISIS_MOOD')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- No free-text columns — enforced at schema level per the ERD contract.

CREATE INDEX idx_crisis_events_user_id ON crisis_events(user_id);
CREATE INDEX idx_crisis_events_source ON crisis_events(source);
CREATE INDEX idx_crisis_events_created_at ON crisis_events(created_at);
