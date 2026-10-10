import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

test("sale with insufficient recipe ingredient stock leaves no partial sale, cash, or inventory movements", { skip: process.env.CI !== "true" }, async () => {
  const { pool } = await import("./db.js");
  const suffix = randomUUID();
  let establishmentId: string | undefined;
  let userId: string | undefined;
  let deviceId: string | undefined;
  let categoryId: string | undefined;
  let productId: string | undefined;
  let ingredientId: string | undefined;
  let recipeId: string | undefined;
  let cashRegisterId: string | undefined;
  let server: ReturnType<typeof app.listen> | undefined;

  try {
    const establishment = await pool.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [`CI recipe rollback ${suffix}`],
    );
    establishmentId = establishment.rows[0].id as string;

    const user = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentId, `ci-recipe-${suffix}`, "CI Recipe Rollback", await bcrypt.hash("1234", 4)],
    );
    userId = user.rows[0].id as string;

    const device = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentId, `CI recipe device ${suffix}`],
    );
    deviceId = device.rows[0].id as string;

    const category = await pool.query(
      "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
      [establishmentId, `CI Recipe category ${suffix}`],
    );
    categoryId = category.rows[0].id as string;

    const product = await pool.query(
      "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, precio_venta, tipo_inventario, tipo_afectacion_igv) VALUES ($1, $2, $3, $4, 11.80, 'receta', '10') RETURNING id",
      [establishmentId, `CI-RECIPE-${suffix}`, "CI Recipe Product", categoryId],
    );
    productId = product.rows[0].id as string;

    const ingredient = await pool.query(
      "INSERT INTO insumos (establecimiento_id, codigo, nombre, categoria_id, unidad_medida) VALUES ($1, $2, $3, $4, 'unid') RETURNING id",
      [establishmentId, `CI-ING-${suffix}`, "CI Recipe Ingredient", categoryId],
    );
    ingredientId = ingredient.rows[0].id as string;

    const recipe = await pool.query(
      "INSERT INTO recetas (establecimiento_id, producto_id, nombre, activo) VALUES ($1, $2, $3, true) RETURNING id",
      [establishmentId, productId, "CI Recipe Product"],
    );
    recipeId = recipe.rows[0].id as string;

    await pool.query(
      "INSERT INTO receta_detalle (receta_id, insumo_id, cantidad, unidad) VALUES ($1, $2, 2, 'unid')",
      [recipeId, ingredientId],
    );

    const cash = await pool.query(
      "INSERT INTO cajas (establecimiento_id, monto_inicial, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, 100, $2, $3) RETURNING id",
      [establishmentId, userId, deviceId],
    );
    cashRegisterId = cash.rows[0].id as string;

    server = app.listen(0, "127.0.0.1");
    await once(server, "listening");
    const address = server.address();
    assert.ok(address && typeof address !== "string");
    const baseUrl = `http://127.0.0.1:${address.port}`;

    const login = await fetch(`${baseUrl}/api/v1/auth/login`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ establishmentId, username: `ci-recipe-${suffix}`, pin: "1234", deviceId }),
    });
    assert.equal(login.status, 200);
    const { token } = await login.json() as { token: string };

    const idempotencyKey = randomUUID();
    const response = await fetch(`${baseUrl}/api/v1/sales`, {
      method: "POST",
      headers: {
        authorization: `Bearer ${token}`,
        "content-type": "application/json",
        "idempotency-key": idempotencyKey,
      },
      body: JSON.stringify({ items: [{ productId, quantity: 1 }], paymentMethod: "Efectivo" }),
    });
    const body = await response.json() as { error?: { code?: string; itemId?: string; available?: number; required?: number } };
    assert.equal(response.status, 409, JSON.stringify(body));
    assert.equal(body.error?.code, "INSUFFICIENT_STOCK");
    assert.equal(body.error?.itemId, ingredientId);
    assert.equal(body.error?.available, 0);
    assert.equal(body.error?.required, 2);

    const sales = await pool.query(
      "SELECT count(*)::int AS count FROM ventas WHERE establecimiento_id = $1",
      [establishmentId],
    );
    const cashMovements = await pool.query(
      "SELECT count(*)::int AS count FROM movimientos_caja WHERE caja_id = $1",
      [cashRegisterId],
    );
    const inventoryMovements = await pool.query(
      "SELECT count(*)::int AS count FROM movimientos_inventario WHERE establecimiento_id = $1 AND (producto_id = $2 OR insumo_id = $3)",
      [establishmentId, productId, ingredientId],
    );
    const idempotencyRecords = await pool.query(
      "SELECT count(*)::int AS count FROM ventas WHERE idempotency_key = $1",
      [idempotencyKey],
    );

    assert.equal(sales.rows[0].count, 0, "a rejected recipe sale must not persist a sale");
    assert.equal(cashMovements.rows[0].count, 0, "a rejected recipe sale must not create a cash movement");
    assert.equal(inventoryMovements.rows[0].count, 0, "a rejected recipe sale must not create stock movements");
    assert.equal(idempotencyRecords.rows[0].count, 0, "a rejected request must not reserve its idempotency key");
  } finally {
    if (server) {
      const closed = once(server, "close");
      server.close();
      await closed;
    }
    if (cashRegisterId) await pool.query("DELETE FROM movimientos_caja WHERE caja_id = $1", [cashRegisterId]);
    if (cashRegisterId) await pool.query("DELETE FROM cajas WHERE id = $1", [cashRegisterId]);
    if (recipeId) await pool.query("DELETE FROM recetas WHERE id = $1", [recipeId]);
    if (ingredientId) await pool.query("DELETE FROM movimientos_inventario WHERE insumo_id = $1", [ingredientId]);
    if (productId) await pool.query("DELETE FROM movimientos_inventario WHERE producto_id = $1", [productId]);
    if (productId) await pool.query("DELETE FROM productos WHERE id = $1", [productId]);
    if (ingredientId) await pool.query("DELETE FROM insumos WHERE id = $1", [ingredientId]);
    if (categoryId) await pool.query("DELETE FROM categorias WHERE id = $1", [categoryId]);
    if (userId) await pool.query("DELETE FROM sesiones WHERE usuario_id = $1", [userId]);
    if (deviceId) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceId]);
    if (userId) await pool.query("DELETE FROM usuarios WHERE id = $1", [userId]);
    if (establishmentId) await pool.query("DELETE FROM correlativos WHERE establecimiento_id = $1", [establishmentId]);
    if (establishmentId) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentId]);
    await pool.end();
  }
});
