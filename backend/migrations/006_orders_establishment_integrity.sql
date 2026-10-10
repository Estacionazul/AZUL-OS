-- Tenant integrity for open orders and their line items.
-- Reject pre-existing cross-establishment references instead of rewriting ownership.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM pedidos p
      LEFT JOIN usuarios u ON u.id = p.usuario_id
      LEFT JOIN dispositivos d ON d.id = p.dispositivo_id
     WHERE (p.usuario_id IS NOT NULL AND (u.id IS NULL OR u.establecimiento_id <> p.establecimiento_id))
        OR (p.dispositivo_id IS NOT NULL AND (d.id IS NULL OR d.establecimiento_id <> p.establecimiento_id))
  ) THEN
    RAISE EXCEPTION 'Migration 006 refused: an order references a user or device from another establishment. Resolve ownership explicitly before retrying.';
  END IF;

  IF EXISTS (
    SELECT 1
      FROM pedido_detalles pd
      JOIN pedidos p ON p.id = pd.pedido_id
      JOIN productos pr ON pr.id = pd.producto_id
     WHERE pr.establecimiento_id <> p.establecimiento_id
  ) THEN
    RAISE EXCEPTION 'Migration 006 refused: an order line references a product from another establishment. Resolve ownership explicitly before retrying.';
  END IF;
END $$;

ALTER TABLE pedido_detalles
  ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);

UPDATE pedido_detalles pd
   SET establecimiento_id = p.establecimiento_id
  FROM pedidos p
 WHERE p.id = pd.pedido_id;

ALTER TABLE pedido_detalles
  ALTER COLUMN establecimiento_id SET NOT NULL;

CREATE UNIQUE INDEX ux_pedidos_id_establecimiento
  ON pedidos (id, establecimiento_id);

ALTER TABLE pedidos
  ADD CONSTRAINT fk_pedidos_usuario_establecimiento
  FOREIGN KEY (usuario_id, establecimiento_id)
  REFERENCES usuarios (id, establecimiento_id);
ALTER TABLE pedidos
  ADD CONSTRAINT fk_pedidos_dispositivo_establecimiento
  FOREIGN KEY (dispositivo_id, establecimiento_id)
  REFERENCES dispositivos (id, establecimiento_id);

ALTER TABLE pedido_detalles
  ADD CONSTRAINT fk_pedido_detalles_pedido_establecimiento
  FOREIGN KEY (pedido_id, establecimiento_id)
  REFERENCES pedidos (id, establecimiento_id)
  ON DELETE CASCADE;
ALTER TABLE pedido_detalles
  ADD CONSTRAINT fk_pedido_detalles_producto_establecimiento
  FOREIGN KEY (producto_id, establecimiento_id)
  REFERENCES productos (id, establecimiento_id);

CREATE INDEX ix_pedidos_establecimiento_estado_fecha
  ON pedidos (establecimiento_id, estado, fecha_apertura DESC);
CREATE INDEX ix_pedido_detalles_establecimiento_pedido
  ON pedido_detalles (establecimiento_id, pedido_id);
