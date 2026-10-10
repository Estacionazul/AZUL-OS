import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

test("cashier permissions are enforced and logout immediately invalidates the session", { skip: process.env.CI !== "true" }, async (t) => {
  const { pool } = await import("./db.js");
  const suffix = randomUUID();
  let establishmentId: string | undefined;
  let userId: string | undefined;
  let deviceId: string | undefined;
  let server: ReturnType<typeof app.listen> | undefined;

  try {
    const establishment = await pool.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [`CI auth establishment ${suffix}`],
    );
    establishmentId = establishment.rows[0].id as string;

    const user = await pool.query(
      `INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol)
       VALUES ($1, $2, $3, $4, 'CAJERO') RETURNING id`,
      [establishmentId, `ci-cashier-${suffix}`, "CI Cashier", await bcrypt.hash("1234", 4)],
    );
    userId = user.rows[0].id as string;

    const device = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentId, `CI auth device ${suffix}`],
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
      body: JSON.stringify({ establishmentId, username: `ci-cashier-${suffix}`, pin: "1234", deviceId }),
    });
    assert.equal(login.status, 200);
    const { token } = await login.json() as { token: string };
    const headers = { authorization: `Bearer ${token}` };

    const forbidden = await fetch(`${baseUrl}/api/v1/catalog/products`, { headers });
    assert.equal(forbidden.status, 403);
    assert.equal((await forbidden.json() as { error: { code: string } }).error.code, "FORBIDDEN");

    const logout = await fetch(`${baseUrl}/api/v1/auth/logout`, {
      method: "POST",
      headers,
    });
    assert.equal(logout.status, 204);

    const afterLogout = await fetch(`${baseUrl}/api/v1/auth/me`, { headers });
    assert.equal(afterLogout.status, 401);
    assert.equal((await afterLogout.json() as { error: { code: string } }).error.code, "SESSION_REVOKED");
  } finally {
    if (server) await new Promise<void>((resolve) => server!.close(() => resolve()));
    if (userId) await pool.query("DELETE FROM sesiones WHERE usuario_id = $1", [userId]);
    if (userId) await pool.query("DELETE FROM usuarios WHERE id = $1", [userId]);
    if (deviceId) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceId]);
    if (establishmentId) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentId]);
  }
});
