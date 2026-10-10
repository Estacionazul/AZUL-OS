-- Tenant isolation for shared operational entities.
-- Safe for an empty development database and for a populated single-establishment database.
-- Refuses to guess ownership when multiple establishments and existing business data coexist.

DO $$
DECLARE
  establishment_count integer;
  has_business_data boolean := false;
  table_name text;
  business_tables text[] := ARRAY[
    'categorias','productos','insumos','recetas','clientes',
    'movimientos_inventario','pedidos','correlativos',
    'comprobantes_electronicos','resumenes_diarios','auditoria'
  ];
BEGIN
  SELECT count(*) INTO establishment_count FROM establecimientos;
  FOREACH table_name IN ARRAY business_tables LOOP
    EXECUTE format('SELECT EXISTS (SELECT 1 FROM %I LIMIT 1)', table_name)
      INTO has_business_data;
    IF has_business_data AND establishment_count <> 1 THEN
      RAISE EXCEPTION 'Migration 002 refused: table % contains data and there are % establishments. Assign ownership explicitly before retrying.', table_name, establishment_count;
    END IF;
  END LOOP;
END $$;

ALTER TABLE categorias ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
ALTER TABLE productos ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
ALTER TABLE insumos ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
ALTER TABLE recetas ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
ALTER TABLE clientes ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
ALTER TABLE movimientos_inventario ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
ALTER TABLE pedidos ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
ALTER TABLE correlativos ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
ALTER TABLE comprobantes_electronicos ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
ALTER TABLE resumenes_diarios ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);
ALTER TABLE auditoria ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);

-- Backfill only when ownership is unambiguous (exactly one establishment).
DO $$
DECLARE
  establishment_id uuid;
BEGIN
  SELECT id INTO establishment_id FROM establecimientos LIMIT 1;
  IF establishment_id IS NOT NULL THEN
    UPDATE categorias SET establecimiento_id = establishment_id WHERE establecimiento_id IS NULL;
    UPDATE productos SET establecimiento_id = establecimiento_id WHERE establecimiento_id IS NULL;
    UPDATE insumos SET establecimiento_id = establishment_id WHERE establecimiento_id IS NULL;
    UPDATE recetas SET establecimiento_id = establishment_id WHERE establecimiento_id IS NULL;
    UPDATE clientes SET establecimiento_id = establishment_id WHERE establecimiento_id IS NULL;
    UPDATE movimientos_inventario SET establecimiento_id = establishment_id WHERE establecimiento_id IS NULL;
    UPDATE pedidos SET establecimiento_id = establishment_id WHERE establecimiento_id IS NULL;
    UPDATE correlativos SET establecimiento_id = establishment_id WHERE establecimiento_id IS NULL;
    UPDATE comprobantes_electronicos SET establecimiento_id = establishment_id WHERE establecimiento_id IS NULL;
    UPDATE resumenes_diarios SET establecimiento_id = establishment_id WHERE establecimiento_id IS NULL;
    UPDATE auditoria SET establecimiento_id = establishment_id WHERE establecimiento_id IS NULL;
  END IF;
END $$;

ALTER TABLE categorias ALTER COLUMN establecimiento_id SET NOT NULL;
ALTER TABLE productos ALTER COLUMN establecimiento_id SET NOT NULL;
ALTER TABLE insumos ALTER COLUMN establecimiento_id SET NOT NULL;
ALTER TABLE recetas ALTER COLUMN establecimiento_id SET NOT NULL;
ALTER TABLE clientes ALTER COLUMN establecimiento_id SET NOT NULL;
ALTER TABLE movimientos_inventario ALTER COLUMN establecimiento_id SET NOT NULL;
ALTER TABLE pedidos ALTER COLUMN establecimiento_id SET NOT NULL;
ALTER TABLE correlativos ALTER COLUMN establecimiento_id SET NOT NULL;
ALTER TABLE comprobantes_electronicos ALTER COLUMN establecimiento_id SET NOT NULL;
ALTER TABLE resumenes_diarios ALTER COLUMN establecimiento_id SET NOT NULL;
ALTER TABLE auditoria ALTER COLUMN establecimiento_id SET NOT NULL;

CREATE INDEX ix_categorias_establecimiento_activo ON categorias (establecimiento_id, orden, nombre) WHERE activo = true;
CREATE INDEX ix_productos_establecimiento_categoria ON productos (establecimiento_id, categoria_id, nombre) WHERE activo = true;
CREATE INDEX ix_insumos_establecimiento_categoria ON insumos (establecimiento_id, categoria_id, nombre) WHERE activo = true;
CREATE INDEX ix_recetas_establecimiento_producto ON recetas (establecimiento_id, producto_id) WHERE activo = true;
CREATE INDEX ix_movimientos_inventario_establecimiento_fecha ON movimientos_inventario (establecimiento_id, fecha DESC);
CREATE INDEX ix_pedidos_establecimiento_fecha ON pedidos (establecimiento_id, fecha_apertura DESC);
CREATE INDEX ix_comprobantes_establecimiento_fecha ON comprobantes_electronicos (establecimiento_id, fecha_emision DESC);
CREATE INDEX ix_resumenes_establecimiento_fecha ON resumenes_diarios (establecimiento_id, fecha_referencia DESC);
CREATE INDEX ix_auditoria_establecimiento_fecha ON auditoria (establecimiento_id, fecha DESC);
