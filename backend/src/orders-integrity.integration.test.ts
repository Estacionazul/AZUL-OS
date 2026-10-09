import test from "node:test";
import assert from "node:assert/strict";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";

test("orders and order details reject cross-establishment users, devices and products", { skip: process.env.CI !== "true" }, async () => {
  const { pool } = await import("./db.js");
  const suffix = crypto.randomUUID();
  let establishmentA: string | undefined;
  let establishmentB: string | undefined;
  let userA: string | undefined;
  let userB: string | undefined;
  let deviceA: string | undefined;
  let deviceB: string | undefined;
  let categoryA: string | undefined;
  let categoryB: string | undefined;
  let productA: string | undefined;
  let productB: string | undefined;
  let orderA: string | undefined;

  try {
    const a = await pool.query("INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id", [`CI orders A ${suffix}`]);
    establishmentA = a.rows[0].id as string;
    const b = await pool.query("INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id", [`CI orders B ${suffix}`]);
    establishmentB = b.rows[0].id as string;

    const ua = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentA, `ci-order-a-${suffix}`, "CI Order A", "test-hash"],
    );
    userA = ua.rows[0].id as string;
    const ub = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentB, `ci-order-b-${suffix}`, "CI Order B", "test-hash"],
    );
    userB = ub.rows[0].id as string;

    const da = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentA, `CI Order device A ${suffix}`],
    );
    deviceA = da.rows[0].id as string;
    const db = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentB, `CI Order device B ${suffix}`],
    );
    deviceB = db.rows[0].id as string;

    const ca = await pool.query("INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id", [establishmentA, `CI Order category A ${suffix}`]);
    categoryA = ca.rows[0].id as string;
    const cb = await pool.query("INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id", [establishmentB, `CI Order category B ${suffix}`]);
    categoryB = cb.rows[0].id as string;
    const pa = await pool.query(
      "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, tipo_inventario) VALUES ($1, $2, $3, $4, 'producto') RETURNING id",
      [establishmentA, `CI-OA-${suffix}`, "CI Order Product A", categoryA],
    );
    productA = pa.rows[0].id as string;
    const pb = await pool.query(
      "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, tipo_inventario) VALUES ($1, $2, $3, $4, 'producto') RETURNING id",
      [establishmentB, `CI-OB-${suffix}`, "CI Order Product B", categoryB],
    );
    productB = pb.rows[0].id as string;

    await assert.rejects(
      pool.query(
        "INSERT INTO pedidos (establecimiento_id, numero, ubicacion_id, ubicacion_nombre, usuario_id, dispositivo_id) VALUES ($1, $2, 'mesa-1', 'Mesa 1', $3, $4)",
        [establishmentA, `CI-ORDER-USER-${suffix}`, userB, deviceA],
      ),
      (error: { code?: string }) => error.code === "23503",
      "an order must not reference a user from another establishment",
    );
    await assert.rejects(
      pool.query(
        "INSERT INTO pedidos (establecimiento_id, numero, ubicacion_id, ubicacion_nombre, usuario_id, dispositivo_id) VALUES ($1, $2, 'mesa-1', 'Mesa 1', $3, $4)",
        [establishmentA, `CI-ORDER-DEVICE-${suffix}`, userA, deviceB],
      ),
      (error: { code?: string }) => error.code === "23503",
      "an order must not reference a device from another establishment",
    );

    const order = await pool.query(
      "INSERT INTO pedidos (establecimiento_id, numero, ubicacion_id, ubicacion_nombre, usuario_id, dispositivo_id) VALUES ($1, $2, 'mesa-1', 'Mesa 1', $3, $4) RETURNING id",
      [establishmentA, `CI-ORDER-${suffix}`, userA, deviceA],
    );
    orderA = order.rows[0].id as string;

    await assert.rejects(
      pool.query(
        "INSERT INTO pedido_detalles (pedido_id, producto_id, codigo_producto, nombre_producto, establecimiento_id) VALUES ($1, $2, $3, $4, $5)",
        [orderA, productB, `CI-OB-${suffix}`, "Foreign product", establishmentA],
      ),
      (error: { code?: string }) => error.code === "23503",
      "an order line must not reference a product from another establishment",
    );

    await pool.query(
      "INSERT INTO pedido_detalles (pedido_id, producto_id, codigo_producto, nombre_producto, establecimiento_id) VALUES ($1, $2, $3, $4, $5)",
      [orderA, productA, `CI-OA-${suffix}`, "Local product", establishmentA],
    );
  } finally {
    if (establishmentA || establishmentB) {
      await pool.query(
        "DELETE FROM pedido_detalles WHERE establecimiento_id = ANY($1::uuid[])",
        [[establishmentA, establishmentB].filter((id): id is string => Boolean(id))],
      );
      await pool.query(
        "DELETE FROM pedidos WHERE establecimiento_id = ANY($1::uuid[])",
        [[establishmentA, establishmentB].filter((id): id is string => Boolean(id))],
      );
    }
    if (productA) await pool.query("DELETE FROM productos WHERE id = $1", [productA]);
    if (productB) await pool.query("DELETE FROM productos WHERE id = $1", [productB]);
    if (categoryA) await pool.query("DELETE FROM categorias WHERE id = $1", [categoryA]);
    if (categoryB) await pool.query("DELETE FROM categorias WHERE id = $1", [categoryB]);
    if (deviceA) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceA]);
    if (deviceB) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceB]);
    if (userA) await pool.query("DELETE FROM usuarios WHERE id = $1", [userA]);
    if (userB) await pool.query("DELETE FROM usuarios WHERE id = $1", [userB]);
    if (establishmentA) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentA]);
    if (establishmentB) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentB]);
  }
});
