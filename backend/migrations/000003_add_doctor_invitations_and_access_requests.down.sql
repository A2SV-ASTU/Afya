DROP TABLE IF EXISTS access_requests;
DROP TABLE IF EXISTS doctor_invitations;

-- Recreate old admin_invitations table
CREATE TABLE IF NOT EXISTS admin_invitations (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_admin_invitations_token_hash ON admin_invitations(token_hash);
CREATE INDEX IF NOT EXISTS idx_admin_invitations_user_id ON admin_invitations(user_id);

ALTER TABLE users DROP CONSTRAINT IF EXISTS fk_users_clinic_id;
DROP TABLE IF EXISTS clinics;

DROP TYPE IF EXISTS access_request_status;
DROP TYPE IF EXISTS invitation_status;
DROP TYPE IF EXISTS clinic_status;
