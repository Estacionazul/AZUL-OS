-- Enforce establishment ownership for cash-register opening and closing actors/devices.
-- Existing mismatches are not reassigned automatically.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM cajas c
      LEFT JOIN usuarios ua ON ua.id = c.usuario_apertura_id
      LEFT JOIN dispositivos da ON da.id = c.dispositivo_apertura_id
      LEFT JOIN usuarios uc ON uc.id = c.usuario_cierre_id
      LEFT JOIN dispositivos dc ON dc.id = c.dispositivo_cierre_id
     WHERE ua.id IS NULL
        OR da.id IS NULL
        OR ua.establecimiento_id <> c.establecimiento_id
        OR da.establecimiento_id <> c.establecimiento_id
        OR (c.usuario_cierre_id IS NOT NULL AND (uc.id IS NULL OR uc.establecimiento_id <> c.establecimiento_id))
        OR (c.dispositivo_cierre_id IS NOT NULL AND (dc.id IS NULL OR dc.establecimiento_id <> c.establecimiento_id))
  ) THEN
    RAISE EXCEPTION 'Migration 005 refused: a cash register references an opening or closing user/device from another establishment. Resolve ownership explicitly before retrying.';
  END IF;
END $$;

ALTER TABLE cajas
  ADD CONSTRAINT fk_cajas_usuario_apertura_establecimiento
  FOREIGN KEY (usuario_apertura_id, establecimiento_id)
  REFERENCES usuarios (id, establecimiento_id);
ALTER TABLE cajas
  ADD CONSTRAINT fk_cajas_dispositivo_apertura_establecimiento
  FOREIGN KEY (dispositivo_apertura_id, establecimiento_id)
  REFERENCES dispositivos (id, establecimiento_id);
ALTER TABLE cajas
  ADD CONSTRAINT fk_cajas_usuario_cierre_establecimiento
  FOREIGN KEY (usuario_cierre_id, establecimiento_id)
  REFERENCES usuarios (id, establecimiento_id);
ALTER TABLE cajas
  ADD CONSTRAINT fk_cajas_dispositivo_cierre_establecimiento
  FOREIGN KEY (dispositivo_cierre_id, establecimiento_id)
  REFERENCES dispositivos (id, establecimiento_id);

CREATE INDEX ix_cajas_establecimiento_fecha
  ON cajas (establecimiento_id, fecha_apertura DESC);
