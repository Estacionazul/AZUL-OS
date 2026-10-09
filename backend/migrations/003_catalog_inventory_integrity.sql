-- Database-level tenant integrity for catalog and inventory relationships.
-- Existing cross-establishment links are rejected rather than silently reassigned.

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM receta_detalle rd
      JOIN recetas r ON r.id = rd.receta_id
      JOIN insumos i ON i.id = rd.insumo_id
     WHERE r.establecimiento_id <> i.establecimiento_id
  ) THEN
    RAISE EXCEPTION 'Migration 003 refused: receta_detalle contains ingredients owned by a different establishment. Correct ownership explicitly before retrying.';
  END IF;
END $$;

CREATE UNIQUE INDEX ux_categorias_id_establecimiento
  ON categorias (id, establecimiento_id);
CREATE UNIQUE INDEX ux_productos_id_establecimiento
  ON productos (id, establecimiento_id);
CREATE UNIQUE INDEX ux_insumos_id_establecimiento
  ON insumos (id, establecimiento_id);
CREATE UNIQUE INDEX ux_recetas_id_establecimiento
  ON recetas (id, establecimiento_id);

ALTER TABLE productos
  ADD CONSTRAINT fk_productos_categoria_establecimiento
  FOREIGN KEY (categoria_id, establecimiento_id)
  REFERENCES categorias (id, establecimiento_id);

ALTER TABLE insumos
  ADD CONSTRAINT fk_insumos_categoria_establecimiento
  FOREIGN KEY (categoria_id, establecimiento_id)
  REFERENCES categorias (id, establecimiento_id);

ALTER TABLE recetas
  ADD CONSTRAINT fk_recetas_producto_establecimiento
  FOREIGN KEY (producto_id, establecimiento_id)
  REFERENCES productos (id, establecimiento_id);

ALTER TABLE movimientos_inventario
  ADD CONSTRAINT fk_movimientos_producto_establecimiento
  FOREIGN KEY (producto_id, establecimiento_id)
  REFERENCES productos (id, establecimiento_id);

ALTER TABLE movimientos_inventario
  ADD CONSTRAINT fk_movimientos_insumo_establecimiento
  FOREIGN KEY (insumo_id, establecimiento_id)
  REFERENCES insumos (id, establecimiento_id);

-- receta_detalle does not store establishment_id, so enforce ownership by
-- resolving both parents. This also protects updates, not only inserts.
CREATE FUNCTION validar_receta_detalle_establecimiento()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  receta_establecimiento uuid;
  insumo_establecimiento uuid;
BEGIN
  SELECT establecimiento_id
    INTO receta_establecimiento
    FROM recetas
   WHERE id = NEW.receta_id;

  SELECT establecimiento_id
    INTO insumo_establecimiento
    FROM insumos
   WHERE id = NEW.insumo_id;

  IF receta_establecimiento IS NULL OR insumo_establecimiento IS NULL THEN
    RAISE EXCEPTION 'Recipe and ingredient must exist before linking them.';
  END IF;

  IF receta_establecimiento <> insumo_establecimiento THEN
    RAISE EXCEPTION 'Recipe and ingredient must belong to the same establishment.';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_receta_detalle_establecimiento
  BEFORE INSERT OR UPDATE OF receta_id, insumo_id
  ON receta_detalle
  FOR EACH ROW
  EXECUTE FUNCTION validar_receta_detalle_establecimiento();
