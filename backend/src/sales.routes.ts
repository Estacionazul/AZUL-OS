import { createHash, randomUUID } from "node:crypto";
import { Router } from "express";
import { z } from "zod";
import { pool } from "./db.js";
import { authenticate, requirePermission } from "./auth.js";

export const salesRouter = Router();

const SaleBody = z.object({
  items: z.array(z.object({
    productId: z.string().uuid(),
    quantity: z.number().int().min(1).max(10000),
    size: z.string().trim().max(40).optional(),
    milkType: z.string().trim().max(60).optional(),
    sweetener: z.string().trim().max(60).optional(),
    infusion: z.string().trim().max(60).optional(),
    extraShot: z.boolean().default(false),
    note: z.string().trim().max(500).optional(),
  })).min(1).max(200),
  paymentMethod: z.enum(["Efectivo", "Yape", "Plin", "Tarjeta", "Mixto"]),
  discount: z.number().finite().min(0).max(999999999.99).default(0),
  customerId: z.string().uuid().optional(),
  dni: z.string().trim().max(8).optional(),
  ruc: z.string().trim().max(11).optional(),
  customerName: z.string().trim().max(200).optional(),
  businessName: z.string().trim().max(200).optional(),
  fiscalAddress: z.string().trim().max(300).optional(),
  note: z.string().trim().max(500).optional(),
}).superRefine((value, ctx) => {
  if (value.dni && !/^\d{8}$/.test(value.dni)) {
    ctx.addIssue({ code: "custom", path: ["dni"], message: "El DNI debe tener 8 dígitos." });
  }
  if (value.ruc && !/^\d{11}$/.test(value.ruc)) {
    ctx.addIssue({ code: "custom", path: ["ruc"], message: "El RUC debe tener 11 dígitos." });
  }
});

const money = (value: number) => Math.round((value + Number.EPSILON) * 100) / 100;

const isoDate = z.string()
  .regex(/^\d{4}-\d{2}-\d{2}$/, "Usa el formato AAAA-MM-DD.")
  .refine((value) => {
    const date = new Date(`${value}T00:00:00.000Z`);
    return !Number.isNaN(date.getTime()) && date.toISOString().slice(0, 10) === value;
  }, "La fecha no existe en el calendario.");

const SalesHistoryQuery = z.object({
  from: isoDate.optional(),
  to: isoDate.optional(),
  documentType: z.string().trim().min(1).max(40).optional(),
  limit: z.coerce.number().int().min(1).max(100).default(50),
  offset: z.coerce.number().int().min(0).max(1000000).default(0),
});

salesRouter.get("/", authenticate, requirePermission("Ventas"), async (req, res, next) => {
  const parsed = SalesHistoryQuery.safeParse(req.query);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Filtros de historial inválidos." } });
    return;
  }
  const { from, to, documentType, limit, offset } = parsed.data;
  if (from && to && from > to) {
    res.status(400).json({ error: { code: "INVALID_DATE_RANGE", message: "La fecha inicial no puede ser posterior a la fecha final." } });
    return;
  }
  try {
    const values: (string | null)[] = [req.auth!.establishmentId, from ?? null, to ?? null, documentType ?? null];
    const count = await pool.query(
      `SELECT count(*)::int AS total
         FROM ventas v
        WHERE v.establecimiento_id = $1
          AND ($2::date IS NULL OR v.fecha >= $2::date)
          AND ($3::date IS NULL OR v.fecha < ($3::date + INTERVAL '1 day'))
          AND ($4::text IS NULL OR v.tipo_documento = $4)`,
      values,
    );
    const rows = await pool.query(
      `SELECT v.id, v.numero, v.fecha, v.tipo_documento AS "documentType",
              v.nombre_cliente AS "customerName", v.razon_social AS "businessName",
              v.subtotal, v.igv, v.descuento AS discount, v.total,
              v.metodo_pago AS "paymentMethod", v.observaciones AS note,
              COALESCE((
                SELECT json_agg(json_build_object(
                  'type', ce.tipo, 'series', ce.serie, 'number', ce.numero,
                  'status', ce.estado, 'sunatCode', ce.codigo_respuesta_sunat,
                  'sunatMessage', ce.mensaje_respuesta_sunat, 'issuedAt', ce.fecha_emision
                ) ORDER BY ce.fecha_emision DESC)
                FROM comprobantes_electronicos ce
                WHERE ce.venta_id = v.id AND ce.establecimiento_id = v.establecimiento_id
              ), '[]'::json) AS documents
         FROM ventas v
        WHERE v.establecimiento_id = $1
          AND ($2::date IS NULL OR v.fecha >= $2::date)
          AND ($3::date IS NULL OR v.fecha < ($3::date + INTERVAL '1 day'))
          AND ($4::text IS NULL OR v.tipo_documento = $4)
        ORDER BY v.fecha DESC, v.id DESC
        LIMIT $5 OFFSET $6`,
      [...values, limit, offset],
    );
    res.json({ items: rows.rows, total: Number(count.rows[0]?.total ?? 0), limit, offset });
  } catch (error) {
    next(error);
  }
});

