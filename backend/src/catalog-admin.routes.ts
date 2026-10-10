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


const RecipeIngredient = z.object({
  insumoId: z.string().uuid(),
  quantity: z.number().finite().positive().max(1_000_000_000)
    .refine((value) => Number.isInteger(value * 10_000), "La cantidad admite hasta cuatro decimales."),
  unit: z.string().trim().min(1).max(40).default("unid"),
  order: z.number().int().min(0).max(100000).optional(),
});
const RecipeBody = z.object({
  productId: z.string().uuid(),
  name: z.string().trim().min(1).max(200),
  ingredients: z.array(RecipeIngredient).min(1).max(200),
}).superRefine((value, ctx) => {
  const ids = value.ingredients.map((ingredient) => ingredient.insumoId);
  if (new Set(ids).size !== ids.length) {
    ctx.addIssue({ code: "custom", path: ["ingredients"], message: "No repitas un mismo insumo en la receta." });
  }
});
const RecipeUpdate = z.object({
  name: z.string().trim().min(1).max(200).optional(),
  active: z.boolean().optional(),
  ingredients: z.array(RecipeIngredient).min(1).max(200).optional(),
}).strict().superRefine((value, ctx) => {
  if (Object.keys(value).length === 0) {
    ctx.addIssue({ code: "custom", message: "Indica al menos un cambio." });
  }
  if (value.ingredients) {
    const ids = value.ingredients.map((ingredient) => ingredient.insumoId);
    if (new Set(ids).size !== ids.length) {
      ctx.addIssue({ code: "custom", path: ["ingredients"], message: "No repitas un mismo insumo en la receta." });
    }
  }
});

async function validateRecipeIngredients(
  client: import("pg").PoolClient,
  establishmentId: string,
  ingredients: z.infer<typeof RecipeIngredient>[],
): Promise<boolean> {
  const ids = ingredients.map((ingredient) => ingredient.insumoId);
  const found = await client.query(
    "SELECT id FROM insumos WHERE establecimiento_id = $1 AND activo = true AND id = ANY($2::uuid[])",
    [establishmentId, ids],
  );
  return found.rowCount === new Set(ids).size;
}

