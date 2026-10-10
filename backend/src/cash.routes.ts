import { Router } from "express";
import { createHash } from "node:crypto";
import { z } from "zod";
import { pool } from "./db.js";
import { authenticate, requirePermission } from "./auth.js";

export const cashRouter = Router();

const hasAtMostTwoDecimals = (value: number) => /^\d+(?:\.\d{1,2})?$/.test(value.toString());

const OpenCashBody = z.object({
  openingAmount: z.number().finite().min(0).max(999_999_999.99).refine(hasAtMostTwoDecimals, "El monto admite hasta dos decimales."),
  note: z.string().trim().max(500).optional(),
});

const CloseCashBody = z.object({
  closingAmount: z.number().finite().min(0).max(999_999_999.99).refine(hasAtMostTwoDecimals, "El monto admite hasta dos decimales."),
  note: z.string().trim().max(500).optional(),
});

cashRouter.get("/current", authenticate, requirePermission("Caja"), async (req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT id, fecha_apertura AS "openedAt", monto_inicial AS "openingAmount",
              usuario_apertura_id AS "openedByUserId",
              dispositivo_apertura_id AS "openedByDeviceId",
              observaciones AS note
         FROM cajas
        WHERE establecimiento_id = $1 AND estado = 'ABIERTA'
        ORDER BY fecha_apertura DESC
        LIMIT 1`,
      [req.auth!.establishmentId],
    );
    res.status(200).json({ cashRegister: result.rows[0] ?? null });
  } catch (error) {
    next(error);
  }
});

cashRouter.post("/open", authenticate, requirePermission("Caja"), async (req, res, next) => {
  const parsed = OpenCashBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Datos de apertura de caja inválidos." } });
    return;
  }

  try {
    const result = await pool.query(
      `INSERT INTO cajas
         (establecimiento_id, monto_inicial, observaciones, usuario_apertura_id, dispositivo_apertura_id)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, fecha_apertura AS "openedAt", monto_inicial AS "openingAmount",
                 estado, usuario_apertura_id AS "openedByUserId",
                 dispositivo_apertura_id AS "openedByDeviceId", observaciones AS note`,
      [
        req.auth!.establishmentId,
        parsed.data.openingAmount,
        parsed.data.note ?? null,
        req.auth!.userId,
        req.auth!.deviceId,
      ],
    );
    res.status(201).json({ cashRegister: result.rows[0] });
  } catch (error) {
    if (typeof error === "object" && error !== null && "code" in error && error.code === "23505") {
      res.status(409).json({ error: { code: "CASH_REGISTER_ALREADY_OPEN", message: "Ya existe una caja abierta para este establecimiento." } });
    cashRouter.post("/close", authenticate, requirePermission("Caja"), async (req, res, next) => {
  const parsed = CloseCashBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Datos de cierre de caja inválidos." } });
    return;
  }
  const key = z.string().uuid().safeParse(req.get("Idempotency-Key"));
  if (!key.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Falta una clave de idempotencia válida para el cierre." } });
    return;
  }
  const note = parsed.data.note?.trim() || null;
  const requestHash = createHash("sha256").update(JSON.stringify({
    closingAmount: parsed.data.closingAmount,
    note,
  })).digest("hex");

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const prior = await client.query(
      `SELECT id, fecha_apertura AS "openedAt", fecha_cierre AS "closedAt",
              monto_inicial AS "openingAmount", monto_cierre AS "closingAmount",
              estado, usuario_apertura_id AS "openedByUserId",
              dispositivo_apertura_id AS "openedByDeviceId",
              usuario_cierre_id AS "closedByUserId",
              dispositivo_cierre_id AS "closedByDeviceId", observaciones AS note,
              cierre_request_hash AS "requestHash",
              cierre_efectivo_esperado AS "expectedCash",
              cierre_diferencia AS difference,
              cierre_pagos_mixtos AS "mixedPaymentsToReview",
              usuario_cierre_id AS "closedByUserId",
              dispositivo_cierre_id AS "closedByDeviceId"
         FROM cajas
        WHERE establecimiento_id = $1 AND cierre_idempotency_key = $2
        FOR UPDATE`,
      [req.auth!.establishmentId, key.data],
    );
    if (prior.rowCount) {
      const row = prior.rows[0];
      const sameActor = row.closedByUserId === req.auth!.userId &&
        row.closedByDeviceId === req.auth!.deviceId;
      if (row.requestHash !== requestHash || !sameActor || row.estado !== "CERRADA") {
        await client.query("COMMIT");
        res.status(409).json({ error: { code: "IDEMPOTENCY_CONFLICT", message: "La clave de cierre ya fue utilizada con otros datos, usuario o dispositivo." } });
        return;
      }
      await client.query("COMMIT");
      res.status(200).json({
        cashRegister: {
          id: row.id, openedAt: row.openedAt, closedAt: row.closedAt,
          openingAmount: Number(row.openingAmount), closingAmount: Number(row.closingAmount),
          estado: row.estado, openedByUserId: row.openedByUserId,
          openedByDeviceId: row.openedByDeviceId, closedByUserId: row.closedByUserId,
          closedByDeviceId: row.closedByDeviceId, note: row.note,
        },
        reconciliation: {
          expectedCash: Number(row.expectedCash),
          countedCash: Number(row.closingAmount),
          difference: Number(row.difference),
          mixedPaymentsToReview: Number(row.mixedPaymentsToReview),
        },
        replayed: true,
      });
      return;
    }

    const current = await client.query(
      `SELECT id, fecha_apertura AS "openedAt", monto_inicial AS "openingAmount",
              usuario_apertura_id AS "openedByUserId",
              dispositivo_apertura_id AS "openedByDeviceId", observaciones AS note
         FROM cajas
        WHERE establecimiento_id = $1 AND estado = 'ABIERTA'
        FOR UPDATE`,
      [req.auth!.establishmentId],
    );
    if (!current.rowCount) {
      await client.query("ROLLBACK");
      res.status(409).json({ error: { code: "NO_OPEN_CASH_REGISTER", message: "No hay una caja abierta para cerrar." } });
      return;
    }

    const cashRegister = current.rows[0];
    const totals = await client.query(
      `SELECT
         COALESCE(SUM(CASE
           WHEN metodo_pago = 'Efectivo' AND tipo = 'INGRESO' THEN monto
           WHEN metodo_pago = 'Efectivo' AND tipo = 'EGRESO' THEN -monto
           ELSE 0
         END), 0)::numeric(14,2) AS "cashMovements",
         COALESCE(SUM(CASE WHEN metodo_pago = 'Mixto' THEN monto ELSE 0 END), 0)::numeric(14,2) AS "mixedPayments"
       FROM movimientos_caja
       WHERE caja_id = $1 AND establecimiento_id = $2`,
      [cashRegister.id, req.auth!.establishmentId],
    );
    const cashMovements = Number(totals.rows[0].cashMovements);
    const mixedPayments = Number(totals.rows[0].mixedPayments);
    const expectedAmount = Math.round((Number(cashRegister.openingAmount) + cashMovements + Number.EPSILON) * 100) / 100;
    const difference = Math.round((parsed.data.closingAmount - expectedAmount + Number.EPSILON) * 100) / 100;
    const combinedNote = [
      cashRegister.note,
      note,
      mixedPayments > 0 ? `Atención: hay S/ ${mixedPayments.toFixed(2)} en pagos mixtos sin desglose; verificar manualmente.` : null,
    ].filter((value): value is string => Boolean(value)).join("\\n") || null;

    const updated = await client.query(
      `UPDATE cajas
          SET estado = 'CERRADA',
              fecha_cierre = now(),
              monto_cierre = $2,
              usuario_cierre_id = $3,
              dispositivo_cierre_id = $4,
              observaciones = $5,
              cierre_idempotency_key = $7,
              cierre_request_hash = $8,
              cierre_efectivo_esperado = $9,
              cierre_diferencia = $10,
              cierre_pagos_mixtos = $11
        WHERE id = $1 AND establecimiento_id = $6 AND estado = 'ABIERTA'
        RETURNING id, fecha_apertura AS "openedAt", fecha_cierre AS "closedAt",
                  monto_inicial AS "openingAmount", monto_cierre AS "closingAmount",
                  estado, usuario_apertura_id AS "openedByUserId",
                  dispositivo_apertura_id AS "openedByDeviceId",
                  usuario_cierre_id AS "closedByUserId",
                  dispositivo_cierre_id AS "closedByDeviceId", observaciones AS note`,
      [cashRegister.id, parsed.data.closingAmount, req.auth!.userId, req.auth!.deviceId,
        combinedNote, req.auth!.establishmentId, key.data, requestHash, expectedAmount, difference, mixedPayments],
    );
    if (!updated.rowCount) {
      await client.query("ROLLBACK");
      res.status(409).json({ error: { code: "NO_OPEN_CASH_REGISTER", message: "La caja ya fue cerrada por otra operación." } });
      return;
    }
    await client.query("COMMIT");
    res.status(200).json({
      cashRegister: updated.rows[0],
      reconciliation: { expectedCash: expectedAmount, countedCash: parsed.data.closingAmount, difference, mixedPaymentsToReview: mixedPayments },
      replayed: false,
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => undefined);
    next(error);
  } finally {
    client.release();
  }
});


finally {
    client.release();
  }
});


const CashMovementBody = z.object({
  type: z.enum(["INGRESO", "EGRESO"]),
  concept: z.string().trim().min(2).max(160),
  amount: z.number().finite().positive().max(999999999.99)
    .refine(hasAtMostTwoDecimals, "El importe admite hasta dos decimales."),
  paymentMethod: z.enum(["Efectivo", "Yape", "Plin", "Tarjeta"]),
  reference: z.string().trim().max(200).optional(),
  note: z.string().trim().max(500).optional(),
}).strict();

const CashMovementQuery = z.object({
  type: z.enum(["INGRESO", "EGRESO"]).optional(),
  from: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  to: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  limit: z.coerce.number().int().min(1).max(100).default(50),
  offset: z.coerce.number().int().min(0).max(1000000).default(0),
});

cashRouter.get("/movements", authenticate, requirePermission("Caja"), async (req, res, next) => {
  const parsed = CashMovementQuery.safeParse(req.query);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Filtros de movimientos de caja inválidos." } });
    return;
  }
  const { type, from, to, limit, offset } = parsed.data;
  if (from && to && from > to) {
    res.status(400).json({ error: { code: "INVALID_DATE_RANGE", message: "La fecha inicial no puede ser posterior a la fecha final." } });
    return;
  }
  try {
    const values = [req.auth!.establishmentId, type ?? null, from ?? null, to ?? null];
    const [items, count] = await Promise.all([
      pool.query(
        `SELECT m.id, m.caja_id AS "cashRegisterId", m.fecha AS date, m.tipo AS type,
                m.concepto AS concept, m.monto AS amount, m.metodo_pago AS "paymentMethod",
                m.referencia AS reference, m.observacion AS note,
                m.usuario_id AS "userId", m.dispositivo_id AS "deviceId"
           FROM movimientos_caja m
          WHERE m.establecimiento_id = $1
            AND ($2::text IS NULL OR m.tipo = $2)
            AND ($3::date IS NULL OR m.fecha >= $3::date)
            AND ($4::date IS NULL OR m.fecha < ($4::date + INTERVAL '1 day'))
          ORDER BY m.fecha DESC, m.id DESC
          LIMIT $5 OFFSET $6`,
        [...values, limit, offset],
      ),
      pool.query(
        `SELECT count(*)::integer AS total FROM movimientos_caja m
          WHERE m.establecimiento_id = $1
            AND ($2::text IS NULL OR m.tipo = $2)
            AND ($3::date IS NULL OR m.fecha >= $3::date)
            AND ($4::date IS NULL OR m.fecha < ($4::date + INTERVAL '1 day'))`,
        values,
      ),
    ]);
    res.status(200).json({ items: items.rows, pagination: { limit, offset, total: count.rows[0].total } });
  } catch (error) {
    next(error);
  }
});

cashRouter.post("/movements", authenticate, requirePermission("Caja"), async (req, res, next) => {
  const parsed = CashMovementBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Datos del movimiento de caja inválidos." } });
    return;
  }
  const key = req.header("idempotency-key");
  if (!key || !z.string().uuid().safeParse(key).success) {
    res.status(400).json({ error: { code: "IDEMPOTENCY_KEY_REQUIRED", message: "Envía una clave UUID en Idempotency-Key." } });
    return;
  }

  const input = parsed.data;
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const prior = await client.query(
      `SELECT id, caja_id, tipo, concepto, monto, metodo_pago, referencia, observacion,
              usuario_id, dispositivo_id
         FROM movimientos_caja
        WHERE idempotency_key = $1 AND establecimiento_id = $2
        FOR UPDATE`,
      [key, req.auth!.establishmentId],
    );
    if (prior.rowCount) {
      const row = prior.rows[0];
      const same = row.tipo === input.type
        && row.concepto === input.concept
        && Number(row.monto) === input.amount
        && row.metodo_pago === input.paymentMethod
        && (row.referencia ?? null) === (input.reference ?? null)
        && (row.observacion ?? null) === (input.note ?? null)
        && row.usuario_id === req.auth!.userId
        && row.dispositivo_id === req.auth!.deviceId;
      await client.query("COMMIT");
      if (!same) {
        res.status(409).json({ error: { code: "IDEMPOTENCY_CONFLICT", message: "La clave de idempotencia ya se usó con otros datos." } });
        return;
      }
      res.status(200).json({ movement: { id: row.id, cashRegisterId: row.caja_id, type: row.tipo, concept: row.concepto, amount: Number(row.monto), paymentMethod: row.metodo_pago, reference: row.referencia, note: row.observacion }, replayed: true });
      return;
    }

    const cash = await client.query(
      `SELECT id FROM cajas
        WHERE establecimiento_id = $1 AND estado = 'ABIERTA'
        ORDER BY fecha_apertura DESC LIMIT 1 FOR UPDATE`,
      [req.auth!.establishmentId],
    );
    if (!cash.rowCount) {
      await client.query("ROLLBACK");
      res.status(409).json({ error: { code: "NO_OPEN_CASH_REGISTER", message: "Abre una caja antes de registrar movimientos." } });
      return;
    }
    const inserted = await client.query(
      `INSERT INTO movimientos_caja
         (caja_id, tipo, concepto, monto, metodo_pago, referencia, observacion,
          usuario_id, dispositivo_id, idempotency_key, establecimiento_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING id, caja_id AS "cashRegisterId", tipo AS type, concepto AS concept,
                 monto AS amount, metodo_pago AS "paymentMethod", referencia AS reference,
                 observacion AS note, fecha AS date`,
      [cash.rows[0].id, input.type, input.concept, input.amount, input.paymentMethod,
       input.reference ?? null, input.note ?? null, req.auth!.userId, req.auth!.deviceId,
       key, req.auth!.establishmentId],
    );
    await client.query("COMMIT");
    res.status(201).json({ movement: inserted.rows[0], replayed: false });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => undefined);
    if (typeof error === "object" && error !== null && "code" in error && error.code === "23505") {
      res.status(409).json({ error: { code: "IDEMPOTENCY_CONFLICT", message: "La clave de idempotencia ya fue utilizada." } });
      return;
    }
    next(error);
  } finally {
    client.release();
  }
});
