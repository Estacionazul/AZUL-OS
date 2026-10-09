import test from "node:test";
import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";

test("catalog codes, category names, and order numbers can be reused across establishments", { skip: process.env.CI !== "true" }, async () => {
  const { pool } = await import("./db.js");
  const suffix = randomUUID();
  const establishmentIds: string[] = [];
  const categoryIds: string[] = [];
  const productIds: string[] = [];
  const ingredientIds: string[] = [];
  const orderIds: string[] = [];

  try {
    for (const name of ["first", "second"]) {
      const result = await pool.query(
        "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
        [`CI tenant uniqueness ${name} ${suffix}`],
      );
      establishmentIds.push(result.rows[0].id as string);
    }

    for (const establishmentId of establishmentIds) {
      const category = await pool.query(
        "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
        [establishmentId, `Shared category ${suffix}`],
      );
      categoryIds.push(category.rows[0].id as string);
    }

    for (let i = 0; i < establishmentIds.length; i += 1) {
      const product = await pool.query(
        "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, precio_venta, tipo_inventario, tipo_afectacion_igv) VALUES ($1, $2, $3, $4, 5, 'producto', '10') RETURNING id",
        [establishmentIds[i], `SHARED-CODE-${suffix}`, `Product ${i}`, categoryIds[i]],
      );
      productIds.push(product.rows[0].id as string);

      const ingredient = await pool.query(
        "INSERT INTO insumos (establecimiento_id, codigo, nombre, categoria_id, unidad_medida) VALUES ($1, $2, $3, $4, 'unid') RETURNING id",
        [establishmentIds[i], `SHARED-INGREDIENT-${suffix}`, `Ingredient ${i}`, categoryIds[i]],
      );
      ingredientIds.push(ingredient.rows[0].id as string);

      const order = await pool.query(
        "INSERT INTO pedidos (establecimiento_id, numero, ubicacion_id, ubicacion_nombre) VALUES ($1, $2, 'test-location', 'CI location') RETURNING id",
        [establishmentIds[i], `P-SHARED-${suffix}`],
      );
      orderIds.push(order.rows[0].id as string);
    }

    assert.equal(new Set(categoryIds).size, 2);
    assert.equal(new Set(productIds).size, 2);
    assert.equal(new Set(ingredientIds).size, 2);
    assert.equal(new Set(orderIds).size, 2);

    // Keep duplicates forbidden inside one establishment.
    const uniqueViolation = (error: unknown) =>
      typeof error === "object" && error !== null && "code" in error &&
      (error as { code?: string }).code === "23505";

    await assert.rejects(
      pool.query("INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2)", [establishmentIds[0], `Shared category ${suffix}`]),
      uniqueViolation,
      "a category name must remain unique within one establishment",
    );
    await assert.rejects(
      pool.query("INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id) VALUES ($1, $2, 'Duplicate product', $3)", [establishmentIds[0], `SHARED-CODE-${suffix}`, categoryIds[0]]),
      uniqueViolation,
      "a product code must remain unique within one establishment",
    );
    await assert.rejects(
      pool.query("INSERT INTO insumos (establecimiento_id, codigo, nombre, categoria_id, unidad_medida) VALUES ($1, $2, 'Duplicate ingredient', $3, 'unid')", [establishmentIds[0], `SHARED-INGREDIENT-${suffix}`, categoryIds[0]]),
      uniqueViolation,
      "an ingredient code must remain unique within one establishment",
    );
    await assert.rejects(
      pool.query("INSERT INTO pedidos (establecimiento_id, numero, ubicacion_id, ubicacion_nombre) VALUES ($1, $2, 'duplicate-location', 'CI duplicate')", [establishmentIds[0], `P-SHARED-${suffix}`]),
      uniqueViolation,
      "an order number must remain unique within one establishment",
    );
  } finally {
    if (orderIds.length) await pool.query("DELETE FROM pedidos WHERE id = ANY($1::uuid[])", [orderIds]);
    if (productIds.length) await pool.query("DELETE FROM productos WHERE id = ANY($1::uuid[])", [productIds]);
    if (ingredientIds.length) await pool.query("DELETE FROM insumos WHERE id = ANY($1::uuid[])", [ingredientIds]);
    if (categoryIds.length) await pool.query("DELETE FROM categorias WHERE id = ANY($1::uuid[])", [categoryIds]);
    if (establishmentIds.length) await pool.query("DELETE FROM establecimientos WHERE id = ANY($1::uuid[])", [establishmentIds]);
    await pool.end();
  }
});
