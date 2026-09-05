-- Migration 000010 DOWN: Drop email_verifications table and remove verification columns from users

DROP TABLE IF EXISTS email_verifications;

ALTER TABLE users 
DROP COLUMN IF EXISTS email_verified_at,
DROP COLUMN IF EXISTS is_email_verified;
