import { Router, type NextFunction, type Request, type Response } from "express";
import { randomUUID } from "node:crypto";
import { z } from "zod";
import { pool } from "./db.js";
import { authenticate } from "./auth.js";

export const catalogAdminRouter = Router();

function requireCeo(req: Request, res: Response, next: NextFunction): void {
  if (!req.auth) {
    res.status(401).json({ error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." } });
    return;
  }
  if (req.auth.role !== "CEO") {
    res.status(403).json({ error: { code: "CEO_REQUIRED", message: "Esta operación está reservada al CEO." } });
    return;
  }
  next();
}

catalogAdminRouter.use(authenticate, requireCeo);

function isDuplicate(error: unknown): boolean {
  return typeof error === "object" && error !== null && "code" in error && error.code === "23505";
}

function validationError(res: Response, message: string): void {
  res.status(400).json({ error: { code: "VALIDATION_ERROR", message } });
}

const CategoryBody = z.object({
  name: z.string().trim().min(2).max(100),
  icon: z.string().trim().min(1).max(20).default("📦"),
  sortOrder: z.number().int().min(0).max(100000).default(0),
});
const CategoryUpdate = CategoryBody.partial().extend({ active: z.boolean().optional() }).strict()
  .refine((value) => Object.keys(value).length > 0, "Indica al menos un cambio.");

catalogAdminRouter.post("/categories", async (req, res, next) => {
  const parsed = CategoryBody.safeParse(req.body);
  if (!parsed.success) return validationError(res, "Datos de categoría inválidos.");
  try {
    const result = await pool.query(
      `INSERT INTO categorias (id, establecimiento_id, nombre, icono, orden)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, nombre AS name, icono AS icon, orden AS "sortOrder", activo AS active`,
      [randomUUID(), req.auth!.establishmentId, parsed.data.name, parsed.data.icon, parsed.data.sortOrder],
    );
    res.status(201).json({ category: result.rows[0] });
  } catch (error) {
    if (isDuplicate(error)) return res.status(409).json({ error: { code: "CATEGORY_ALREADY_EXISTS", message: "Ya existe una categoría con ese nombre." } });
    next(error);
  }
});

catalogAdminRouter.patch("/categories/:id", async (req, res, next) => {
  const id = z.string().uuid().safeParse(req.params.id);
  const parsed = CategoryUpdate.safeParse(req.body);
  if (!id.success || !parsed.success) return validationError(res, "Identificador o cambios de categoría inválidos.");
  const columns: Record<string, string> = { name: "nombre", icon: "icono", sortOrder: "orden", active: "activo" };
  const values: unknown[] = [id.data, req.auth!.establishmentId];
  const sets: string[] = [];
  for (const [key, value] of Object.entries(parsed.data)) {
    values.push(value);
    sets.push(`${columns[key]} = $${values.length}`);
  }
  sets.push("updated_at = now()");
  try {
    const result = await pool.query(
      `UPDATE categorias SET ${sets.join(", ")}
        WHERE id = $1 AND establecimiento_id = $2
        RETURNING id, nombre AS name, icono AS icon, orden AS "sortOrder", activo AS active`,
      values,
    );
    if (!result.rowCount) return res.status(404).json({ error: { code: "CATEGORY_NOT_FOUND", message: "No se encontró la categoría." } });
    res.status(200).json({ category: result.rows[0] });
  } catch (error) {
    if (isDuplicate(error)) return res.status(409).json({ error: { code: "CATEGORY_ALREADY_EXISTS", message: "Ya existe una categoría con ese nombre." } });
    next(error);
  }
});

const ProductBody = z.object({
  code: z.string().trim().min(1).max(80),
  barcode: z.string().trim().max(100).optional(),
  name: z.string().trim().min(1).max(200),
  description: z.string().max(1000).default(""),
  categoryId: z.string().uuid(),
  cost: z.number().finite().min(0).max(999999999.99).default(0),
  salePrice: z.number().finite().min(0).max(999999999.99),
  minimumStock: z.number().finite().min(0).max(999999999.9999).default(0),
  inventoryType: z.enum(["producto", "receta"]).default("producto"),
  igvAffectation: z.string().regex(/^\d{2}$/).default("10"),
  emoji: z.string().trim().min(1).max(20).default("📦"),
  image: z.string().max(2000).default(""),
});
const ProductUpdate = ProductBody.partial().extend({ active: z.boolean().optional() }).strict()
  .refine((value) => Object.keys(value).length > 0, "Indica al menos un cambio.");
const productColumns: Record<string, string> = {
  code: "codigo", barcode: "codigo_barras", name: "nombre", description: "descripcion",
  categoryId: "categoria_id", cost: "costo", salePrice: "precio_venta",
  minimumStock: "stock_minimo", inventoryType: "tipo_inventario",
  igvAffectation: "tipo_afectacion_igv", emoji: "emoji", image: "imagen", active: "activo",
};

async function categoryBelongsToEstablishment(categoryId: string, establishmentId: string): Promise<boolean> {
  const result = await pool.query(
    "SELECT 1 FROM categorias WHERE id = $1 AND establecimiento_id = $2 AND activo = true",
    [categoryId, establishmentId],
  );
  return Boolean(result.rowCount);
}

catalogAdminRouter.post("/products", async (req, res, next) => {
  const parsed = ProductBody.safeParse(req.body);
  if (!parsed.success) return validationError(res, "Datos del producto inválidos.");
  try {
    if (!await categoryBelongsToEstablishment(parsed.data.categoryId, req.auth!.establishmentId)) {
      res.status(404).json({ error: { code: "CATEGORY_NOT_FOUND", message: "No se encontró la categoría activa del establecimiento." } });
      return;
    }
    const p = parsed.data;
    const result = await pool.query(
      `INSERT INTO productos
         (id, establecimiento_id, codigo, codigo_barras, nombre, descripcion, categoria_id,
          costo, precio_venta, stock_minimo, tipo_inventario, tipo_afectacion_igv, emoji, imagen)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
       RETURNING id, codigo AS code, codigo_barras AS barcode, nombre AS name,
                 descripcion AS description, categoria_id AS "categoryId", costo AS cost,
                 precio_venta AS "salePrice", stock_minimo AS "minimumStock",
                 tipo_inventario AS "inventoryType", tipo_afectacion_igv AS "igvAffectation",
                 emoji, imagen AS image, activo AS active, updated_at AS "updatedAt"`,
      [randomUUID(), req.auth!.establishmentId, p.code, p.barcode ?? null, p.name, p.description,
       p.categoryId, p.cost, p.salePrice, p.minimumStock, p.inventoryType, p.igvAffectation, p.emoji, p.image],
    );
    res.status(201).json({ product: result.rows[0] });
  } catch (error) {
    if (isDuplicate(error)) return res.status(409).json({ error: { code: "PRODUCT_CODE_ALREADY_EXISTS", message: "Ya existe un producto con ese código." } });
    next(error);
  }
});

catalogAdminRouter.patch("/products/:id", async (req, res, next) => {
  const id = z.string().uuid().safeParse(req.params.id);
  const parsed = ProductUpdate.safeParse(req.body);
  if (!id.success || !parsed.success) return validationError(res, "Identificador o cambios de producto inválidos.");
  if (parsed.data.categoryId && !await categoryBelongsToEstablishment(parsed.data.categoryId, req.auth!.establishmentId)) {
    res.status(404).json({ error: { code: "CATEGORY_NOT_FOUND", message: "No se encontró la categoría activa del establecimiento." } });
    return;
  }
  const values: unknown[] = [id.data, req.auth!.establishmentId];
  const sets: string[] = [];
  for (const [key, value] of Object.entries(parsed.data)) {
    values.push(value);
    sets.push(`${productColumns[key]} = $${values.length}`);
  }
  sets.push("updated_at = now()");
  try {
    const result = await pool.query(
      `UPDATE productos SET ${sets.join(", ")}
        WHERE id = $1 AND establecimiento_id = $2
        RETURNING id, codigo AS code, codigo_barras AS barcode, nombre AS name,
                  descripcion AS description, categoria_id AS "categoryId", costo AS cost,
                  precio_venta AS "salePrice", stock_minimo AS "minimumStock",
                  tipo_inventario AS "inventoryType", tipo_afectacion_igv AS "igvAffectation",
                  emoji, imagen AS image, activo AS active, updated_at AS "updatedAt"`,
      values,
    );
    if (!result.rowCount) return res.status(404).json({ error: { code: "PRODUCT_NOT_FOUND", message: "No se encontró el producto." } });
    res.status(200).json({ product: result.rows[0] });
  } catch (error) {
    if (isDuplicate(error)) return res.status(409).json({ error: { code: "PRODUCT_CODE_ALREADY_EXISTS", message: "Ya existe un producto con ese código." } });
    next(error);
  }
});

const InsumoBody = z.object({
  code: z.string().trim().min(1).max(80),
  name: z.string().trim().min(1).max(200),
  description: z.string().max(1000).default(""),
  categoryId: z.string().uuid(),
  unit: z.string().trim().min(1).max(40),
  minimumStock: z.number().finite().min(0).max(999999999.9999).default(0),
  purchaseCost: z.number().finite().min(0).max(999999999.99).default(0),
  emoji: z.string().trim().min(1).max(20).default("📦"),
  image: z.string().max(2000).default(""),
});
const InsumoUpdate = InsumoBody.partial().extend({ active: z.boolean().optional() }).strict()
  .refine((value) => Object.keys(value).length > 0, "Indica al menos un cambio.");
const insumoColumns: Record<string, string> = {
  code: "codigo", name: "nombre", description: "descripcion", categoryId: "categoria_id",
  unit: "unidad_medida", minimumStock: "stock_minimo", purchaseCost: "costo_compra",
  emoji: "emoji", image: "imagen", active: "activo",
};

catalogAdminRouter.post("/insumos", async (req, res, next) => {
  const parsed = InsumoBody.safeParse(req.body);
  if (!parsed.success) return validationError(res, "Datos del insumo inválidos.");
  try {
    if (!await categoryBelongsToEstablishment(parsed.data.categoryId, req.auth!.establishmentId)) {
      res.status(404).json({ error: { code: "CATEGORY_NOT_FOUND", message: "No se encontró la categoría activa del establecimiento." } });
      return;
    }
    const i = parsed.data;
    const result = await pool.query(
      `INSERT INTO insumos
         (id, establecimiento_id, codigo, nombre, descripcion, categoria_id, unidad_medida,
          stock_minimo, costo_compra, emoji, imagen)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING id, codigo AS code, nombre AS name, descripcion AS description,
                 categoria_id AS "categoryId", unidad_medida AS unit,
                 stock_minimo AS "minimumStock", costo_compra AS "purchaseCost",
                 emoji, imagen AS image, activo AS active, updated_at AS "updatedAt"`,
      [randomUUID(), req.auth!.establishmentId, i.code, i.name, i.description, i.categoryId,
       i.unit, i.minimumStock, i.purchaseCost, i.emoji, i.image],
    );
    res.status(201).json({ insumo: result.rows[0] });
  } catch (error) {
    if (isDuplicate(error)) return res.status(409).json({ error: { code: "INSUMO_CODE_ALREADY_EXISTS", message: "Ya existe un insumo con ese código." } });
    next(error);
  }
});

catalogAdminRouter.patch("/insumos/:id", async (req, res, next) => {
  const id = z.string().uuid().safeParse(req.params.id);
  const parsed = InsumoUpdate.safeParse(req.body);
  if (!id.success || !parsed.success) return validationError(res, "Identificador o cambios de insumo inválidos.");
  if (parsed.data.categoryId && !await categoryBelongsToEstablishment(parsed.data.categoryId, req.auth!.establishmentId)) {
    res.status(404).json({ error: { code: "CATEGORY_NOT_FOUND", message: "No se encontró la categoría activa del establecimiento." } });
    return;
  }
  const values: unknown[] = [id.data, req.auth!.establishmentId];
  const sets: string[] = [];
  for (const [key, value] of Object.entries(parsed.data)) {
    values.push(value);
    sets.push(`${insumoColumns[key]} = $${values.length}`);
  }
  sets.push("updated_at = now()");
  try {
    const result = await pool.query(
      `UPDATE insumos SET ${sets.join(", ")}
        WHERE id = $1 AND establecimiento_id = $2
        RETURNING id, codigo AS code, nombre AS name, descripcion AS description,
                  categoria_id AS "categoryId", unidad_medida AS unit,
                  stock_minimo AS "minimumStock", costo_compra AS "purchaseCost",
                  emoji, imagen AS image, activo AS active, updated_at AS "updatedAt"`,
      values,
    );
    if (!result.rowCount) return res.status(404).json({ error: { code: "INSUMO_NOT_FOUND", message: "No se encontró el insumo." } });
    res.status(200).json({ insumo: result.rows[0] });
  } catch (error) {
    if (isDuplicate(error)) return res.status(409).json({ error: { code: "INSUMO_CODE_ALREADY_EXISTS", message: "Ya existe un insumo con ese código." } });
    next(error);
  }
});
