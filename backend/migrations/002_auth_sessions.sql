-- Requires a fresh backend database created with 001_initial.sql.
-- This migration is not for the production SQLite database.
ALTER TABLE usuarios
  ADD COLUMN establecimiento_id uuid NOT NULL REFERENCES establecimientos(id),
  ADD COLUMN usuario text NOT NULL,
  ADD COLUMN intentos_fallidos integer NOT NULL DEFAULT 0 CHECK (intentos_fallidos >= 0),
  ADD COLUMN bloqueado_hasta timestamptz;

CREATE UNIQUE INDEX ux_usuarios_establecimiento_usuario
  ON usuarios(establecimiento_id, usuario);

ALTER TABLE sesiones
  ADD COLUMN token_hash text,
  ADD COLUMN expira_en timestamptz;

CREATE UNIQUE INDEX ux_sesiones_token_hash
  ON sesiones(token_hash)
  WHERE token_hash IS NOT NULL;

ALTER TABLE sesiones
  ADD CONSTRAINT ck_sesiones_estado
  CHECK (estado IN ('ACTIVA','CERRADA','REVOCADA'));
