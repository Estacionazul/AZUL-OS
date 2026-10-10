-- Persist the tender breakdown for every API-created sale.
CREATE TABLE pagos_venta (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  venta_id uuid NOT NULL,
  establecimiento_id uuid NOT NULL REFERENCES establecimientos(id),
  metodo_pago text NOT NULL CHECK (metodo_pago IN ('Efectivo', 'Yape', 'Plin', 'Tarjeta')),
  monto numeric(12,2) NOT NULL CHECK (monto > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_pagos_venta_establecimiento
    FOREIGN KEY (venta_id, establecimiento_id)
    REFERENCES ventas (id, establecimiento_id)
    ON DELETE RESTRICT
);

CREATE INDEX ix_pagos_venta_establecimiento
  ON pagos_venta (establecimiento_id, venta_id);
