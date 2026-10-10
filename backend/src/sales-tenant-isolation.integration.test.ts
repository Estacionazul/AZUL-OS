import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

test("sales history and detail never disclose another establishment's sale", { skip: process.env.CI !== "true" }, async () => {
  const { pool } = await import("./db.js");
  const suffix = randomUUID();
  const ids: Record<string, string | undefined> = {
    establishmentA: undefined,
    establishmentB: undefined,
    userA: undefined,
    userB: undefined,
    deviceA: undefined,
    deviceB: undefined,
    categoryB: undefined,
    productB: undefined,
    cashA: undefined,
    cashB: undefined,
    saleB: undefined,
  };
  let server: ReturnType<typeof app.listen> | undefined;

  try {
    const establishmentA = await pool.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [`CI sales tenant A ${suffix}`],
    );
    ids.establishmentA = establishmentA.rows[0].id as string;
    const establishmentB = await pool.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [`CI sales tenant B ${suffix}`],
    );
    ids.establishmentB = establishmentB.rows[0].id as string;

    for (const tenant of ["A", "B"] as const) {
      const establishmentId = ids[tenant === "A" ? "establishmentA" : "establishmentB"]!;
      const user = await pool.query(
        "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
        [establishmentId, `ci-sales-${tenant.toLowerCase()}-${suffix}`, `CI Sales ${tenant}`, await bcrypt.hash("1234", 4)],
      );
      ids[tenant === "A" ? "userA" : "userB"] = user.rows[0].id as string;
      const device = await pool.query(
        "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
        [establishmentId, `CI sales device ${tenant} ${suffix}`],
      );
      ids[tenant === "A" ? "deviceA" : "deviceB"] = device.rows[0].id as string;
    }

    const category = await pool.query(
      "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
      [ids.establishmentB, `CI sales category ${suffix}`],
    );
    ids.categoryB = category.rows[0].id as string;
    const product = await pool.query(
      "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, precio_venta, tipo_inventario, tipo_afectacion_igv) VALUES ($1, $2, $3, $4, 11.80, 'producto', '10') RETURNING id",
      [ids.establishmentB, `CI-SALES-B-${suffix}`, `CI Sales Product B ${suffix}`, ids.categoryB],
    );
    ids.productB = product.rows[0].id as string;

    for (const tenant of ["A", "B"] as const) {
      const cash = await pool.query(
        "INSERT INTO cajas (establecimiento_id, monto_inicial, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, 100, $2, $3) RETURNING id",
        [
          ids[tenant === "A" ? "establishmentA" : "establishmentB"],
          ids[tenant === "A" ? "userA" : "userB"],
          ids[tenant === "A" ? "deviceA" : "deviceB"],
        ],
      );
      ids[tenant === "A" ? "cashA" : "cashB"] = cash.rows[0].id as string;
    }

    await pool.query(
      "INSERT INTO movimientos_inventario (establecimiento_id, tipo, nombre_item, unidad, producto_id, cantidad, signo, usuario_id, dispositivo_id, idempotency_key) VALUES ($1, 'ENTRADA', $2, 'unid', $3, 5, 1, $4, $5, $6)",
      [ids.establishmentB, `CI Sales Product B ${suffix}`, ids.productB, ids.userB, ids.deviceB, randomUUID()],
    );

    server = app.listen(0, "127.0.0.1");
    await once(server, "listening");
    const address = server.address();
    assert.ok(address && typeof address !== "string");
    const baseUrl = `http://127.0.0.1:${address.port}`;

    const login = async (tenant: "A" | "B") => {
      const response = await fetch(`${baseUrl}/api/v1/auth/login`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          establishmentId: ids[tenant === "A" ? "establishmentA" : "establishmentB"],
          username: `ci-sales-${tenant.toLowerCase()}-${suffix}`,
          pin: "1234",
          deviceId: ids[tenant === "A" ? "deviceA" : "deviceB"],
        }),
      });
      assert.equal(response.status, 200);
      return (await response.json() as { token: string }).token;
    };
    const tokenA = await login("A");
    const tokenB = await login("B");

    const createSale = await fetch(`${baseUrl}/api/v1/sales`, {
      method: "POST",
      headers: {
        authorization: `Bearer ${tokenB}`,
        "content-type": "application/json",
        "idempotency-key": randomUUID(),
      },
      body: JSON.stringify({ items: [{ productId: ids.productB, quantity: 1 }], paymentMethod: "Efectivo" }),
    });
    assert.equal(createSale.status, 201, await createSale.text().catch(() => ""));
    const created = await createSale.json() as { sale: { id: string } };
    ids.saleB = created.sale.id;

    const foreignDetail = await fetch(`${baseUrl}/api/v1/sales/${ids.saleB}`, {
      headers: { authorization: `Bearer ${tokenA}` },
    });
    assert.equal(foreignDetail.status, 404);
    assert.equal((await foreignDetail.json() as { error: { code: string } }).error.code, "SALE_NOT_FOUND");

    const history = await fetch(`${baseUrl}/api/v1/sales`, {
      headers: { authorization: `Bearer ${tokenA}` },
    });
    assert.equal(history.status, 200);
    const historyBody = await history.json() as { items: Array<{ id: string }>; total: number };
    assert.ok(!historyBody.items.some(sale => sale.id === ids.saleB), "sales history must not include another establishment's sale");
    assert.equal(historyBody.total, 0, "sales history total must be scoped to the authenticated establishment");
  } finally {
    if (server) {
      const closed = once(server, "close");
      server.close();
      await closed;
    }
    if (ids.saleB) await pool.query("DELETE FROM detalle_ventas WHERE venta_id = $1", [ids.saleB]);
    if (ids.saleB) await pool.query("DELETE FROM movimientos_caja WHERE referencia = $1", [ids.saleB]);
    if (ids.saleB) await pool.query("DELETE FROM movimientos_inventario WHERE referencia_id = $1", [ids.saleB]);
    if (ids.saleB) await pool.query("DELETE FROM comprobantes_electronicos WHERE venta_id = $1", [ids.saleB]);
    if (ids.saleB) await pool.query("DELETE FROM ventas WHERE id = $1", [ids.saleB]);
    for (const cashId of [ids.cashA, ids.cashB]) {
      if (cashId) await pool.query("DELETE FROM movimientos_caja WHERE caja_id = $1", [cashId]);
      if (cashId) await pool.query("DELETE FROM cajas WHERE id = $1", [cashId]);
    }
    if (ids.productB) await pool.query("DELETE FROM movimientos_inventario WHERE producto_id = $1", [ids.productB]);
    if (ids.productB) await pool.query("DELETE FROM productos WHERE id = $1", [ids.productB]);
    if (ids.categoryB) await pool.query("DELETE FROM categorias WHERE id = $1", [ids.categoryB]);
    for (const userId of [ids.userA, ids.userB]) {
      if (userId) await pool.query("DELETE FROM sesiones WHERE usuario_id = $1", [userId]);
    }
    for (const deviceId of [ids.deviceA, ids.deviceB]) {
      if (deviceId) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceId]);
    }
    for (const userId of [ids.userA, ids.userB]) {
      if (userId) await pool.query("DELETE FROM usuarios WHERE id = $1", [userId]);
    }
    for (const establishmentId of [ids.establishmentA, ids.establishmentB]) {
      if (establishmentId) await pool.query("DELETE FROM correlativos WHERE establecimiento_id = $1", [establishmentId]);
    }
    for (const establishmentId of [ids.establishmentA, ids.establishmentB]) {
      if (establishmentId) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentId]);
    }
    await pool.end();
  }
});
