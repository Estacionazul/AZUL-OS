-- Allow each establishment to reuse its own catalog codes and order numbers.
-- The initial schema used global UNIQUE constraints, which conflict with tenant isolation.
-- Existing rows are preserved; the new unique indexes scope each key to its establishment.

ALTER TABLE categorias DROP CONSTRAINT categorias_nombre_key;
ALTER TABLE productos DROP CONSTRAINT productos_codigo_key;
ALTER TABLE insumos DROP CONSTRAINT insumos_codigo_key;
ALTER TABLE pedidos DROP CONSTRAINT pedidos_numero_key;

CREATE UNIQUE INDEX ux_categorias_establecimiento_nombre
  ON categorias (establecimiento_id, nombre);
CREATE UNIQUE INDEX ux_productos_establecimiento_codigo
  ON productos (establecimiento_id, codigo);
CREATE UNIQUE INDEX ux_insumos_establecimiento_codigo
  ON insumos (establecimiento_id, codigo);
CREATE UNIQUE INDEX ux_pedidos_establecimiento_numero
  ON pedidos (establecimiento_id, numero);
