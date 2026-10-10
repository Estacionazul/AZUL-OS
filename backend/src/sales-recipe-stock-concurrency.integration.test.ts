import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

test("concurrent recipe sales sharing one ingredient cannot oversell ingredient stock", { skip: process.env.CI !== "true" }, async () => {
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
      [`CI shared recipe stock ${suffix}`],
    );
    establishmentId = establishment.rows[0].id as string;

    const user = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentId, `ci-recipe-stock-${suffix}`, "CI Shared Recipe Stock", await bcrypt.hash("1234", 4)],
    );
    userId = user.rows[0].id as string;

    const device = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentId, `CI shared recipe device ${suffix}`],
    );
    deviceId = device.rows[0].id as string;

    const category = await pool.query(
      "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
      [establishmentId, `CI shared recipe category ${suffix}`],
    );
    categoryId = category.rows[0].id as string;

    const product = await pool.query(
      "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, precio_venta, tipo_inventario, tipo_afectacion_igv) VALUES ($1, $2, $3, $4, 11.80, 'receta', '10') RETURNING id",
      [establishmentId, `CI-RECIPE-STOCK-${suffix}`, "CI Shared Ingredient Recipe", categoryId],
    );
    productId = product.rows[0].id as string;

    const ingredient = await pool.query(
      "INSERT INTO insumos (establecimiento_id, codigo, nombre, categoria_id, unidad_medida) VALUES ($1, $2, $3, $4, 'unid') RETURNING id",
      [establishmentId, `CI-SHARED-ING-${suffix}`, "CI Shared Ingredient", categoryId],
    );
    ingredientId = ingredient.rows[0].id as string;

    const recipe = await pool.query(
      "INSERT INTO recetas (establecimiento_id, producto_id, nombre, activo) VALUES ($1, $2, $3, true) RETURNING id",
      [establishmentId, productId, "CI Shared Ingredient Recipe"],
    );
    recipeId = recipe.rows[0].id as string;

    await pool.query(
      "INSERT INTO receta_detalle (receta_id, insumo_id, cantidad, unidad) VALUES ($1, $2, 1, 'unid')",
      [recipeId, ingredientId],
    );

    await pool.query(
      "INSERT INTO movimientos_inventario (establecimiento_id, tipo, nombre_item, unidad, insumo_id, cantidad, signo, usuario_id, dispositivo_id, idempotency_key) VALUES ($1, 'INGRESO', 'CI Shared Ingredient', 'unid', $2, 1, 1, $3, $4, $5)",
      [establishmentId, ingredientId, userId, deviceId, randomUUID()],
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
      body: JSON.stringify({ establishmentId, username: `ci-recipe-stock-${suffix}`, pin: "1234", deviceId }),
    });
    assert.equal(login.status, 200);
    const { token } = await login.json() as { token: string };

    const requestSale = (key: string) => fetch(`${baseUrl}/api/v1/sales`, {
      method: "POST",
      headers: {
        authorization: `Bearer ${token}`,
        "content-type": "application/json",
        "idempotency-key": key,
      },
      body: JSON.stringify({ items: [{ productId, quantity: 1 }], paymentMethod: "Efectivo" }),
    });
    const keys = [randomUUID(), randomUUID()];
    const responses = await Promise.all(keys.map(requestSale));
    const results = await Promise.all(responses.map(async response => ({
      status: response.status,
      body: await response.json() as { sale?: { id: string }; error?: { code?: string } },
    })));

    assert.equal(results.filter(result => result.status === 201).length, 1, JSON.stringify(results));
    assert.equal(
      results.filter(result => result.status === 409 && result.body.error?.code === "INSUFFICIENT_STOCK").length,
      1,
      JSON.stringify(results),
    );

    const sales = await pool.query(
      "SELECT v.id FROM ventas v JOIN detalle_ventas d ON d.venta_id = v.id WHERE v.establecimiento_id = $1 AND d.producto_id = $2",
      [establishmentId, productId],
    );
    assert.equal(sales.rowCount, 1, "exactly one recipe sale must persist");
    const saleId = sales.rows[0].id as string;

    const stock = await pool.query(
      "SELECT COALESCE(SUM(cantidad * signo), 0)::numeric(14,4) AS current FROM movimientos_inventario WHERE establecimiento_id = $1 AND insumo_id = $2",
      [establishmentId, ingredientId],
    );
    assert.equal(Number(stock.rows[0].current), 0, "the single ingredient unit must be consumed exactly once");

    const cashMovements = await pool.query(
      "SELECT count(*)::int AS count FROM movimientos_caja WHERE caja_id = $1 AND referencia = $2",
      [cashRegisterId, saleId],
    );
    const ingredientSaleMovements = await pool.query(
      "SELECT count(*)::int AS count, COALESCE(SUM(cantidad), 0)::numeric(14,4) AS quantity FROM movimientos_inventario WHERE establecimiento_id = $1 AND insumo_id = $2 AND referencia_id = $3 AND tipo = 'VENTA'",
      [establishmentId, ingredientId, saleId],
    );
    assert.equal(cashMovements.rows[0].count, 1, "only the accepted sale may create a cash movement");
    assert.equal(ingredientSaleMovements.rows[0].count, 1, "only one ingredient consumption movement must be recorded");
    assert.equal(Number(ingredientSaleMovements.rows[0].quantity), 1);
    const rejectedKeyCount = await pool.query(
      "SELECT count(*)::int AS count FROM ventas WHERE idempotency_key = ANY($1::uuid[])",
      [keys],
    );
    assert.equal(rejectedKeyCount.rows[0].count, 1, "only the accepted request may persist");
  } finally {
    if (server) {
      const closed = once(server, "close");
      server.close();
      await closed;
    }
    if (productId && establishmentId) {
      const fixtureSales = await pool.query(
        "SELECT DISTINCT v.id FROM ventas v JOIN detalle_ventas d ON d.venta_id = v.id WHERE v.establecimiento_id = $1 AND d.producto_id = $2",
        [establishmentId, productId],
      );
      const saleIds = fixtureSales.rows.map(row => row.id as string);
      if (saleIds.length) {
        await pool.query("DELETE FROM detalle_ventas WHERE venta_id = ANY($1::uuid[])", [saleIds]);
        await pool.query("DELETE FROM pagos_venta WHERE venta_id = ANY($1::uuid[])", [saleIds]);
        await pool.query("DELETE FROM movimientos_caja WHERE referencia = ANY($1::text[])", [saleIds]);
        await pool.query("DELETE FROM movimientos_inventario WHERE referencia_id = ANY($1::uuid[])", [saleIds]);
        await pool.query("DELETE FROM ventas WHERE id = ANY($1::uuid[])", [saleIds]);
      }
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