salesRouter.get("/:id", authenticate, requirePermission("Ventas"), async (req, res, next) => {
  const id = z.string().uuid().safeParse(req.params.id);
  if (!id.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Identificador de venta inválido." } });
    return;
  }
  try {
    const result = await pool.query(
      `SELECT v.id, v.numero, v.fecha, v.tipo_documento AS "documentType",
              v.dni, v.ruc, v.nombre_cliente AS "customerName",
              v.razon_social AS "businessName", v.direccion_fiscal AS "fiscalAddress",
              v.subtotal, v.igv, v.descuento AS discount, v.total,
              v.metodo_pago AS "paymentMethod", v.observaciones AS note
         FROM ventas v
        WHERE v.id = $1 AND v.establecimiento_id = $2`,
      [id.data, req.auth!.establishmentId],
    );
    if (!result.rowCount) {
      res.status(404).json({ error: { code: "SALE_NOT_FOUND", message: "No se encontró la venta." } });
      return;
    }
    const details = await pool.query(
      `SELECT id, producto_id AS "productId", nombre_producto AS "productName",
              cantidad AS quantity, precio_unitario AS "unitPrice", subtotal,
              tamano AS size, tipo_leche AS "milkType", endulzante AS sweetener,
              infusion, extra_shot AS "extraShot", observaciones AS note,
              tipo_afectacion_igv AS "taxAffectation"
         FROM detalle_ventas
        WHERE venta_id = $1 AND establecimiento_id = $2
        ORDER BY id`,
      [id.data, req.auth!.establishmentId],
    );
    const documents = await pool.query(
      `SELECT id, tipo AS type, serie AS series, numero AS number,
              fecha_emision AS "issuedAt", estado AS status,
              codigo_respuesta_sunat AS "sunatCode",
              mensaje_respuesta_sunat AS "sunatMessage"
         FROM comprobantes_electronicos
        WHERE venta_id = $1 AND establecimiento_id = $2
        ORDER BY fecha_emision DESC`,
      [id.data, req.auth!.establishmentId],
    );
    res.json({ sale: result.rows[0], items: details.rows, documents: documents.rows });
  } catch (error) {
    next(error);
  }
});

