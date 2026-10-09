import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

test("cash close reconciles cash-only movements and flags mixed payments", { skip: process.env.CI !== "true" }, async (t) => {
  const { pool } = await import("./db.js");
  const suffix = randomUUID();
  let establishmentId: string | undefined;
  let userId: string | undefined;
  let deviceId: string | undefined;
  let cashRegisterId: string | undefined;
  let server: ReturnType<typeof app.listen> | undefined;

  try {
    const establishment = await pool.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [`CI cash reconciliation ${suffix}`],
    );
    establishmentId = establishment.rows[0].id as string;

    const user = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentId, `ci-reconcile-${suffix}`, "CI Reconciliation", await bcrypt.hash("1234", 4)],
    );
    userId = user.rows[0].id as string;

    const device = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentId, `CI reconciliation device ${suffix}`],
    );
    deviceId = device.rows[0].id as string;

    server = app.listen(0, "127.0.0.1");
    await once(server, "listening");
    const address = server.address();
    assert.ok(address && typeof address !== "string");
    const baseUrl = `http://127.0.0.1:${address.port}`;

    const login = await fetch(`${baseUrl}/api/v1/auth/login`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ establishmentId, username: `ci-reconcile-${suffix}`, pin: "1234", deviceId }),
    });
    assert.equal(login.status, 200);
    const loginBody = await login.json() as { token: string };
    assert.ok(loginBody.token);

    const cash = await pool.query(
      "INSERT INTO cajas (establecimiento_id, monto_inicial, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, 100, $2, $3) RETURNING id",
      [establishmentId, userId, deviceId],
    );
    cashRegisterId = cash.rows[0].id as string;

    for (const [type, amount, method] of [
      ["INGRESO", 25, "Efectivo"],
      ["EGRESO", 5, "Efectivo"],
      ["INGRESO", 20, "Mixto"],
      ["INGRESO", 50, "Yape"],
    ] as const) {
      await pool.query(
        "INSERT INTO movimientos_caja (caja_id, tipo, concepto, monto, metodo_pago, usuario_id, dispositivo_id, idempotency_key, establecimiento_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)",
        [cashRegisterId, type, `CI ${method} movement`, amount, method, userId, deviceId, randomUUID(), establishmentId],
      );
    }

    const close = await fetch(`${baseUrl}/api/v1/cash/close`, {
      method: "POST",
      headers: {
        authorization: `Bearer ${loginBody.token}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({ closingAmount: 120, note: "CI close" }),
    });
    assert.equal(close.status, 200);
    const closeBody = await close.json() as {
      reconciliation: { expectedCash: number; countedCash: number; difference: number; mixedPaymentsToReview: number };
      cashRegister: { note: string; estado: string };
    };
    assert.deepEqual(closeBody.reconciliation, {
      expectedCash: 120,
      countedCash: 120,
      difference: 0,
      mixedPaymentsToReview: 20,
    });
    assert.equal(closeBody.cashRegister.estado, "CERRADA");
    assert.match(closeBody.cashRegister.note, /pagos mixtos sin desglose/);
  } finally {
    if (server) {
      server.close();
      await once(server, "close");
    }
    if (cashRegisterId) await pool.query("DELETE FROM movimientos_caja WHERE caja_id = $1", [cashRegisterId]);
    if (cashRegisterId) await pool.query("DELETE FROM cajas WHERE id = $1", [cashRegisterId]);
    if (userId) await pool.query("DELETE FROM sesiones WHERE usuario_id = $1", [userId]);
    if (deviceId) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceId]);
    if (userId) await pool.query("DELETE FROM usuarios WHERE id = $1", [userId]);
    if (establishmentId) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentId]);
    await pool.end();
  }
});
