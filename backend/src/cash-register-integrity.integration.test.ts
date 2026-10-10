import test from "node:test";
import assert from "node:assert/strict";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";

test("cash registers reject opening or closing actors/devices from another establishment", { skip: process.env.CI !== "true" }, async () => {
  const { pool } = await import("./db.js");
  const suffix = crypto.randomUUID();
  let establishmentA: string | undefined;
  let establishmentB: string | undefined;
  let userA: string | undefined;
  let userB: string | undefined;
  let deviceA: string | undefined;
  let deviceB: string | undefined;
  let cashRegisterA: string | undefined;

  try {
    const a = await pool.query("INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id", [`CI cash A ${suffix}`]);
    establishmentA = a.rows[0].id as string;
    const b = await pool.query("INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id", [`CI cash B ${suffix}`]);
    establishmentB = b.rows[0].id as string;

    const ua = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentA, `ci-cash-a-${suffix}`, "CI Cash A", "test-hash"],
    );
    userA = ua.rows[0].id as string;
    const ub = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentB, `ci-cash-b-${suffix}`, "CI Cash B", "test-hash"],
    );
    userB = ub.rows[0].id as string;

    const da = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentA, `CI Cash device A ${suffix}`],
    );
    deviceA = da.rows[0].id as string;
    const db = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id",
      [establishmentB, `CI Cash device B ${suffix}`],
    );
    deviceB = db.rows[0].id as string;

    await assert.rejects(
      pool.query(
        "INSERT INTO cajas (establecimiento_id, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, $2, $3)",
        [establishmentA, userB, deviceA],
      ),
      (error: { code?: string }) => error.code === "23503",
      "cash register opening user must belong to its establishment",
    );
    await assert.rejects(
      pool.query(
        "INSERT INTO cajas (establecimiento_id, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, $2, $3)",
        [establishmentA, userA, deviceB],
      ),
      (error: { code?: string }) => error.code === "23503",
      "cash register opening device must belong to its establishment",
    );

    const caja = await pool.query(
      "INSERT INTO cajas (establecimiento_id, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, $2, $3) RETURNING id",
      [establishmentA, userA, deviceA],
    );
    cashRegisterA = caja.rows[0].id as string;

    await assert.rejects(
      pool.query("UPDATE cajas SET usuario_cierre_id = $1 WHERE id = $2", [userB, cashRegisterA]),
      (error: { code?: string }) => error.code === "23503",
      "cash register closing user must belong to its establishment",
    );
    await assert.rejects(
      pool.query("UPDATE cajas SET dispositivo_cierre_id = $1 WHERE id = $2", [deviceB, cashRegisterA]),
      (error: { code?: string }) => error.code === "23503",
      "cash register closing device must belong to its establishment",
    );
  } finally {
    if (cashRegisterA) await pool.query("DELETE FROM cajas WHERE id = $1", [cashRegisterA]);
    if (deviceA) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceA]);
    if (deviceB) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceB]);
    if (userA) await pool.query("DELETE FROM usuarios WHERE id = $1", [userA]);
    if (userB) await pool.query("DELETE FROM usuarios WHERE id = $1", [userB]);
    if (establishmentA) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentA]);
    if (establishmentB) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentB]);
  }
});
