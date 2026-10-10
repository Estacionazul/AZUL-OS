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
     WHERE establecimiento_id = $1 AND producto_id IS NOT NULL
     GROUP BY producto_id
    UNION ALL
    SELECT 'insumo'::text AS item_type, insumo_id AS item_id, SUM(cantidad * signo)::numeric(14,4) AS stock
      FROM movimientos_inventario
     WHERE establecimiento_id = $1 AND insumo_id IS NOT NULL
     GROUP BY insumo_id
  ),
  items AS (
    SELECT 'producto'::text AS "itemType", p.id, p.codigo AS code, p.nombre AS name,
           c.nombre AS category, p.stock_minimo AS "minimumStock",
           COALESCE(sm.stock, 0)::numeric(14,4) AS "currentStock", p.activo AS active
      FROM productos p
      JOIN categorias c ON c.id = p.categoria_id AND c.establecimiento_id = p.establecimiento_id
      LEFT JOIN stock_movements sm ON sm.item_id = p.id AND sm.item_type = 'producto'
     WHERE p.establecimiento_id = $1 AND p.tipo_inventario = 'producto'
    UNION ALL
    SELECT 'insumo'::text AS "itemType", i.id, i.codigo AS code, i.nombre AS name,
           c.nombre AS category, i.stock_minimo AS "minimumStock",
           COALESCE(sm.stock, 0)::numeric(14,4) AS "currentStock", i.activo AS active
      FROM insumos i
      JOIN categorias c ON c.id = i.categoria_id AND c.establecimiento_id = i.establecimiento_id
      LEFT JOIN stock_movements sm ON sm.item_id = i.id AND sm.item_type = 'insumo'
     WHERE i.establecimiento_id = $1
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
    AND ($2::text IS NULL OR "itemType" = $2)
    AND ($3::text IS NULL OR name ILIKE '%' || $3 || '%' OR code ILIKE '%' || $3 || '%')
    AND (NOT $4::boolean OR "currentStock" <= "minimumStock")`;
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
          LIMIT $5 OFFSET $6`,
        [req.auth!.establishmentId, typeFilter, search, lowOnly, limit, offset],
      ),
      pool.query(
        `${stockCte}
         SELECT count(*)::integer AS total
           FROM items
          WHERE ${filterSql}`,
        [req.auth!.establishmentId, typeFilter, search, lowOnly],
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
          WHERE m.establecimiento_id = $1
            AND ($2::uuid IS NULL OR m.producto_id = $2)
            AND ($3::uuid IS NULL OR m.insumo_id = $3)
            AND ($4::uuid IS NULL OR m.producto_id = $4 OR m.insumo_id = $4)
            AND ($5::text IS NULL OR ($5 = 'producto' AND m.producto_id IS NOT NULL)
                                 OR ($5 = 'insumo' AND m.insumo_id IS NOT NULL))
          ORDER BY m.fecha DESC, m.id DESC
          LIMIT $6 OFFSET $7`,
        [req.auth!.establishmentId, productId, insumoId, anyId, typeFilter, limit, offset],
      ),
      pool.query(
        `SELECT count(*)::integer AS total
           FROM movimientos_inventario m
          WHERE m.establecimiento_id = $1
            AND ($2::uuid IS NULL OR m.producto_id = $2)
            AND ($3::uuid IS NULL OR m.insumo_id = $3)
            AND ($4::uuid IS NULL OR m.producto_id = $4 OR m.insumo_id = $4)
            AND ($5::text IS NULL OR ($5 = 'producto' AND m.producto_id IS NOT NULL)
                                 OR ($5 = 'insumo' AND m.insumo_id IS NOT NULL))`,
        [req.auth!.establishmentId, productId, insumoId, anyId, typeFilter],
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


const MovementBody = z.object({
  itemType: z.enum(["producto", "insumo"]),
  itemId: z.string().uuid(),
  type: z.enum(["ENTRADA", "SALIDA", "AJUSTE"]),
  quantity: z.number().finite().positive().max(1_000_000_000)
    .refine((value) => Number.isInteger(value * 10_000), "La cantidad admite hasta cuatro decimales."),
  sign: z.union([z.literal(-1), z.literal(1)]).optional(),
  referenceId: z.string().uuid().optional(),
  note: z.string().trim().max(500).optional(),
}).superRefine((value, ctx) => {
  if (value.type === "AJUSTE" && value.sign === undefined) {
    ctx.addIssue({ code: "custom", path: ["sign"], message: "Un ajuste requiere indicar si aumenta o disminuye el stock." });
  }
  if (value.type === "ENTRADA" && value.sign === -1) {
    ctx.addIssue({ code: "custom", path: ["sign"], message: "Una entrada debe aumentar el stock." });
  }
  if (value.type === "SALIDA" && value.sign === 1) {
    ctx.addIssue({ code: "custom", path: ["sign"], message: "Una salida debe disminuir el stock." });
  }
});

inventoryRouter.post("/movements", authenticate, requirePermission("Inventario"), async (req, res, next) => {
  const parsed = MovementBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Datos del movimiento inválidos." } });
    return;
  }
  const idempotencyKey = req.header("idempotency-key");
  if (!idempotencyKey || !z.string().uuid().safeParse(idempotencyKey).success) {
    res.status(400).json({ error: { code: "IDEMPOTENCY_KEY_REQUIRED", message: "Envía una clave UUID en el encabezado Idempotency-Key." } });
    return;
  }

  const input = parsed.data;
  const sign = input.type === "ENTRADA" ? 1 : input.type === "SALIDA" ? -1 : input.sign!;
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query("SELECT pg_advisory_xact_lock(hashtext($1))", [idempotencyKey]);

    const prior = await client.query(
      `SELECT id, establecimiento_id, producto_id, insumo_id, tipo, cantidad, signo,
              referencia_id, observacion
         FROM movimientos_inventario WHERE idempotency_key = $1`,
      [idempotencyKey],
    );
    if (prior.rowCount) {
      const row = prior.rows[0];
      const sameRequest =
        row.establecimiento_id === req.auth!.establishmentId &&
        row.producto_id === (input.itemType === "producto" ? input.itemId : null) &&
        row.insumo_id === (input.itemType === "insumo" ? input.itemId : null) &&
        row.tipo === input.type &&
        Number(row.cantidad) === input.quantity &&
        Number(row.signo) === sign &&
        row.referencia_id === (input.referenceId ?? null) &&
        row.observacion === (input.note ?? null);
      await client.query("COMMIT");
      if (!sameRequest) {
        res.status(409).json({ error: { code: "IDEMPOTENCY_CONFLICT", message: "La clave ya se usó para un movimiento distinto." } });
        return;
      }
      res.status(200).json({ id: row.id, replayed: true });
      return;
    }

    const itemResult = input.itemType === "producto"
      ? await client.query(
          "SELECT id, nombre, emoji, ''::text AS unidad, activo, tipo_inventario FROM productos WHERE id = $1 AND establecimiento_id = $2 FOR UPDATE",
          [input.itemId, req.auth!.establishmentId],
        )
      : await client.query(
          "SELECT id, nombre, emoji, unidad_medida AS unidad, activo, 'insumo'::text AS tipo_inventario FROM insumos WHERE id = $1 AND establecimiento_id = $2 FOR UPDATE",
          [input.itemId, req.auth!.establishmentId],
        );
    const item = itemResult.rows[0];
    if (!item || !item.activo) {
      await client.query("ROLLBACK");
      res.status(404).json({ error: { code: "ITEM_NOT_FOUND", message: "El producto o insumo no existe o está inactivo." } });
      return;
    }
    if (input.itemType === "producto" && item.tipo_inventario === "receta") {
      await client.query("ROLLBACK");
      res.status(409).json({ error: { code: "RECIPE_STOCK_CONTROLLED", message: "Los productos de receta no admiten movimientos manuales de stock." } });
      return;
    }

    const stockResult = input.itemType === "producto"
      ? await client.query(
          "SELECT COALESCE(SUM(cantidad * signo), 0)::numeric(14,4) AS stock FROM movimientos_inventario WHERE producto_id = $1 AND establecimiento_id = $2",
          [input.itemId, req.auth!.establishmentId],
        )
      : await client.query(
          "SELECT COALESCE(SUM(cantidad * signo), 0)::numeric(14,4) AS stock FROM movimientos_inventario WHERE insumo_id = $1 AND establecimiento_id = $2",
          [input.itemId, req.auth!.establishmentId],
        );
    const currentStock = Number(stockResult.rows[0].stock);
    if (currentStock + input.quantity * sign < -0.0000001) {
      await client.query("ROLLBACK");
      res.status(409).json({ error: { code: "STOCK_INSUFFICIENTE", message: "El movimiento dejaría el stock en negativo." } });
      return;
    }

    const inserted = await client.query(
      `INSERT INTO movimientos_inventario
         (establecimiento_id, tipo, nombre_item, emoji, unidad, referencia_id, insumo_id, producto_id,
          cantidad, signo, observacion, usuario_id, dispositivo_id, idempotency_key)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
       RETURNING id`,
      [
        req.auth!.establishmentId, input.type, item.nombre, item.emoji ?? "📦", item.unidad ?? "",
        input.referenceId ?? null,
        input.itemType === "insumo" ? input.itemId : null,
        input.itemType === "producto" ? input.itemId : null,
        input.quantity, sign, input.note ?? null,
        req.auth!.userId, req.auth!.deviceId, idempotencyKey,
      ],
    );
    await client.query("COMMIT");
    res.status(201).json({ id: inserted.rows[0].id, replayed: false });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => undefined);
    next(error);
  } finally {
    client.release();
  }
});
