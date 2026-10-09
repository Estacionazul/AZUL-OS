import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

test("concurrent sales with different idempotency keys cannot oversell the same product", { skip: process.env.CI !== "true" }, async () => {
  const { pool } = await import("./db.js");
  const suffix = randomUUID();
  let establishmentId: string | undefined;
  let userId: string | undefined;
  let deviceId: string | undefined;
  let categoryId: string | undefined;
  let productId: string | undefined;
  let cashRegisterId: string | undefined;
  let saleId: string | undefined;
  let server: ReturnType<typeof app.listen> | undefined;

  try {
    const establishment = await pool.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [`CI stock concurrency ${suffix}`],
    );
    establishmentId = establishment.rows[0].id as string;

    const user = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentId, `ci-stock-${suffix}`, "CI Stock Concurrency", await bcrypt.hash("1234", 4)],
    );
    userId = user.rows[0].id as string;

    const device = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentId, `CI stock device ${suffix}`],
    );
    deviceId = device.rows[0].id as string;

    const category = await pool.query(
      "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
      [establishmentId, `CI Stock category ${suffix}`],
    );
    categoryId = category.rows[0].id as string;

    const product = await pool.query(
      "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, precio_venta, tipo_inventario, tipo_afectacion_igv) VALUES ($1, $2, $3, $4, 11.80, 'producto', '10') RETURNING id",
      [establishmentId, `CI-STOCK-${suffix}`, "CI Single-Stock Product", categoryId],
    );
    productId = product.rows[0].id as string;

    const cash = await pool.query(
      "INSERT INTO cajas (establecimiento_id, monto_inicial, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, 100, $2, $3) RETURNING id",
      [establishmentId, userId, deviceId],
    );
    cashRegisterId = cash.rows[0].id as string;

    await pool.query(
      "INSERT INTO movimientos_inventario (establecimiento_id, tipo, nombre_item, unidad, producto_id, cantidad, signo, usuario_id, dispositivo_id, idempotency_key) VALUES ($1, 'INGRESO', 'CI Single-Stock Product', 'unid', $2, 1, 1, $3, $4, $5)",
      [establishmentId, productId, userId, deviceId, randomUUID()],
    );

    server = app.listen(0, "127.0.0.1");
    await once(server, "listening");
    const address = server.address();
    assert.ok(address && typeof address !== "string");
    const baseUrl = `http://127.0.0.1:${address.port}`;

    const username = `ci-stock-${suffix}`;
    const login = await fetch(`${baseUrl}/api/v1/auth/login`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ establishmentId, username, pin: "1234", deviceId }),
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
    const responses = await Promise.all([requestSale(randomUUID()), requestSale(randomUUID())]);
    const results = await Promise.all(responses.map(async response => ({
      status: response.status,
      body: await response.json() as { sale?: { id: string }; error?: { code?: string } },
    })));

    assert.equal(results.filter(result => result.status === 201).length, 1, JSON.stringify(results));
    assert.equal(results.filter(result => result.status === 409 && result.body.error?.code === "INSUFFICIENT_STOCK").length, 1, JSON.stringify(results));

    // Count all sales linked to the fixture product through their sale details.
    const fixtureSales = await pool.query(
      "SELECT count(DISTINCT v.id)::int AS count FROM ventas v JOIN detalle_ventas d ON d.venta_id = v.id WHERE v.establecimiento_id = $1 AND d.producto_id = $2",
      [establishmentId, productId],
    );
    const stock = await pool.query(
      "SELECT COALESCE(SUM(cantidad * signo), 0)::numeric(14,4) AS current FROM movimientos_inventario WHERE establecimiento_id = $1 AND producto_id = $2",
      [establishmentId, productId],
    );
    assert.equal(fixtureSales.rows[0].count, 1);
    assert.equal(Number(stock.rows[0].current), 0);

    const sale = results.find(result => result.status === 201)?.body.sale;
    assert.ok(sale);
    saleId = sale.id;
    const cashMovements = await pool.query(
      "SELECT count(*)::int AS count FROM movimientos_caja WHERE caja_id = $1 AND referencia = $2",
      [cashRegisterId, sale.id],
    );
    const stockMovements = await pool.query(
      "SELECT count(*)::int AS count FROM movimientos_inventario WHERE referencia_id = $1 AND tipo = 'VENTA'",
      [sale.id],
    );
    assert.equal(cashMovements.rows[0].count, 1);
    assert.equal(stockMovements.rows[0].count, 1);
  } finally {
    if (server) {
      const closed = once(server, "close");
      server.close();
      await closed;
    }
    if (saleId) await pool.query("DELETE FROM detalle_ventas WHERE venta_id = $1", [saleId]);
    if (saleId) await pool.query("DELETE FROM movimientos_caja WHERE referencia = $1", [saleId]);
    if (saleId) await pool.query("DELETE FROM movimientos_inventario WHERE referencia_id = $1", [saleId]);
    if (saleId) await pool.query("DELETE FROM ventas WHERE id = $1", [saleId]);
    if (cashRegisterId) await pool.query("DELETE FROM movimientos_caja WHERE caja_id = $1", [cashRegisterId]);
    if (cashRegisterId) await pool.query("DELETE FROM cajas WHERE id = $1", [cashRegisterId]);
    if (productId) await pool.query("DELETE FROM movimientos_inventario WHERE producto_id = $1", [productId]);
    if (productId) await pool.query("DELETE FROM productos WHERE id = $1", [productId]);
    if (categoryId) await pool.query("DELETE FROM categorias WHERE id = $1", [categoryId]);
    if (userId) await pool.query("DELETE FROM sesiones WHERE usuario_id = $1", [userId]);
    if (deviceId) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceId]);
    if (userId) await pool.query("DELETE FROM usuarios WHERE id = $1", [userId]);
    if (establishmentId) {
      await pool.query("DELETE FROM correlativos WHERE establecimiento_id = $1", [establishmentId]);
      await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentId]);
    }
    await pool.end();
  }
});
