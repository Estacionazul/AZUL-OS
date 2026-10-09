-- Tenant integrity for SUNAT documents, daily summaries and correlatives.
-- Refuse ambiguous/cross-establishment links instead of silently changing ownership.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM comprobantes_electronicos ce
      LEFT JOIN ventas v ON v.id = ce.venta_id
      LEFT JOIN comprobantes_electronicos related ON related.id = ce.comprobante_relacionado_id
     WHERE (ce.venta_id IS NOT NULL AND (v.id IS NULL OR v.establecimiento_id <> ce.establecimiento_id))
        OR (ce.comprobante_relacionado_id IS NOT NULL AND (related.id IS NULL OR related.establecimiento_id <> ce.establecimiento_id))
  ) THEN
    RAISE EXCEPTION 'Migration 007 refused: an electronic document references a sale or related document from another establishment. Resolve ownership explicitly before retrying.';
  END IF;

  IF EXISTS (
    SELECT 1
      FROM resumenes_diarios_detalles rdd
      JOIN resumenes_diarios rd ON rd.id = rdd.resumen_diario_id
      JOIN comprobantes_electronicos ce ON ce.id = rdd.comprobante_electronico_id
     WHERE rd.establecimiento_id <> ce.establecimiento_id
  ) THEN
    RAISE EXCEPTION 'Migration 007 refused: a daily summary contains an electronic document from another establishment. Resolve ownership explicitly before retrying.';
  END IF;
END $$;

ALTER TABLE resumenes_diarios_detalles
  ADD COLUMN establecimiento_id uuid REFERENCES establecimientos(id);

UPDATE resumenes_diarios_detalles rdd
   SET establecimiento_id = rd.establecimiento_id
  FROM resumenes_diarios rd
 WHERE rd.id = rdd.resumen_diario_id;

ALTER TABLE resumenes_diarios_detalles
  ALTER COLUMN establecimiento_id SET NOT NULL;

CREATE UNIQUE INDEX ux_comprobantes_id_establecimiento
  ON comprobantes_electronicos (id, establecimiento_id);
CREATE UNIQUE INDEX ux_resumenes_diarios_id_establecimiento
  ON resumenes_diarios (id, establecimiento_id);

ALTER TABLE comprobantes_electronicos
  ADD CONSTRAINT fk_comprobantes_venta_establecimiento
  FOREIGN KEY (venta_id, establecimiento_id)
  REFERENCES ventas (id, establecimiento_id);
ALTER TABLE comprobantes_electronicos
  ADD CONSTRAINT fk_comprobantes_relacionado_establecimiento
  FOREIGN KEY (comprobante_relacionado_id, establecimiento_id)
  REFERENCES comprobantes_electronicos (id, establecimiento_id);

ALTER TABLE resumenes_diarios_detalles
  ADD CONSTRAINT fk_resumen_detalle_resumen_establecimiento
  FOREIGN KEY (resumen_diario_id, establecimiento_id)
  REFERENCES resumenes_diarios (id, establecimiento_id)
  ON DELETE CASCADE;
ALTER TABLE resumenes_diarios_detalles
  ADD CONSTRAINT fk_resumen_detalle_comprobante_establecimiento
  FOREIGN KEY (comprobante_electronico_id, establecimiento_id)
  REFERENCES comprobantes_electronicos (id, establecimiento_id);

ALTER TABLE correlativos
  DROP CONSTRAINT correlativos_clave_key;
CREATE UNIQUE INDEX ux_correlativos_clave_establecimiento
  ON correlativos (clave, establecimiento_id);

ALTER TABLE comprobantes_electronicos
  DROP CONSTRAINT comprobantes_electronicos_tipo_serie_numero_key;
CREATE UNIQUE INDEX ux_comprobantes_tipo_serie_numero_establecimiento
  ON comprobantes_electronicos (establecimiento_id, tipo, serie, numero);

ALTER TABLE resumenes_diarios
  DROP CONSTRAINT resumenes_diarios_fecha_referencia_correlativo_key;
CREATE UNIQUE INDEX ux_resumenes_fecha_correlativo_establecimiento
  ON resumenes_diarios (establecimiento_id, fecha_referencia, correlativo);

CREATE INDEX ix_resumen_detalle_establecimiento_resumen
  ON resumenes_diarios_detalles (establecimiento_id, resumen_diario_id);
