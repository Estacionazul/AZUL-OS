-- Allow each establishment to maintain its own sales numbering series.
-- The original global UNIQUE(numero) prevented independent per-establishment correlatives.
ALTER TABLE ventas DROP CONSTRAINT ventas_numero_key;

CREATE UNIQUE INDEX ux_ventas_establecimiento_numero
  ON ventas (establecimiento_id, numero);
