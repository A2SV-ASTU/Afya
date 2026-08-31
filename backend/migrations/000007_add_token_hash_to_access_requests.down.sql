DROP INDEX IF EXISTS idx_access_requests_token_hash;
ALTER TABLE access_requests DROP COLUMN IF EXISTS token_hash;
