import { Router } from "express";
import { z } from "zod";
import { pool } from "./db.js";
import { authenticate, requirePermission } from "./auth.js";

export const cashRouter = Router();

const OpenCashBody = z.object({
  openingAmount: z.number().finite().min(0).max(999_999_999.99),
  note: z.string().trim().max(500).optional(),
});

const CloseCashBody = z.object({
  closingAmount: z.number().finite().min(0).max(999_999_999.99),
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
      return;
    }
    next(error);
  }
});

cashRouter.post("/close", authenticate, requirePermission("Caja"), async (req, res, next) => {
  const parsed = CloseCashBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Datos de cierre de caja inválidos." } });
    return;
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
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
    const note = parsed.data.note?.trim() || null;
    const combinedNote = [
      cashRegister.note,
      note,
      mixedPayments > 0 ? `Atención: hay S/ ${mixedPayments.toFixed(2)} en pagos mixtos sin desglose; verificar manualmente.` : null,
    ].filter((value): value is string => Boolean(value)).join("\n") || null;

    const updated = await client.query(
      `UPDATE cajas
          SET estado = 'CERRADA',
              fecha_cierre = now(),
              monto_cierre = $2,
              usuario_cierre_id = $3,
              dispositivo_cierre_id = $4,
              observaciones = $5
        WHERE id = $1 AND establecimiento_id = $6 AND estado = 'ABIERTA'
        RETURNING id, fecha_apertura AS "openedAt", fecha_cierre AS "closedAt",
                  monto_inicial AS "openingAmount", monto_cierre AS "closingAmount",
                  estado, usuario_apertura_id AS "openedByUserId",
                  dispositivo_apertura_id AS "openedByDeviceId",
                  usuario_cierre_id AS "closedByUserId",
                  dispositivo_cierre_id AS "closedByDeviceId", observaciones AS note`,
      [cashRegister.id, parsed.data.closingAmount, req.auth!.userId, req.auth!.deviceId, combinedNote, req.auth!.establishmentId],
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
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => undefined);
    next(error);
  } finally {
    client.release();
  }
});