async function insertRecipeIngredients(
  client: import("pg").PoolClient,
  recipeId: string,
  ingredients: z.infer<typeof RecipeIngredient>[],
): Promise<void> {
  for (let index = 0; index < ingredients.length; index++) {
    const ingredient = ingredients[index];
    await client.query(
      `INSERT INTO receta_detalle (id, receta_id, insumo_id, cantidad, unidad, orden)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [randomUUID(), recipeId, ingredient.insumoId, ingredient.quantity, ingredient.unit, ingredient.order ?? index],
    );
  }
}

catalogAdminRouter.post("/recipes", async (req, res, next) => {
  const parsed = RecipeBody.safeParse(req.body);
  if (!parsed.success) return validationError(res, "Datos de receta inválidos.");
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const product = await client.query(
      "SELECT id FROM productos WHERE id = $1 AND establecimiento_id = $2 AND activo = true FOR UPDATE",
      [parsed.data.productId, req.auth!.establishmentId],
    );
    if (!product.rowCount) {
      await client.query("ROLLBACK");
      res.status(404).json({ error: { code: "PRODUCT_NOT_FOUND", message: "No se encontró un producto activo del establecimiento." } });
      return;
    }
    if (!await validateRecipeIngredients(client, req.auth!.establishmentId, parsed.data.ingredients)) {
      await client.query("ROLLBACK");
      res.status(404).json({ error: { code: "INGREDIENT_NOT_FOUND", message: "Uno o más insumos no existen, están inactivos o pertenecen a otro establecimiento." } });
      return;
    }
    const recipeId = randomUUID();
    await client.query(
      "UPDATE productos SET tipo_inventario = 'receta', updated_at = now() WHERE id = $1 AND establecimiento_id = $2",
      [parsed.data.productId, req.auth!.establishmentId],
    );
    await client.query(
      "INSERT INTO recetas (id, establecimiento_id, producto_id, nombre) VALUES ($1, $2, $3, $4)",
      [recipeId, req.auth!.establishmentId, parsed.data.productId, parsed.data.name],
    );
    await insertRecipeIngredients(client, recipeId, parsed.data.ingredients);
    await client.query("COMMIT");
    res.status(201).json({ recipe: { id: recipeId, productId: parsed.data.productId, name: parsed.data.name, active: true, ingredients: parsed.data.ingredients } });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => undefined);
    if (isDuplicate(error)) {
      res.status(409).json({ error: { code: "RECIPE_ALREADY_EXISTS", message: "Este producto ya tiene una receta registrada." } });
      return;
    }
    next(error);
  } finally {
    client.release();
  }
});

catalogAdminRouter.patch("/recipes/:id", async (req, res, next) => {
  const id = z.string().uuid().safeParse(req.params.id);
  const parsed = RecipeUpdate.safeParse(req.body);
  if (!id.success || !parsed.success) return validationError(res, "Identificador o cambios de receta inválidos.");
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const existing = await client.query(
      "SELECT id, producto_id AS product_id FROM recetas WHERE id = $1 AND establecimiento_id = $2 FOR UPDATE",
      [id.data, req.auth!.establishmentId],
    );
    if (!existing.rowCount) {
      await client.query("ROLLBACK");
      res.status(404).json({ error: { code: "RECIPE_NOT_FOUND", message: "No se encontró la receta." } });
      return;
    }
    if (parsed.data.ingredients && !await validateRecipeIngredients(client, req.auth!.establishmentId, parsed.data.ingredients)) {
      await client.query("ROLLBACK");
      res.status(404).json({ error: { code: "INGREDIENT_NOT_FOUND", message: "Uno o más insumos no existen, están inactivos o pertenecen a otro establecimiento." } });
      return;
    }
    const updates: string[] = [];
    const values: unknown[] = [id.data, req.auth!.establishmentId];
    if (parsed.data.name !== undefined) {
      values.push(parsed.data.name);
      updates.push(`nombre = $${values.length}`);
    }
    if (parsed.data.active !== undefined) {
      values.push(parsed.data.active);
      updates.push(`activo = $${values.length}`);
    }
    if (updates.length) {
      updates.push("updated_at = now()");
      await client.query(
        `UPDATE recetas SET ${updates.join(", ")} WHERE id = $1 AND establecimiento_id = $2`,
        values,
      );
    }
    if (parsed.data.ingredients) {
      await client.query("DELETE FROM receta_detalle WHERE receta_id = $1 AND establecimiento_id = $2", [id.data, req.auth!.establishmentId]);
      await insertRecipeIngredients(client, id.data, parsed.data.ingredients);
    }
    const recipe = await client.query(
      "SELECT id, producto_id AS \\"productId\\", nombre AS name, activo AS active FROM recetas WHERE id = $1 AND establecimiento_id = $2",
      [id.data, req.auth!.establishmentId],
    );
    const ingredients = await client.query(
      `SELECT rd.id, rd.insumo_id AS "insumoId", i.codigo AS "insumoCode",
              i.nombre AS "insumoName", rd.cantidad AS quantity, rd.unidad AS unit, rd.orden AS "order"
         FROM receta_detalle rd
         JOIN insumos i ON i.id = rd.insumo_id AND i.establecimiento_id = rd.establecimiento_id
        WHERE rd.receta_id = $1 AND rd.establecimiento_id = $2
        ORDER BY rd.orden`,
      [id.data, req.auth!.establishmentId],
    );
    await client.query("COMMIT");
    res.status(200).json({ recipe: { ...recipe.rows[0], ingredients: ingredients.rows } });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => undefined);
    next(error);
  } finally {
    client.release();
  }
});
