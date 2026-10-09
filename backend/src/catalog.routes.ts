import { Router } from "express";
import { z } from "zod";
import { pool } from "./db.js";
import { authenticate, requirePermission } from "./auth.js";

export const catalogRouter = Router();

const ProductQuery = z.object({
  q: z.string().trim().max(100).optional(),
  categoryId: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(100).default(50),
  offset: z.coerce.number().int().min(0).max(1_000_000).default(0),
});

catalogRouter.get("/products", authenticate, requirePermission("Productos"), async (req, res, next) => {
  const parsed = ProductQuery.safeParse(req.query);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Filtros de productos inválidos." } });
    return;
  }
  const { q, categoryId, limit, offset } = parsed.data;
  const search = q || null;
  try {
    const [items, total] = await Promise.all([
      pool.query(
        `SELECT p.id, p.codigo, p.codigo_barras, p.nombre, p.descripcion,
                p.categoria_id AS "categoryId", c.nombre AS "categoryName",
                p.costo, p.precio_venta AS "salePrice", p.stock_minimo AS "minimumStock",
                p.tipo_inventario AS "inventoryType", p.tipo_afectacion_igv AS "igvAffectation",
                p.emoji, p.imagen AS "image", p.activo AS active, p.updated_at AS "updatedAt"
           FROM productos p
           JOIN categorias c ON c.id = p.categoria_id
          WHERE p.activo = true
            AND ($1::text IS NULL OR p.nombre ILIKE '%' || $1 || '%' OR p.codigo ILIKE '%' || $1 || '%')
            AND ($2::uuid IS NULL OR p.categoria_id = $2)
          ORDER BY p.nombre, p.codigo
          LIMIT $3 OFFSET $4`,
        [search, categoryId ?? null, limit, offset],
      ),
      pool.query(
        `SELECT count(*)::integer AS total
           FROM productos p
          WHERE p.activo = true
            AND ($1::text IS NULL OR p.nombre ILIKE '%' || $1 || '%' OR p.codigo ILIKE '%' || $1 || '%')
            AND ($2::uuid IS NULL OR p.categoria_id = $2)`,
        [search, categoryId ?? null],
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

catalogRouter.get("/categories", authenticate, requirePermission("Productos"), async (_req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT id, nombre AS name, icono AS icon, orden AS "sortOrder"
         FROM categorias
        WHERE activo = true
        ORDER BY orden, nombre`,
    );
    res.status(200).json({ items: result.rows });
  } catch (error) {
    next(error);
  }
});
