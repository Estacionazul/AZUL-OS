import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

test("concurrent retries of an idempotent sale do not duplicate sale, cash, or stock movements", { skip: process.env.CI !== "true" }, async (t) => {
  const { pool } = await import("./db.js");
  const suffix = randomUUID();
  let establishmentId: string | undefined;
  let userId: string | undefined;
  let deviceId: string | undefined;
  let categoryId: string | undefined;
  let productId: string | undefined;
  let cashRegisterId: string | undefined;
  let saleId: string | undefined;
  let mixedSaleId: string | undefined;
  let server: ReturnType<typeof app.listen> | undefined;

  try {
    const establishment = await pool.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [`CI sale idempotency ${suffix}`],
    );
    establishmentId = establishment.rows[0].id as string;

    const user = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentId, `ci-sale-${suffix}`, "CI Sale Idempotency", await bcrypt.hash("1234", 4)],
    );
    userId = user.rows[0].id as string;

    const device = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentId, `CI sale device ${suffix}`],
    );
    deviceId = device.rows[0].id as string;

    const category = await pool.query(
      "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
      [establishmentId, `CI Sale category ${suffix}`],
    );
    categoryId = category.rows[0].id as string;

    const product = await pool.query(
      "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, precio_venta, tipo_inventario, tipo_afectacion_igv) VALUES ($1, $2, $3, $4, 11.80, 'producto', '10') RETURNING id",
      [establishmentId, `CI-SALE-${suffix}`, "CI Product", categoryId],
    );
    productId = product.rows[0].id as string;

    const cash = await pool.query(
      "INSERT INTO cajas (establecimiento_id, monto_inicial, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, 100, $2, $3) RETURNING id",
      [establishmentId, userId, deviceId],
    );
    cashRegisterId = cash.rows[0].id as string;

    await pool.query(
      "INSERT INTO movimientos_inventario (establecimiento_id, tipo, nombre_item, unidad, producto_id, cantidad, signo, usuario_id, dispositivo_id, idempotency_key) VALUES ($1, 'INGRESO', 'CI Product', 'unid', $2, 10, 1, $3, $4, $5)",
      [establishmentId, productId, userId, deviceId, randomUUID()],
    );

    server = app.listen(0, "127.0.0.1");
    await once(server, "listening");
    const address = server.address();
    assert.ok(address && typeof address !== "string");
    const baseUrl = `http://127.0.0.1:${address.port}`;

    const username = `ci-sale-${suffix}`;
    const login = await fetch(`${baseUrl}/api/v1/auth/login`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ establishmentId, username, pin: "1234", deviceId }),
    });
    assert.equal(login.status, 200);
    const { token } = await login.json() as { token: string };
    const mixedPayment = await fetch(`${baseUrl}/api/v1/sales`, {
      method: "POST",
      headers: {
        authorization: `Bearer ${token}`,
        "content-type": "application/json",
        "idempotency-key": randomUUID(),
      },
      body: JSON.stringify({
        items: [{ productId, quantity: 1 }],
        paymentMethod: "Mixto",
        payments: [
          { method: "Efectivo", amount: 1.15 },
          { method: "Yape", amount: 10.65 },
        ],
      }),
    });
    assert.equal(mixedPayment.status, 201);
    const mixedBody = await mixedPayment.json() as { sale: { id: string; total: number; paymentMethod: string } };
    mixedSaleId = mixedBody.sale.id;
    assert.equal(mixedBody.sale.total, 11.8);
    assert.equal(mixedBody.sale.paymentMethod, "Mixto");
    const mixedTenders = await pool.query(
      "SELECT metodo_pago, monto FROM pagos_venta WHERE venta_id = $1 AND establecimiento_id = $2 ORDER BY metodo_pago",
      [mixedSaleId, establishmentId],
    );
    assert.deepEqual(mixedTenders.rows.map((row) => [row.metodo_pago, Number(row.monto)]), [
      ["Efectivo", 1.15],
      ["Yape", 10.65],
    ]);
    const mixedCashMovements = await pool.query(
      "SELECT metodo_pago, monto FROM movimientos_caja WHERE referencia = $1 ORDER BY metodo_pago",
      [mixedSaleId],
    );
    assert.equal(mixedCashMovements.rowCount, 2);

    const idempotencyKey = randomUUID();
    const body = JSON.stringify({
      items: [{ productId, quantity: 1 }],
      paymentMethod: "Efectivo",
    });
    const headers = {
      authorization: `Bearer ${token}`,
      "content-type": "application/json",
      "idempotency-key": idempotencyKey,
    };

    const responses = await Promise.all([
      fetch(`${baseUrl}/api/v1/sales`, { method: "POST", headers, body }),
      fetch(`${baseUrl}/api/v1/sales`, { method: "POST", headers, body }),
    ]);
    const results = await Promise.all(responses.map(async (response) => ({
      status: response.status,
      body: await response.json() as { sale?: { id: string; number: string; total: number }; replayed?: boolean; error?: unknown },
    })));
    const created = results.find((result) => result.status === 201);
    const replay = results.find((result) => result.status === 200);
    assert.ok(created, JSON.stringify(results));
    assert.ok(replay, JSON.stringify(results));
    assert.ok(created.body.sale);
    assert.ok(replay.body.sale);
    saleId = created.body.sale.id;
    assert.equal(created.body.replayed, false);
    assert.equal(replay.body.replayed, true);
    assert.equal(replay.body.sale.id, created.body.sale.id);
    assert.equal(replay.body.sale.total, created.body.sale.total);

    const detailResponse = await fetch(`${baseUrl}/api/v1/sales/${saleId}`, {
      headers: { authorization: `Bearer ${token}` },
    });
    assert.equal(detailResponse.status, 200);
    const detailBody = await detailResponse.json() as { sale: { number: string } };
    assert.equal(detailBody.sale.number, created.body.sale.number);

    const sales = await pool.query("SELECT count(*)::int AS count FROM ventas WHERE idempotency_key = $1", [idempotencyKey]);
    const cashMovements = await pool.query("SELECT count(*)::int AS count FROM movimientos_caja WHERE referencia = $1", [created.body.sale.id]);
    const stockMovements = await pool.query("SELECT count(*)::int AS count FROM movimientos_inventario WHERE referencia_id = $1 AND tipo = 'VENTA'", [created.body.sale.id]);
    const changedRequest = await fetch(`${baseUrl}/api/v1/sales`, {
      method: "POST",
      headers,
      body: JSON.stringify({ items: [{ productId, quantity: 2 }], paymentMethod: "Efectivo" }),
    });
    const changedBody = await changedRequest.json() as { error?: { code?: string } };
    assert.equal(changedRequest.status, 409, JSON.stringify(changedBody));
    assert.equal(changedBody.error?.code, "IDEMPOTENCY_CONFLICT");

    // Simulate a historical sale created before request fingerprints were stored.
    await pool.query("UPDATE ventas SET idempotency_hash = NULL WHERE id = $1", [saleId]);
    const legacyKeyReuse = await fetch(`${baseUrl}/api/v1/sales`, {
      method: "POST",
      headers,
      body: JSON.stringify({ items: [{ productId, quantity: 3 }], paymentMethod: "Efectivo" }),
    });
    const legacyKeyBody = await legacyKeyReuse.json() as { error?: { code?: string } };
    assert.equal(legacyKeyReuse.status, 409, JSON.stringify(legacyKeyBody));
    assert.equal(legacyKeyBody.error?.code, "IDEMPOTENCY_CONFLICT");

    assert.equal(sales.rows[0].count, 1, "exactly one sale should exist");
    assert.equal(cashMovements.rows[0].count, 1, "exactly one cash movement should exist");
    assert.equal(stockMovements.rows[0].count, 1, "exactly one stock movement should exist");

    const close = await fetch(`${baseUrl}/api/v1/cash/close`, {
      method: "POST",
      headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
      body: JSON.stringify({ closingAmount: 112.95 }),
    });
    assert.equal(close.status, 200);
    const closeBody = await close.json() as { reconciliation: { expectedCash: number; difference: number; mixedPaymentsToReview: number } };
    assert.equal(closeBody.reconciliation.expectedCash, 112.95);
    assert.equal(closeBody.reconciliation.difference, 0);
    assert.equal(closeBody.reconciliation.mixedPaymentsToReview, 0);
  } finally {
    if (server) {
      const closed = once(server, "close");
      server.close();
      await closed;
    }
    if (mixedSaleId) await pool.query("DELETE FROM detalle_ventas WHERE venta_id = $1", [mixedSaleId]);
    if (mixedSaleId) await pool.query("DELETE FROM pagos_venta WHERE venta_id = $1", [mixedSaleId]);
    if (mixedSaleId) await pool.query("DELETE FROM movimientos_caja WHERE referencia = $1", [mixedSaleId]);
    if (mixedSaleId) await pool.query("DELETE FROM movimientos_inventario WHERE referencia_id = $1", [mixedSaleId]);
    if (mixedSaleId) await pool.query("DELETE FROM ventas WHERE id = $1", [mixedSaleId]);
    if (saleId) await pool.query("DELETE FROM detalle_ventas WHERE venta_id = $1", [saleId]);
    if (saleId) await pool.query("DELETE FROM pagos_venta WHERE venta_id = $1", [saleId]);
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
    if (establishmentId) await pool.query("DELETE FROM correlativos WHERE establecimiento_id = $1", [establishmentId]);
    if (establishmentId) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentId]);
    await pool.end();
  }
});
