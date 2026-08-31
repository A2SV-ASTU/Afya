-- Add token_hash column to access_requests for magic link verification
ALTER TABLE access_requests ADD COLUMN IF NOT EXISTS token_hash VARCHAR(255);

CREATE INDEX IF NOT EXISTS idx_access_requests_token_hash ON access_requests(token_hash);
