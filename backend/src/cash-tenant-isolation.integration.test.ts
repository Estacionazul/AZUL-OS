import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

test("cash register current/open/close operations are isolated by establishment", { skip: process.env.CI !== "true" }, async () => {
  const { pool } = await import("./db.js");
  const suffix = randomUUID();
  const ids: Record<string, string | undefined> = {
    establishmentA: undefined, establishmentB: undefined,
    userA: undefined, userB: undefined, deviceA: undefined, deviceB: undefined,
    cashA: undefined, cashB: undefined,
  };
  let server: ReturnType<typeof app.listen> | undefined;

  try {
    for (const tenant of ["A", "B"] as const) {
      const establishment = await pool.query(
        "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
        [`CI cash tenant ${tenant} ${suffix}`],
      );
      const establishmentId = establishment.rows[0].id as string;
      ids[tenant === "A" ? "establishmentA" : "establishmentB"] = establishmentId;
      const user = await pool.query(
        "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
        [establishmentId, `ci-cash-${tenant.toLowerCase()}-${suffix}`, `CI Cash ${tenant}`, await bcrypt.hash("1234", 4)],
      );
      ids[tenant === "A" ? "userA" : "userB"] = user.rows[0].id as string;
      const device = await pool.query(
        "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
        [establishmentId, `CI cash device ${tenant} ${suffix}`],
      );
      ids[tenant === "A" ? "deviceA" : "deviceB"] = device.rows[0].id as string;
    }

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
          username: `ci-cash-${tenant.toLowerCase()}-${suffix}`,
          pin: "1234",
          deviceId: ids[tenant === "A" ? "deviceA" : "deviceB"],
        }),
      });
      assert.equal(response.status, 200);
      return (await response.json() as { token: string }).token;
    };
    const tokenA = await login("A");
    const tokenB = await login("B");
    const headers = (token: string) => ({ authorization: `Bearer ${token}`, "content-type": "application/json" });

    const openB = await fetch(`${baseUrl}/api/v1/cash/open`, {
      method: "POST", headers: headers(tokenB), body: JSON.stringify({ openingAmount: 80, note: "CI tenant B" }),
    });
    assert.equal(openB.status, 201);
    const openedB = await openB.json() as { cashRegister: { id: string } };
    ids.cashB = openedB.cashRegister.id;

    const currentAInitially = await fetch(`${baseUrl}/api/v1/cash/current`, { headers: headers(tokenA) });
    assert.equal(currentAInitially.status, 200);
    assert.equal((await currentAInitially.json() as { cashRegister: unknown }).cashRegister, null);

    const closeForeign = await fetch(`${baseUrl}/api/v1/cash/close`, {
      method: "POST", headers: { ...headers(tokenA), "Idempotency-Key": randomUUID() }, body: JSON.stringify({ closingAmount: 80 }),
    });
    assert.equal(closeForeign.status, 409);
    assert.equal((await closeForeign.json() as { error: { code: string } }).error.code, "NO_OPEN_CASH_REGISTER");

    const openA = await fetch(`${baseUrl}/api/v1/cash/open`, {
      method: "POST", headers: headers(tokenA), body: JSON.stringify({ openingAmount: 25, note: "CI tenant A" }),
    });
    assert.equal(openA.status, 201);
    const openedA = await openA.json() as { cashRegister: { id: string } };
    ids.cashA = openedA.cashRegister.id;
    assert.notEqual(ids.cashA, ids.cashB);

    const currentA = await fetch(`${baseUrl}/api/v1/cash/current`, { headers: headers(tokenA) });
    assert.equal(currentA.status, 200);
    assert.equal((await currentA.json() as { cashRegister: { id: string } }).cashRegister.id, ids.cashA);

    const closeA = await fetch(`${baseUrl}/api/v1/cash/close`, {
      method: "POST", headers: { ...headers(tokenA), "Idempotency-Key": randomUUID() }, body: JSON.stringify({ closingAmount: 25 }),
    });
    assert.equal(closeA.status, 200);

    const currentBAfter = await fetch(`${baseUrl}/api/v1/cash/current`, { headers: headers(tokenB) });
    assert.equal(currentBAfter.status, 200);
    assert.equal((await currentBAfter.json() as { cashRegister: { id: string } }).cashRegister.id, ids.cashB);
  } finally {
    if (server) {
      const closed = once(server, "close");
      server.close();
      await closed;
    }
    for (const cashId of [ids.cashA, ids.cashB]) {
      if (cashId) await pool.query("DELETE FROM movimientos_caja WHERE caja_id = $1", [cashId]);
      if (cashId) await pool.query("DELETE FROM cajas WHERE id = $1", [cashId]);
    }
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
