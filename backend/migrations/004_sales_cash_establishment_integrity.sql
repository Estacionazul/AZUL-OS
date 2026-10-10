-- Tenant isolation and relationship integrity for sales and cash movements.
-- Ownership is derived from the existing cash register relationship; ambiguous
-- or inconsistent existing records stop the migration instead of being rewritten.

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM ventas v
      JOIN cajas c ON c.id = v.caja_id
      JOIN dispositivos d ON d.id = v.dispositivo_id
     WHERE d.establecimiento_id <> c.establecimiento_id
        OR (v.usuario_id IS NOT NULL AND NOT EXISTS (
          SELECT 1 FROM usuarios u
           WHERE u.id = v.usuario_id
             AND u.establecimiento_id = c.establecimiento_id
        ))
        OR (v.cliente_id IS NOT NULL AND NOT EXISTS (
          SELECT 1 FROM clientes cl
           WHERE cl.id = v.cliente_id
             AND cl.establecimiento_id = c.establecimiento_id
        ))
  ) THEN
    RAISE EXCEPTION 'Migration 004 refused: a sale references a user, device, or customer from another establishment. Resolve ownership explicitly before retrying.';
  END IF;

  IF EXISTS (
    SELECT 1
      FROM detalle_ventas dv
      JOIN ventas v ON v.id = dv.venta_id
      JOIN cajas c ON c.id = v.caja_id
      JOIN productos p ON p.id = dv.producto_id
     WHERE p.establecimiento_id <> c.establecimiento_id
  ) THEN
    RAISE EXCEPTION 'Migration 004 refused: a sale detail references a product from another establishment. Resolve ownership explicitly before retrying.';
  END IF;

  IF EXISTS (
    SELECT 1
      FROM movimientos_caja mc
      JOIN cajas c ON c.id = mc.caja_id
      LEFT JOIN usuarios u ON u.id = mc.usuario_id
      LEFT JOIN dispositivos d ON d.id = mc.dispositivo_id
     WHERE (mc.usuario_id IS NOT NULL AND (u.id IS NULL OR u.establecimiento_id <> c.establecimiento_id))
        OR (mc.dispositivo_id IS NOT NULL AND (d.id IS NULL OR d.establecimiento_id <> c.establecimiento_id))
  ) THEN
    RAISE EXCEPTION 'Migration 004 refused: a cash movement references a user or device from another establishment. Resolve ownership explicitly before retrying.';
  END IF;
END $$;

ALTER TABLE ventas ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
UPDATE ventas v
   SET establecimiento_id = c.establecimiento_id
  FROM cajas c
 WHERE c.id = v.caja_id;
ALTER TABLE ventas ALTER COLUMN establecimiento_id SET NOT NULL;

ALTER TABLE detalle_ventas ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
UPDATE detalle_ventas dv
   SET establecimiento_id = v.establecimiento_id
  FROM ventas v
 WHERE v.id = dv.venta_id;
ALTER TABLE detalle_ventas ALTER COLUMN establecimiento_id SET NOT NULL;

ALTER TABLE movimientos_caja ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
UPDATE movimientos_caja mc
   SET establecimiento_id = c.establecimiento_id
  FROM cajas c
 WHERE c.id = mc.caja_id;
ALTER TABLE movimientos_caja ALTER COLUMN establecimiento_id SET NOT NULL;

CREATE UNIQUE INDEX ux_dispositivos_id_establecimiento
  ON dispositivos (id, establecimiento_id);
CREATE UNIQUE INDEX ux_usuarios_id_establecimiento
  ON usuarios (id, establecimiento_id);
CREATE UNIQUE INDEX ux_clientes_id_establecimiento
  ON clientes (id, establecimiento_id);
CREATE UNIQUE INDEX ux_cajas_id_establecimiento
  ON cajas (id, establecimiento_id);
CREATE UNIQUE INDEX ux_ventas_id_establecimiento
  ON ventas (id, establecimiento_id);

ALTER TABLE ventas
  ADD CONSTRAINT fk_ventas_caja_establecimiento
  FOREIGN KEY (caja_id, establecimiento_id)
  REFERENCES cajas (id, establecimiento_id);
ALTER TABLE ventas
  ADD CONSTRAINT fk_ventas_dispositivo_establecimiento
  FOREIGN KEY (dispositivo_id, establecimiento_id)
  REFERENCES dispositivos (id, establecimiento_id);
ALTER TABLE ventas
  ADD CONSTRAINT fk_ventas_usuario_establecimiento
  FOREIGN KEY (usuario_id, establecimiento_id)
  REFERENCES usuarios (id, establecimiento_id);
ALTER TABLE ventas
  ADD CONSTRAINT fk_ventas_cliente_establecimiento
  FOREIGN KEY (cliente_id, establecimiento_id)
  REFERENCES clientes (id, establecimiento_id);

ALTER TABLE detalle_ventas
  ADD CONSTRAINT fk_detalle_ventas_venta_establecimiento
  FOREIGN KEY (venta_id, establecimiento_id)
  REFERENCES ventas (id, establecimiento_id)
  ON DELETE RESTRICT;
ALTER TABLE detalle_ventas
  ADD CONSTRAINT fk_detalle_ventas_producto_establecimiento
  FOREIGN KEY (producto_id, establecimiento_id)
  REFERENCES productos (id, establecimiento_id);

ALTER TABLE movimientos_caja
  ADD CONSTRAINT fk_movimientos_caja_caja_establecimiento
  FOREIGN KEY (caja_id, establecimiento_id)
  REFERENCES cajas (id, establecimiento_id)
  ON DELETE RESTRICT;
ALTER TABLE movimientos_caja
  ADD CONSTRAINT fk_movimientos_caja_usuario_establecimiento
  FOREIGN KEY (usuario_id, establecimiento_id)
  REFERENCES usuarios (id, establecimiento_id);
ALTER TABLE movimientos_caja
  ADD CONSTRAINT fk_movimientos_caja_dispositivo_establecimiento
  FOREIGN KEY (dispositivo_id, establecimiento_id)
  REFERENCES dispositivos (id, establecimiento_id);

CREATE INDEX ix_ventas_establecimiento_fecha
  ON ventas (establecimiento_id, fecha DESC);
CREATE INDEX ix_detalle_ventas_establecimiento_venta
  ON detalle_ventas (establecimiento_id, venta_id);
CREATE INDEX ix_movimientos_caja_establecimiento_fecha
  ON movimientos_caja (establecimiento_id, fecha DESC);