salesRouter.post("/", authenticate, requirePermission("Ventas"), async (req, res, next) => {
  const parsed = SaleBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Datos de venta inválidos." } });
    return;
  }
  const idempotencyKey = req.header("idempotency-key");
  if (!idempotencyKey || !z.string().uuid().safeParse(idempotencyKey).success) {
    res.status(400).json({ error: { code: "IDEMPOTENCY_KEY_REQUIRED", message: "Envía una clave UUID en Idempotency-Key." } });
    return;
  }

  const input = parsed.data;
  const requestHash = createHash("sha256").update(JSON.stringify(input)).digest("hex");
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query("SELECT pg_advisory_xact_lock(hashtext($1))", [idempotencyKey]);

    const prior = await client.query(
      `SELECT id, numero, total, establecimiento_id, idempotency_hash
         FROM ventas WHERE idempotency_key = $1`,
      [idempotencyKey],
    );
    if (prior.rowCount) {
      const row = prior.rows[0];
      if (row.establecimiento_id !== req.auth!.establishmentId) {
        await client.query("COMMIT");
        res.status(409).json({ error: { code: "IDEMPOTENCY_CONFLICT", message: "La clave ya se usó en otro establecimiento." } });
        return;
      }
      if (row.idempotency_hash && row.idempotency_hash !== requestHash) {
        await client.query("COMMIT");
        res.status(409).json({ error: { code: "IDEMPOTENCY_CONFLICT", message: "La clave ya se usó con datos de venta diferentes." } });
        return;
      }
      await client.query("COMMIT");
      res.status(200).json({
        sale: { id: row.id, number: row.numero, total: Number(row.total) },
        replayed: true,
      });
      return;
    }

    const cash = await client.query(
      `SELECT id FROM cajas
        WHERE establecimiento_id = $1 AND estado = 'ABIERTA'
        FOR UPDATE`,
      [req.auth!.establishmentId],
    );
    if (!cash.rowCount) {
      await client.query("ROLLBACK");
      res.status(409).json({ error: { code: "NO_OPEN_CASH_REGISTER", message: "Abre la caja antes de registrar una venta." } });
      return;
    }
    const cashRegisterId = cash.rows[0].id as string;

    if (input.customerId) {
      const customer = await client.query(
        "SELECT id FROM clientes WHERE id = $1 AND establecimiento_id = $2",
        [input.customerId, req.auth!.establishmentId],
      );
      if (!customer.rowCount) {
        await client.query("ROLLBACK");
        res.status(404).json({ error: { code: "CUSTOMER_NOT_FOUND", message: "El cliente no existe en este establecimiento." } });
        return;
      }
    }

    const productIds = [...new Set(input.items.map(item => item.productId))];
    const productResult = await client.query(
      `SELECT id, codigo, nombre, precio_venta, tipo_inventario, tipo_afectacion_igv, emoji, activo
         FROM productos
        WHERE establecimiento_id = $1 AND id = ANY($2::uuid[]) AND activo = true
        ORDER BY id
        FOR UPDATE`,
      [req.auth!.establishmentId, productIds],
    );
    const products = new Map<string, {
      id: string; codigo: string; nombre: string; precio_venta: string;
      tipo_inventario: string; tipo_afectacion_igv: string; emoji: string; activo: boolean;
    }>(productResult.rows.map(row => [row.id as string, row]));
    if (products.size !== productIds.length) {
      await client.query("ROLLBACK");
      res.status(409).json({ error: { code: "PRODUCT_UNAVAILABLE", message: "Uno o más productos no existen, están inactivos o pertenecen a otro establecimiento." } });
      return;
    }

    const prepared = input.items.map(item => {
      const product = products.get(item.productId)!;
      const unitPrice = money(Number(product.precio_venta) + (item.size === "Grande" ? 2 : 0) + (item.extraShot ? 2 : 0));
      return { ...item, product, unitPrice, gross: money(unitPrice * item.quantity) };
    });
    const grossTotal = money(prepared.reduce((sum, item) => sum + item.gross, 0));
    if (input.discount > grossTotal) {
      await client.query("ROLLBACK");
      res.status(400).json({ error: { code: "DISCOUNT_EXCEEDS_TOTAL", message: "El descuento no puede superar el importe de la venta." } });
      return;
    }
    const total = money(grossTotal - input.discount);
    const preparedLines = prepared.map(item => {
      const lineDiscount = grossTotal === 0 ? 0 : money(input.discount * item.gross / grossTotal);
      const lineTotal = money(item.gross - lineDiscount);
      const taxable = item.product.tipo_afectacion_igv === "10";
      const subtotal = taxable ? money(lineTotal / 1.18) : lineTotal;
      const igv = taxable ? money(lineTotal - subtotal) : 0;
      return { ...item, lineDiscount, lineTotal, subtotal, igv };
    });
    const subtotal = money(preparedLines.reduce((sum, item) => sum + item.subtotal, 0));
    const igv = money(total - subtotal);

    // Resolve stock consumption from the catalog and recipe definitions inside this transaction.
    const directProductNeeds = new Map<string, number>();
    const recipeNeeds = new Map<string, number>();
    const recipeProductIds = preparedLines
      .filter(item => item.product.tipo_inventario === "receta")
      .map(item => item.product.id);
    const recipeRows = recipeProductIds.length
      ? await client.query(
          `SELECT r.producto_id, rd.insumo_id, rd.cantidad, i.nombre, i.emoji, i.unidad_medida
             FROM recetas r
             JOIN receta_detalle rd ON rd.receta_id = r.id AND rd.establecimiento_id = r.establecimiento_id
             JOIN insumos i ON i.id = rd.insumo_id AND i.establecimiento_id = r.establecimiento_id
            WHERE r.establecimiento_id = $1 AND r.activo = true
              AND r.producto_id = ANY($2::uuid[]) AND i.activo = true
            ORDER BY rd.insumo_id
            FOR UPDATE OF i`,
          [req.auth!.establishmentId, [...new Set(recipeProductIds)]],
        )
      : { rows: [] as Array<{ producto_id: string; insumo_id: string; cantidad: string; nombre: string; emoji: string; unidad_medida: string }> };
    const recipeByProduct = new Map<string, typeof recipeRows.rows>();
    for (const row of recipeRows.rows) {
      const group = recipeByProduct.get(row.producto_id) ?? [];
      group.push(row);
      recipeByProduct.set(row.producto_id, group);
    }
    for (const line of preparedLines) {
      if (line.product.tipo_inventario === "receta") {
        const ingredients = recipeByProduct.get(line.product.id) ?? [];
        if (!ingredients.length) {
          await client.query("ROLLBACK");
          res.status(409).json({ error: { code: "RECIPE_NOT_CONFIGURED", message: `El producto ${line.product.nombre} no tiene una receta activa con insumos.` } });
          return;
        }
        for (const ingredient of ingredients) {
          recipeNeeds.set(ingredient.insumo_id, (recipeNeeds.get(ingredient.insumo_id) ?? 0) + Number(ingredient.cantidad) * line.quantity);
        }
      } else {
        directProductNeeds.set(line.product.id, (directProductNeeds.get(line.product.id) ?? 0) + line.quantity);
      }
    }

    const stockChecks: Array<{ itemType: "producto" | "insumo"; id: string; name: string; emoji: string; unit: string; needed: number }> = [];
    for (const [id, needed] of directProductNeeds) {
      const product = products.get(id)!;
      stockChecks.push({ itemType: "producto", id, name: product.nombre, emoji: product.emoji ?? "📦", unit: "unid", needed });
    }
    if (recipeNeeds.size) {
      const ingredientIds = [...recipeNeeds.keys()];
      const ingredients = await client.query(
        `SELECT id, nombre, emoji, unidad_medida
           FROM insumos WHERE establecimiento_id = $1 AND id = ANY($2::uuid[]) AND activo = true
          ORDER BY id FOR UPDATE`,
        [req.auth!.establishmentId, ingredientIds],
      );
      if (ingredients.rowCount !== ingredientIds.length) {
        await client.query("ROLLBACK");
        res.status(409).json({ error: { code: "RECIPE_INGREDIENT_UNAVAILABLE", message: "La receta contiene insumos no disponibles." } });
        return;
      }
      for (const ingredient of ingredients.rows) {
        stockChecks.push({
          itemType: "insumo", id: ingredient.id, name: ingredient.nombre,
          emoji: ingredient.emoji ?? "📦", unit: ingredient.unidad_medida,
          needed: recipeNeeds.get(ingredient.id)!,
        });
      }
    }

    for (const stockItem of stockChecks) {
      const stock = await client.query(
        stockItem.itemType === "producto"
          ? "SELECT COALESCE(SUM(cantidad * signo), 0)::numeric(14,4) AS current FROM movimientos_inventario WHERE establecimiento_id = $1 AND producto_id = $2"
          : "SELECT COALESCE(SUM(cantidad * signo), 0)::numeric(14,4) AS current FROM movimientos_inventario WHERE establecimiento_id = $1 AND insumo_id = $2",
        [req.auth!.establishmentId, stockItem.id],
      );
      if (Number(stock.rows[0].current) + 0.0000001 < stockItem.needed) {
        await client.query("ROLLBACK");
        res.status(409).json({
          error: { code: "INSUFFICIENT_STOCK", message: `Stock insuficiente para ${stockItem.name}.`, itemId: stockItem.id, available: Number(stock.rows[0].current), required: stockItem.needed },
        });
        return;
      }
    }

    const nextNumber = await client.query(
      `INSERT INTO correlativos (establecimiento_id, clave, ultimo_numero)
       VALUES ($1, 'NOTA_VENTA', 1)
       ON CONFLICT (clave, establecimiento_id)
       DO UPDATE SET ultimo_numero = correlativos.ultimo_numero + 1
       RETURNING ultimo_numero`,
      [req.auth!.establishmentId],
    );
    const number = `V${String(nextNumber.rows[0].ultimo_numero).padStart(6, "0")}`;
    const insertedSale = await client.query(
      `INSERT INTO ventas
         (numero, usuario_id, caja_id, dispositivo_id, cliente_id, fecha, tipo_documento,
          dni, ruc, nombre_cliente, razon_social, direccion_fiscal, subtotal, igv, descuento,
          total, metodo_pago, observaciones, idempotency_key, establecimiento_id)
       VALUES ($1, $2, $3, $4, $5, now(), 'Nota de Venta',
               $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
       RETURNING id, numero, fecha, subtotal, igv, descuento, total, metodo_pago AS "paymentMethod"`,
      [
        number, req.auth!.userId, cashRegisterId, req.auth!.deviceId, input.customerId ?? null,
        input.dni ?? null, input.ruc ?? null, input.customerName ?? null, input.businessName ?? null,
        input.fiscalAddress ?? null, subtotal, igv, input.discount, total, input.paymentMethod,
        input.note ?? null, idempotencyKey, requestHash, req.auth!.establishmentId,
      ],
    );
    const sale = insertedSale.rows[0] as { id: string; numero: string; fecha: Date; subtotal: string; igv: string; descuento: string; total: string; paymentMethod: string };

    await client.query(
      `INSERT INTO movimientos_caja
         (caja_id, tipo, concepto, monto, metodo_pago, referencia, observacion,
          usuario_id, dispositivo_id, idempotency_key, establecimiento_id)
       VALUES ($1, 'INGRESO', $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
      [
        cashRegisterId, `Venta ${number}`, total, input.paymentMethod, sale.id,
        `Ingreso asociado a la venta ${number}`, req.auth!.userId, req.auth!.deviceId,
        randomUUID(), req.auth!.establishmentId,
      ],
    );

    for (const line of preparedLines) {
      await client.query(
        `INSERT INTO detalle_ventas
           (venta_id, producto_id, nombre_producto, cantidad, precio_unitario, subtotal, tamano,
            tipo_leche, endulzante, infusion, extra_shot, observaciones, tipo_afectacion_igv, establecimiento_id)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`,
        [
          sale.id, line.product.id, line.product.nombre, line.quantity, line.unitPrice, line.lineTotal,
          line.size ?? null, line.milkType ?? null, line.sweetener ?? null, line.infusion ?? null,
          line.extraShot, line.note ?? null, line.product.tipo_afectacion_igv, req.auth!.establishmentId,
        ],
      );
    }

    for (const stockItem of stockChecks) {
      await client.query(
        `INSERT INTO movimientos_inventario
           (establecimiento_id, tipo, nombre_item, emoji, unidad, referencia_id, insumo_id, producto_id,
            cantidad, signo, observacion, usuario_id, dispositivo_id, idempotency_key)
         VALUES ($1, 'VENTA', $2, $3, $4, $5, $6, $7, $8, -1, $9, $10, $11, $12)`,
        [
          req.auth!.establishmentId, stockItem.name, stockItem.emoji, stockItem.unit, sale.id,
          stockItem.itemType === "insumo" ? stockItem.id : null,
          stockItem.itemType === "producto" ? stockItem.id : null,
          stockItem.needed, `Consumo por venta ${number}`, req.auth!.userId, req.auth!.deviceId, randomUUID(),
        ],
      );
    }

    await client.query("COMMIT");
    res.status(201).json({
      sale: {
        id: sale.id, number: sale.numero, date: sale.fecha, subtotal: Number(sale.subtotal),
        igv: Number(sale.igv), discount: Number(sale.descuento), total: Number(sale.total),
        paymentMethod: sale.paymentMethod, items: preparedLines.length,
      },
      replayed: false,
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => undefined);
    next(error);
  } finally {
    client.release();
  }
});
