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
           JOIN categorias c ON c.id = p.categoria_id AND c.establecimiento_id = p.establecimiento_id
          WHERE p.establecimiento_id = $1 AND p.activo = true
            AND ($2::text IS NULL OR p.nombre ILIKE '%' || $2 || '%' OR p.codigo ILIKE '%' || $2 || '%')
            AND ($3::uuid IS NULL OR p.categoria_id = $3)
          ORDER BY p.nombre, p.codigo
          LIMIT $4 OFFSET $5`,
        [req.auth!.establishmentId, search, categoryId ?? null, limit, offset],
      ),
      pool.query(
        `SELECT count(*)::integer AS total
           FROM productos p
          WHERE p.establecimiento_id = $1 AND p.activo = true
            AND ($2::text IS NULL OR p.nombre ILIKE '%' || $2 || '%' OR p.codigo ILIKE '%' || $2 || '%')
            AND ($3::uuid IS NULL OR p.categoria_id = $3)`,
        [req.auth!.establishmentId, search, categoryId ?? null],
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

catalogRouter.get("/categories", authenticate, requirePermission("Productos"), async (req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT id, nombre AS name, icono AS icon, orden AS "sortOrder"
         FROM categorias
        WHERE establecimiento_id = $1 AND activo = true
        ORDER BY orden, nombre`,
      [req.auth!.establishmentId],
    );
    res.status(200).json({ items: result.rows });
  } catch (error) {
    next(error);
  }
});


const InsumoQuery = z.object({
  q: z.string().trim().max(100).optional(),
  categoryId: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(100).default(50),
  offset: z.coerce.number().int().min(0).max(1_000_000).default(0),
});

catalogRouter.get("/insumos", authenticate, requirePermission("Inventario"), async (req, res, next) => {
  const parsed = InsumoQuery.safeParse(req.query);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Filtros de insumos inválidos." } });
    return;
  }
  const { q, categoryId, limit, offset } = parsed.data;
  const search = q || null;
  try {
    const [items, total] = await Promise.all([
      pool.query(
        `SELECT i.id, i.codigo, i.nombre, i.descripcion,
                i.categoria_id AS "categoryId", c.nombre AS "categoryName",
                i.unidad_medida AS unit, i.stock_minimo AS "minimumStock",
                i.costo_compra AS "purchaseCost", i.emoji, i.imagen AS image,
                i.activo AS active, i.updated_at AS "updatedAt"
           FROM insumos i
           JOIN categorias c ON c.id = i.categoria_id AND c.establecimiento_id = i.establecimiento_id
          WHERE i.establecimiento_id = $1 AND i.activo = true
            AND ($2::text IS NULL OR i.nombre ILIKE '%' || $2 || '%' OR i.codigo ILIKE '%' || $2 || '%')
            AND ($3::uuid IS NULL OR i.categoria_id = $3)
          ORDER BY i.nombre, i.codigo
          LIMIT $4 OFFSET $5`,
        [req.auth!.establishmentId, search, categoryId ?? null, limit, offset],
      ),
      pool.query(
        `SELECT count(*)::integer AS total
           FROM insumos i
          WHERE i.establecimiento_id = $1 AND i.activo = true
            AND ($2::text IS NULL OR i.nombre ILIKE '%' || $2 || '%' OR i.codigo ILIKE '%' || $2 || '%')
            AND ($3::uuid IS NULL OR i.categoria_id = $3)`,
        [req.auth!.establishmentId, search, categoryId ?? null],
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


const RecipeQuery = z.object({
  q: z.string().trim().max(100).optional(),
  limit: z.coerce.number().int().min(1).max(100).default(50),
  offset: z.coerce.number().int().min(0).max(1_000_000).default(0),
});

catalogRouter.get("/recipes", authenticate, requirePermission("Recetas"), async (req, res, next) => {
  const parsed = RecipeQuery.safeParse(req.query);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Filtros de recetas inválidos." } });
    return;
  }
  const { q, limit, offset } = parsed.data;
  const search = q || null;
  try {
    const [items, total] = await Promise.all([
      pool.query(
        `SELECT r.id, r.producto_id AS "productId", p.codigo AS "productCode",
                p.nombre AS "productName", r.nombre AS name, r.activo AS active,
                COALESCE(
                  json_agg(
                    json_build_object(
                      'id', rd.id,
                      'insumoId', i.id,
                      'insumoCode', i.codigo,
                      'insumoName', i.nombre,
                      'quantity', rd.cantidad,
                      'unit', rd.unidad,
                      'order', rd.orden
                    ) ORDER BY rd.orden
                  ) FILTER (WHERE rd.id IS NOT NULL),
                  '[]'::json
                ) AS ingredients
           FROM recetas r
           JOIN productos p ON p.id = r.producto_id AND p.establecimiento_id = r.establecimiento_id
           LEFT JOIN receta_detalle rd ON rd.receta_id = r.id
           LEFT JOIN insumos i ON i.id = rd.insumo_id AND i.establecimiento_id = r.establecimiento_id
          WHERE r.establecimiento_id = $1 AND r.activo = true AND p.activo = true
            AND ($2::text IS NULL OR r.nombre ILIKE '%' || $2 || '%' OR p.nombre ILIKE '%' || $2 || '%' OR p.codigo ILIKE '%' || $2 || '%')
          GROUP BY r.id, p.id
          ORDER BY p.nombre, r.nombre
          LIMIT $3 OFFSET $4`,
        [req.auth!.establishmentId, search, limit, offset],
      ),
      pool.query(
        `SELECT count(*)::integer AS total
           FROM recetas r
           JOIN productos p ON p.id = r.producto_id AND p.establecimiento_id = r.establecimiento_id
          WHERE r.establecimiento_id = $1 AND r.activo = true AND p.activo = true
            AND ($2::text IS NULL OR r.nombre ILIKE '%' || $2 || '%' OR p.nombre ILIKE '%' || $2 || '%' OR p.codigo ILIKE '%' || $2 || '%')`,
        [req.auth!.establishmentId, search],
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
