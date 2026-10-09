import test from "node:test";
import assert from "node:assert/strict";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";

test("sales and cash foreign keys reject cross-establishment references", { skip: process.env.CI !== "true" }, async () => {
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
  let cashRegisterA: string | undefined;
  let cashRegisterB: string | undefined;
  let saleA: string | undefined;
  let saleB: string | undefined;

  try {
    const a = await pool.query("INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id", [`CI sales A ${suffix}`]);
    establishmentA = a.rows[0].id as string;
    const b = await pool.query("INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id", [`CI sales B ${suffix}`]);
    establishmentB = b.rows[0].id as string;

    const ua = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentA, `ci-sales-a-${suffix}`, "CI Sales A", "test-hash"],
    );
    userA = ua.rows[0].id as string;
    const ub = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentB, `ci-sales-b-${suffix}`, "CI Sales B", "test-hash"],
    );
    userB = ub.rows[0].id as string;

    const da = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentA, `CI Sales device A ${suffix}`],
    );
    deviceA = da.rows[0].id as string;
    const db = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentB, `CI Sales device B ${suffix}`],
    );
    deviceB = db.rows[0].id as string;

    const ca = await pool.query(
      "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
      [establishmentA, `CI Sales category A ${suffix}`],
    );
    categoryA = ca.rows[0].id as string;
    const cb = await pool.query(
      "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
      [establishmentB, `CI Sales category B ${suffix}`],
    );
    categoryB = cb.rows[0].id as string;

    const pa = await pool.query(
      "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, tipo_inventario) VALUES ($1, $2, $3, $4, 'producto') RETURNING id",
      [establishmentA, `CI-SA-${suffix}`, "CI Sales product A", categoryA],
    );
    productA = pa.rows[0].id as string;
    const pb = await pool.query(
      "INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, tipo_inventario) VALUES ($1, $2, $3, $4, 'producto') RETURNING id",
      [establishmentB, `CI-SB-${suffix}`, "CI Sales product B", categoryB],
    );
    productB = pb.rows[0].id as string;

    const caja = await pool.query(
      "INSERT INTO cajas (establecimiento_id, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, $2, $3) RETURNING id",
      [establishmentA, userA, deviceA],
    );
    cashRegisterA = caja.rows[0].id as string;

    const cajaB = await pool.query(
      "INSERT INTO cajas (establecimiento_id, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, $2, $3) RETURNING id",
      [establishmentB, userB, deviceB],
    );
    cashRegisterB = cajaB.rows[0].id as string;

    const sharedNumber = `CI-SAME-NUMBER-${suffix}`;
    await pool.query(
      "INSERT INTO ventas (numero, usuario_id, caja_id, dispositivo_id, establecimiento_id, idempotency_key) VALUES ($1, $2, $3, $4, $5, $6)",
      [sharedNumber, userA, cashRegisterA, deviceA, establishmentA, crypto.randomUUID()],
    );
    const saleInB = await pool.query(
      "INSERT INTO ventas (numero, usuario_id, caja_id, dispositivo_id, establecimiento_id, idempotency_key) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id",
      [sharedNumber, userB, cashRegisterB, deviceB, establishmentB, crypto.randomUUID()],
    );
    saleB = saleInB.rows[0].id as string;

    await assert.rejects(
      pool.query(
        "INSERT INTO ventas (numero, usuario_id, caja_id, dispositivo_id, establecimiento_id, idempotency_key) VALUES ($1, $2, $3, $4, $5, $6)",
        [`CI-FOREIGN-DEVICE-${suffix}`, userA, cashRegisterA, deviceB, establishmentA, crypto.randomUUID()],
      ),
      (error: { code?: string }) => error.code === "23503",
      "a sale must not use a device from another establishment",
    );

    const sale = await pool.query(
      "INSERT INTO ventas (numero, usuario_id, caja_id, dispositivo_id, establecimiento_id, idempotency_key) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id",
      [`CI-SALE-${suffix}`, userA, cashRegisterA, deviceA, establishmentA, crypto.randomUUID()],
    );
    saleA = sale.rows[0].id as string;

    await assert.rejects(
      pool.query(
        "INSERT INTO detalle_ventas (venta_id, producto_id, nombre_producto, establecimiento_id) VALUES ($1, $2, $3, $4)",
        [saleA, productB, "Foreign product", establishmentA],
      ),
      (error: { code?: string }) => error.code === "23503",
      "a sale detail must not use a product from another establishment",
    );

    await assert.rejects(
      pool.query(
        "INSERT INTO movimientos_caja (caja_id, tipo, concepto, monto, usuario_id, dispositivo_id, establecimiento_id) VALUES ($1, 'INGRESO', 'CI foreign user', 1, $2, $3, $4)",
        [cashRegisterA, userB, deviceA, establishmentA],
      ),
      (error: { code?: string }) => error.code === "23503",
      "a cash movement must not use a user from another establishment",
    );

    await assert.rejects(
      pool.query(
        "INSERT INTO movimientos_caja (caja_id, tipo, concepto, monto, usuario_id, dispositivo_id, establecimiento_id) VALUES ($1, 'INGRESO', 'CI foreign device', 1, $2, $3, $4)",
        [cashRegisterA, userA, deviceB, establishmentA],
      ),
      (error: { code?: string }) => error.code === "23503",
      "a cash movement must not use a device from another establishment",
    );

    assert.ok(productA);
  } finally {
    if (saleA) await pool.query("DELETE FROM detalle_ventas WHERE venta_id = $1", [saleA]);
    if (saleB) await pool.query("DELETE FROM detalle_ventas WHERE venta_id = $1", [saleB]);
    if (saleA) await pool.query("DELETE FROM ventas WHERE id = $1", [saleA]);
    if (saleB) await pool.query("DELETE FROM ventas WHERE id = $1", [saleB]);
    if (cashRegisterA) await pool.query("DELETE FROM movimientos_caja WHERE caja_id = $1", [cashRegisterA]);
    if (cashRegisterB) await pool.query("DELETE FROM movimientos_caja WHERE caja_id = $1", [cashRegisterB]);
    if (cashRegisterA) await pool.query("DELETE FROM cajas WHERE id = $1", [cashRegisterA]);
    if (cashRegisterB) await pool.query("DELETE FROM cajas WHERE id = $1", [cashRegisterB]);
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
