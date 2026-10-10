import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

test("manual cash movements are tenant-scoped, idempotent and reconcile cash only", { skip: process.env.CI !== "true" }, async () => {
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
      [`CI cash movement ${suffix}`],
    );
    establishmentId = establishment.rows[0].id as string;
    const user = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentId, `ci-cash-movement-${suffix}`, "CI Cash Movement", await bcrypt.hash("6842", 4)],
    );
    userId = user.rows[0].id as string;
    const device = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentId, `CI cash movement device ${suffix}`],
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
      body: JSON.stringify({ establishmentId, username: `ci-cash-movement-${suffix}`, pin: "6842", deviceId }),
    });
    assert.equal(login.status, 200);
    const token = (await login.json() as { token: string }).token;
    const headers = { authorization: `Bearer ${token}`, "content-type": "application/json" };

    const opened = await fetch(`${baseUrl}/api/v1/cash/open`, {
      method: "POST", headers, body: JSON.stringify({ openingAmount: 100, note: "CI cash open" }),
    });
    assert.equal(opened.status, 201);
    cashRegisterId = (await opened.json() as { cashRegister: { id: string } }).cashRegister.id;

    const key = randomUUID();
    const body = { type: "INGRESO", concept: "CI cash income", amount: 25, paymentMethod: "Efectivo" };
    const first = await fetch(`${baseUrl}/api/v1/cash/movements`, {
      method: "POST", headers: { ...headers, "Idempotency-Key": key }, body: JSON.stringify(body),
    });
    assert.equal(first.status, 201);
    const replay = await fetch(`${baseUrl}/api/v1/cash/movements`, {
      method: "POST", headers: { ...headers, "Idempotency-Key": key }, body: JSON.stringify(body),
    });
    assert.equal(replay.status, 200);
    assert.equal((await replay.json() as { replayed: boolean }).replayed, true);

    const conflict = await fetch(`${baseUrl}/api/v1/cash/movements`, {
      method: "POST",
      headers: { ...headers, "Idempotency-Key": key },
      body: JSON.stringify({ ...body, amount: 26 }),
    });
    assert.equal(conflict.status, 409);
    assert.equal((await conflict.json() as { error: { code: string } }).error.code, "IDEMPOTENCY_CONFLICT");

    const nonCash = await fetch(`${baseUrl}/api/v1/cash/movements`, {
      method: "POST",
      headers: { ...headers, "Idempotency-Key": randomUUID() },
      body: JSON.stringify({ type: "INGRESO", concept: "CI Yape income", amount: 50, paymentMethod: "Yape" }),
    });
    assert.equal(nonCash.status, 201);

    const history = await fetch(`${baseUrl}/api/v1/cash/movements?limit=50`, { headers });
    assert.equal(history.status, 200);
    assert.equal((await history.json() as { pagination: { total: number } }).pagination.total, 2);

    const closed = await fetch(`${baseUrl}/api/v1/cash/close`, {
      method: "POST", headers, body: JSON.stringify({ closingAmount: 125, note: "CI cash close" }),
    });
    assert.equal(closed.status, 200);
    const closeBody = await closed.json() as { reconciliation: { expectedCash: number; difference: number; mixedPaymentsToReview: number } };
    assert.equal(closeBody.reconciliation.expectedCash, 125);
    assert.equal(closeBody.reconciliation.difference, 0);
    assert.equal(closeBody.reconciliation.mixedPaymentsToReview, 0);
  } finally {
    if (server) {
      const closed = once(server, "close");
      server.close();
      await closed;
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
