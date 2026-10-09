import test from "node:test";
import assert from "node:assert/strict";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";

test("electronic documents and daily summaries reject cross-establishment links", { skip: process.env.CI !== "true" }, async () => {
  const { pool } = await import("./db.js");
  const suffix = crypto.randomUUID();
  let establishmentA: string | undefined;
  let establishmentB: string | undefined;
  let userA: string | undefined;
  let userB: string | undefined;
  let deviceA: string | undefined;
  let deviceB: string | undefined;
  let cajaA: string | undefined;
  let saleA: string | undefined;
  let documentA: string | undefined;
  let documentB: string | undefined;
  let summaryA: string | undefined;

  try {
    const a = await pool.query("INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id", [`CI SUNAT A ${suffix}`]);
    establishmentA = a.rows[0].id as string;
    const b = await pool.query("INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id", [`CI SUNAT B ${suffix}`]);
    establishmentB = b.rows[0].id as string;

    const ua = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentA, `ci-sunat-a-${suffix}`, "CI SUNAT A", "test-hash"],
    );
    userA = ua.rows[0].id as string;
    const ub = await pool.query(
      "INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol) VALUES ($1, $2, $3, $4, 'CEO') RETURNING id",
      [establishmentB, `ci-sunat-b-${suffix}`, "CI SUNAT B", "test-hash"],
    );
    userB = ub.rows[0].id as string;

    const da = await pool.query("INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id", [establishmentA, `CI SUNAT device A ${suffix}`]);
    deviceA = da.rows[0].id as string;
    const db = await pool.query("INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'test') RETURNING id", [establishmentB, `CI SUNAT device B ${suffix}`]);
    deviceB = db.rows[0].id as string;

    const caja = await pool.query(
      "INSERT INTO cajas (establecimiento_id, usuario_apertura_id, dispositivo_apertura_id) VALUES ($1, $2, $3) RETURNING id",
      [establishmentA, userA, deviceA],
    );
    cajaA = caja.rows[0].id as string;
    const sale = await pool.query(
      "INSERT INTO ventas (numero, usuario_id, caja_id, dispositivo_id, establecimiento_id, idempotency_key) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id",
      [`CI-SUNAT-SALE-${suffix}`, userA, cajaA, deviceA, establishmentA, crypto.randomUUID()],
    );
    saleA = sale.rows[0].id as string;

    const documentFields = "tipo, serie, numero, fecha_emision, subtotal, igv, total, metodo_pago, establecimiento_id";
    const docA = await pool.query(
      `INSERT INTO comprobantes_electronicos (${documentFields}) VALUES ('03', 'B001', 1, now(), 10, 1.8, 11.8, 'Efectivo', $1) RETURNING id`,
      [establishmentA],
    );
    documentA = docA.rows[0].id as string;
    const docB = await pool.query(
      `INSERT INTO comprobantes_electronicos (${documentFields}) VALUES ('03', 'B001', 1, now(), 10, 1.8, 11.8, 'Efectivo', $1) RETURNING id`,
      [establishmentB],
    );
    documentB = docB.rows[0].id as string;

    await assert.rejects(
      pool.query(
        "UPDATE comprobantes_electronicos SET venta_id = $1 WHERE id = $2",
        [saleA, documentB],
      ),
      (error: { code?: string }) => error.code === "23503",
      "an electronic document must not reference a sale from another establishment",
    );

    const summary = await pool.query(
      "INSERT INTO resumenes_diarios (establecimiento_id, fecha_referencia, correlativo, nombre_archivo) VALUES ($1, CURRENT_DATE, 1, $2) RETURNING id",
      [establishmentA, `CI-SUMMARY-${suffix}`],
    );
    summaryA = summary.rows[0].id as string;

    await assert.rejects(
      pool.query(
        "INSERT INTO resumenes_diarios_detalles (resumen_diario_id, comprobante_electronico_id, line_id, establecimiento_id) VALUES ($1, $2, 1, $3)",
        [summaryA, documentB, establishmentA],
      ),
      (error: { code?: string }) => error.code === "23503",
      "a daily summary must not include an electronic document from another establishment",
    );

    await pool.query(
      "INSERT INTO correlativos (clave, establecimiento_id, ultimo_numero) VALUES ($1, $2, 0)",
      ["BOLETA_B001", establishmentA],
    );
    await pool.query(
      "INSERT INTO correlativos (clave, establecimiento_id, ultimo_numero) VALUES ($1, $2, 0)",
      ["BOLETA_B001", establishmentB],
    );
  } finally {
    if (summaryA) await pool.query("DELETE FROM resumenes_diarios_detalles WHERE resumen_diario_id = $1", [summaryA]);
    if (summaryA) await pool.query("DELETE FROM resumenes_diarios WHERE id = $1", [summaryA]);
    if (documentA) await pool.query("DELETE FROM comprobantes_electronicos WHERE id = $1", [documentA]);
    if (documentB) await pool.query("DELETE FROM comprobantes_electronicos WHERE id = $1", [documentB]);
    if (saleA) await pool.query("DELETE FROM detalle_ventas WHERE venta_id = $1", [saleA]);
    if (saleA) await pool.query("DELETE FROM ventas WHERE id = $1", [saleA]);
    if (cajaA) await pool.query("DELETE FROM movimientos_caja WHERE caja_id = $1", [cajaA]);
    if (cajaA) await pool.query("DELETE FROM cajas WHERE id = $1", [cajaA]);
    if (establishmentA) await pool.query("DELETE FROM correlativos WHERE establecimiento_id = $1", [establishmentA]);
    if (establishmentB) await pool.query("DELETE FROM correlativos WHERE establecimiento_id = $1", [establishmentB]);
    if (deviceA) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceA]);
    if (deviceB) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceB]);
    if (userA) await pool.query("DELETE FROM usuarios WHERE id = $1", [userA]);
    if (userB) await pool.query("DELETE FROM usuarios WHERE id = $1", [userB]);
    if (establishmentA) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentA]);
    if (establishmentB) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentB]);
  }
});
