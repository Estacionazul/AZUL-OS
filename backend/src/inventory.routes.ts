import { Router } from "express";
import { z } from "zod";
import { pool } from "./db.js";
import { authenticate, requirePermission } from "./auth.js";

export const inventoryRouter = Router();

const StockQuery = z.object({
  itemType: z.enum(["producto", "insumo", "todos"]).default("todos"),
  q: z.string().trim().max(100).optional(),
  lowStockOnly: z.enum(["true", "false"]).default("false"),
  limit: z.coerce.number().int().min(1).max(100).default(50),
  offset: z.coerce.number().int().min(0).max(1_000_000).default(0),
});

const stockCte = `
  WITH stock_movements AS (
    SELECT 'producto'::text AS item_type, producto_id AS item_id, SUM(cantidad * signo)::numeric(14,4) AS stock
      FROM movimientos_inventario
     WHERE producto_id IS NOT NULL
     GROUP BY producto_id
    UNION ALL
    SELECT 'insumo'::text AS item_type, insumo_id AS item_id, SUM(cantidad * signo)::numeric(14,4) AS stock
      FROM movimientos_inventario
     WHERE insumo_id IS NOT NULL
     GROUP BY insumo_id
  ),
  items AS (
    SELECT 'producto'::text AS "itemType", p.id, p.codigo AS code, p.nombre AS name,
           c.nombre AS category, p.stock_minimo AS "minimumStock",
           COALESCE(sm.stock, 0)::numeric(14,4) AS "currentStock", p.activo AS active
      FROM productos p
      JOIN categorias c ON c.id = p.categoria_id
      LEFT JOIN stock_movements sm ON sm.item_id = p.id AND sm.item_type = 'producto'
     WHERE p.tipo_inventario = 'producto'
    UNION ALL
    SELECT 'insumo'::text AS "itemType", i.id, i.codigo AS code, i.nombre AS name,
           c.nombre AS category, i.stock_minimo AS "minimumStock",
           COALESCE(sm.stock, 0)::numeric(14,4) AS "currentStock", i.activo AS active
      FROM insumos i
      JOIN categorias c ON c.id = i.categoria_id
      LEFT JOIN stock_movements sm ON sm.item_id = i.id AND sm.item_type = 'insumo'
  )
`;

inventoryRouter.get("/stock", authenticate, requirePermission("Inventario"), async (req, res, next) => {
  const parsed = StockQuery.safeParse(req.query);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Filtros de inventario inválidos." } });
    return;
  }
  const { itemType, q, lowStockOnly, limit, offset } = parsed.data;
  const typeFilter = itemType === "todos" ? null : itemType;
  const search = q || null;
  const lowOnly = lowStockOnly === "true";
  const filterSql = `active = true
    AND ($1::text IS NULL OR "itemType" = $1)
    AND ($2::text IS NULL OR name ILIKE '%' || $2 || '%' OR code ILIKE '%' || $2 || '%')
    AND (NOT $3::boolean OR "currentStock" <= "minimumStock")`;
  try {
    const [items, total] = await Promise.all([
      pool.query(
        `${stockCte}
         SELECT "itemType", id, code, name, category, "minimumStock", "currentStock",
                ("currentStock" <= "minimumStock") AS "lowStock",
                CASE
                  WHEN "currentStock" <= 0 THEN 'AGOTADO'
                  WHEN "currentStock" <= "minimumStock" THEN 'BAJO'
                  ELSE 'OK'
                END AS status
           FROM items
          WHERE ${filterSql}
          ORDER BY name, code
          LIMIT $4 OFFSET $5`,
        [typeFilter, search, lowOnly, limit, offset],
      ),
      pool.query(
        `${stockCte}
         SELECT count(*)::integer AS total
           FROM items
          WHERE ${filterSql}`,
        [typeFilter, search, lowOnly],
      ),
    ]);
    res.status(200).json({
      items: items.rows,
      pagination: { limit, offset, total: total.rows[0].total },
    });
  } catch (error) {
    next(error);
  }
});

const MovementQuery = z.object({
  itemId: z.string().uuid().optional(),
  itemType: z.enum(["producto", "insumo"]).optional(),
  limit: z.coerce.number().int().min(1).max(100).default(50),
  offset: z.coerce.number().int().min(0).max(1_000_000).default(0),
});

inventoryRouter.get("/movements", authenticate, requirePermission("Inventario"), async (req, res, next) => {
  const parsed = MovementQuery.safeParse(req.query);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Filtros de movimientos inválidos." } });
    return;
  }
  const { itemId, itemType, limit, offset } = parsed.data;
  const productId = itemType === "producto" ? itemId ?? null : null;
  const insumoId = itemType === "insumo" ? itemId ?? null : null;
  const anyId = itemType ? null : itemId ?? null;
  const typeFilter = itemType ?? null;
  try {
    const [items, total] = await Promise.all([
      pool.query(
        `SELECT m.id, m.fecha AS "date", m.tipo AS type, m.nombre_item AS "itemName",
                m.unidad AS unit, m.cantidad AS quantity, m.signo AS sign,
                (m.cantidad * m.signo)::numeric(14,4) AS delta,
                m.referencia_id AS "referenceId", m.observacion AS note,
                m.producto_id AS "productId", m.insumo_id AS "insumoId",
                m.usuario_id AS "userId", m.dispositivo_id AS "deviceId"
           FROM movimientos_inventario m
          WHERE ($1::uuid IS NULL OR m.producto_id = $1)
            AND ($2::uuid IS NULL OR m.insumo_id = $2)
            AND ($3::uuid IS NULL OR m.producto_id = $3 OR m.insumo_id = $3)
            AND ($4::text IS NULL OR ($4 = 'producto' AND m.producto_id IS NOT NULL)
                                 OR ($4 = 'insumo' AND m.insumo_id IS NOT NULL))
          ORDER BY m.fecha DESC, m.id DESC
          LIMIT $5 OFFSET $6`,
        [productId, insumoId, anyId, typeFilter, limit, offset],
      ),
      pool.query(
        `SELECT count(*)::integer AS total
           FROM movimientos_inventario m
          WHERE ($1::uuid IS NULL OR m.producto_id = $1)
            AND ($2::uuid IS NULL OR m.insumo_id = $2)
            AND ($3::uuid IS NULL OR m.producto_id = $3 OR m.insumo_id = $3)
            AND ($4::text IS NULL OR ($4 = 'producto' AND m.producto_id IS NOT NULL)
                                 OR ($4 = 'insumo' AND m.insumo_id IS NOT NULL))`,
        [productId, insumoId, anyId, typeFilter],
      ),
    ]);
    res.status(200).json({
      items: items.rows,
      pagination: { limit, offset, total: total.rows[0].total },
    });
  } catch (error) {
    next(error);
  }
});
