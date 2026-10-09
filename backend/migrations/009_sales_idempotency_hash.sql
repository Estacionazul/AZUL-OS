-- Persist a canonical request fingerprint for safe sale idempotency retries.
-- Nullable to preserve existing sales and historical records unchanged.
ALTER TABLE ventas
  ADD COLUMN idempotency_hash char(64);
