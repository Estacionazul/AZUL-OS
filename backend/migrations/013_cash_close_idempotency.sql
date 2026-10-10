-- Persist cash-close request identity and reconciliation so a lost HTTP response
-- can be retried safely without attempting to close the next register.
ALTER TABLE cajas
  ADD COLUMN IF NOT EXISTS cierre_idempotency_key uuid,
  ADD COLUMN IF NOT EXISTS cierre_request_hash text,
  ADD COLUMN IF NOT EXISTS cierre_efectivo_esperado numeric(14,2),
  ADD COLUMN IF NOT EXISTS cierre_diferencia numeric(14,2),
  ADD COLUMN IF NOT EXISTS cierre_pagos_mixtos numeric(14,2);

CREATE UNIQUE INDEX IF NOT EXISTS ux_cajas_establecimiento_cierre_idempotency
  ON cajas (establecimiento_id, cierre_idempotency_key)
  WHERE cierre_idempotency_key IS NOT NULL;
