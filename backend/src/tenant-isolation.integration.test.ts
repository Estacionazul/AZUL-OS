import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

test("catalog and sale endpoints isolate products between establishments", { skip: process.env.CI !== "true" }, async () => {
  const { pool } = await import("./db.js");
  const suffix = randomUUID();
  let establishmentA: string | undefined;
  let establishmentB: string | undefined;
  let userA: string | undefined;
  let deviceA: string | undefined;
  let categoryA: string | undefined;
  let categoryB: string | undefined;
  let productA: string | undefined;
  let productB: string | undefined;
  let cashRegisterA: string | undefined;
  let server: ReturnType<typeof app.listen> | undefined;

  try {
    const a = await pool.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [`CI tenant A ${suffix}`],
    );
    establishmentA = a.rows[0].id as string;
    const b = await pool.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [`CI tenant B ${suffix}`],
    );
    establishmentB = b.rows[0].id as string;

    const user = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentA, `ci-tenant-${suffix}`, "CI Tenant A", await bcrypt.hash("1234", 4)],
    );
    userA = user.rows[0].id as string;
    const device = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentA, `CI tenant device ${suffix}`],
    );
    deviceA = device.rows[0].id as string;

    const catA = await pool.query(
      "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
      [establishmentA, `CI category A ${suffix}`],
    );
    categoryA = catA.rows[0].id as string;
    const catB = await pool.query(
      "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
      [establishmentB, `CI category B ${suffix}`],
    );
    categoryB = catB.rows[0].id as string;

    const ownProduct = await pool.query(
      "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, precio_venta, tipo_inventario, tipo_afectacion_igv) VALUES ($1, $2, $3, $4, 11.80, 'producto', '10') RETURNING id",
      [establishmentA, `CI-TENANT-A-${suffix}`, `CI Product A ${suffix}`, categoryA],
    );
    productA = ownProduct.rows[0].id as string;
    const foreignProduct = await pool.query(
      "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, precio_venta, tipo_inventario, tipo_afectacion_igv) VALUES ($1, $2, $3, $4, 15.00, 'producto', '10') RETURNING id",
      [establishmentB, `CI-TENANT-B-${suffix}`, `CI Product B ${suffix}`, categoryB],
    );
    productB = foreignProduct.rows[0].id as string;

    const cash = await pool.query(
      "INSERT INTO cajas (establecimiento_id, monto_inicial, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, 100, $2, $3) RETURNING id",
      [establishmentA, userA, deviceA],
    );
    cashRegisterA = cash.rows[0].id as string;

    server = app.listen(0, "127.0.0.1");
    await once(server, "listening");
    const address = server.address();
    assert.ok(address && typeof address !== "string");
    const baseUrl = `http://127.0.0.1:${address.port}`;

    const login = await fetch(`${baseUrl}/api/v1/auth/login`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        establishmentId: establishmentA,
        username: `ci-tenant-${suffix}`,
        pin: "1234",
        deviceId: deviceA,
      }),
    });
    assert.equal(login.status, 200);
    const { token } = await login.json() as { token: string };
    const headers = { authorization: `Bearer ${token}` };

    const catalogResponse = await fetch(`${baseUrl}/api/v1/catalog/products`, { headers });
    assert.equal(catalogResponse.status, 200);
    const catalog = await catalogResponse.json() as {
      items: Array<{ id: string; nombre?: string; name?: string; codigo?: string; code?: string }>;
      pagination: { total: number };
    };
    const catalogIds = catalog.items.map(item => item.id);
    assert.ok(catalogIds.includes(productA!), "the authenticated establishment should see its own product");
    assert.ok(!catalogIds.includes(productB!), "the authenticated establishment must not see another establishment's product");
    assert.equal(catalog.pagination.total, 1, "catalog total must not count another establishment's product");

    const categoryResponse = await fetch(`${baseUrl}/api/v1/catalog/categories`, { headers });
    assert.equal(categoryResponse.status, 200);
    const categories = await categoryResponse.json() as { items: Array<{ id: string }> };
    const categoryIds = categories.items.map(item => item.id);
    assert.ok(categoryIds.includes(categoryA!));
    assert.ok(!categoryIds.includes(categoryB!), "categories from another establishment must be hidden");

    const idempotencyKey = randomUUID();
    const crossTenantSale = await fetch(`${baseUrl}/api/v1/sales`, {
      method: "POST",
      headers: {
        ...headers,
        "content-type": "application/json",
        "idempotency-key": idempotencyKey,
      },
      body: JSON.stringify({
        items: [{ productId: productB, quantity: 1 }],
        paymentMethod: "Efectivo",
      }),
    });
    assert.equal(crossTenantSale.status, 409);
    const error = await crossTenantSale.json() as { error?: { code?: string } };
    assert.equal(error.error?.code, "PRODUCT_UNAVAILABLE");

    const saleCount = await pool.query(
      "SELECT count(*)::int AS count FROM ventas WHERE idempotency_key = $1",
      [idempotencyKey],
    );
    assert.equal(saleCount.rows[0].count, 0, "a cross-establishment product must not create a sale");
  } finally {
    if (server) {
      const closed = once(server, "close");
      server.close();
      await closed;
    }
    if (cashRegisterA) await pool.query("DELETE FROM movimientos_caja WHERE caja_id = $1", [cashRegisterA]);
    if (cashRegisterA) await pool.query("DELETE FROM cajas WHERE id = $1", [cashRegisterA]);
    if (productA) await pool.query("DELETE FROM movimientos_inventario WHERE producto_id = $1", [productA]);
    if (productB) await pool.query("DELETE FROM movimientos_inventario WHERE producto_id = $1", [productB]);
    if (productA) await pool.query("DELETE FROM productos WHERE id = $1", [productA]);
    if (productB) await pool.query("DELETE FROM productos WHERE id = $1", [productB]);
    if (categoryA) await pool.query("DELETE FROM categorias WHERE id = $1", [categoryA]);
    if (categoryB) await pool.query("DELETE FROM categorias WHERE id = $1", [categoryB]);
    if (userA) await pool.query("DELETE FROM sesiones WHERE usuario_id = $1", [userA]);
    if (deviceA) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceA]);
    if (userA) await pool.query("DELETE FROM usuarios WHERE id = $1", [userA]);
    if (establishmentA) await pool.query("DELETE FROM correlativos WHERE establecimiento_id = $1", [establishmentA]);
    if (establishmentB) await pool.query("DELETE FROM correlativos WHERE establecimiento_id = $1", [establishmentB]);
    if (establishmentA) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentA]);
    if (establishmentB) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentB]);
    await pool.end();
  }
});
