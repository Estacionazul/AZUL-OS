-- Add lifecycle fields and establishment-scoped uniqueness for customer identifiers.
-- Refuse to create unique indexes if existing development data contains ambiguous duplicates.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM clientes
     WHERE dni IS NOT NULL AND btrim(dni) <> ''
     GROUP BY establecimiento_id, btrim(dni)
    HAVING count(*) > 1
  ) THEN
    RAISE EXCEPTION 'Migration 011 refused: duplicate DNI values exist within an establishment. Resolve duplicates before retrying.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM clientes
     WHERE ruc IS NOT NULL AND btrim(ruc) <> ''
     GROUP BY establecimiento_id, btrim(ruc)
    HAVING count(*) > 1
  ) THEN
    RAISE EXCEPTION 'Migration 011 refused: duplicate RUC values exist within an establishment. Resolve duplicates before retrying.';
  END IF;
END $$;

ALTER TABLE clientes
  ADD COLUMN activo boolean NOT NULL DEFAULT true;
ALTER TABLE clientes
  ADD COLUMN updated_at timestamptz NOT NULL DEFAULT now();

CREATE UNIQUE INDEX ux_clientes_establecimiento_dni
  ON clientes (establecimiento_id, (btrim(dni)))
  WHERE dni IS NOT NULL AND btrim(dni) <> '';
CREATE UNIQUE INDEX ux_clientes_establecimiento_ruc
  ON clientes (establecimiento_id, (btrim(ruc)))
  WHERE ruc IS NOT NULL AND btrim(ruc) <> '';
