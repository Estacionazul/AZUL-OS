import { Router } from "express";
import { z } from "zod";
import { pool } from "./db.js";
import { authenticate, requirePermission } from "./auth.js";

export const customersRouter = Router();

const optionalDni = z.string().trim().regex(/^\d{8}$/, "El DNI debe tener ocho dígitos.").nullable().optional();
const optionalRuc = z.string().trim().regex(/^\d{11}$/, "El RUC debe tener once dígitos.").nullable().optional();
const CustomerFields = {
  name: z.string().trim().min(2).max(200),
  dni: optionalDni,
  ruc: optionalRuc,
  phone: z.string().trim().max(30).nullable().optional(),
  email: z.string().trim().email().max(200).nullable().optional(),
  address: z.string().trim().max(300).nullable().optional(),
  observations: z.string().trim().max(1000).nullable().optional(),
};
const CustomerBody = z.object(CustomerFields).strict();
const CustomerUpdate = z.object({
  ...Object.fromEntries(Object.entries(CustomerFields).map(([key, value]) => [key, value.optional()])),
  active: z.boolean().optional(),
}).strict().refine((value) => Object.keys(value).length > 0, "Indica al menos un cambio.");

const customerColumns: Record<string, string> = {
  name: "nombre", dni: "dni", ruc: "ruc", phone: "telefono",
  email: "correo", address: "direccion", observations: "observaciones", active: "activo",
};

function duplicateIdentifier(error: unknown): boolean {
  return typeof error === "object" && error !== null && "code" in error && error.code === "23505";
}

customersRouter.get("/", authenticate, requirePermission("Clientes"), async (req, res, next) => {
  const parsed = z.object({
    q: z.string().trim().max(100).optional(),
    limit: z.coerce.number().int().min(1).max(100).default(50),
    offset: z.coerce.number().int().min(0).max(1_000_000).default(0),
    includeInactive: z.enum(["true", "false"]).default("false"),
  }).safeParse(req.query);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Filtros de clientes inválidos." } });
    return;
  }
  const { q, limit, offset, includeInactive } = parsed.data;
  try {
    const values = [req.auth!.establishmentId, q || null, includeInactive === "true"];
    const [items, count] = await Promise.all([
      pool.query(
        `SELECT id, nombre AS name, dni, ruc, telefono AS phone, correo AS email,
                direccion AS address, fecha_registro AS "registeredAt",
                ultima_visita AS "lastVisitAt", total_gastado AS "totalSpent",
                cantidad_compras AS "purchaseCount", observaciones AS observations,
                activo AS active, updated_at AS "updatedAt"
           FROM clientes
          WHERE establecimiento_id = $1
            AND ($3::boolean OR activo = true)
            AND ($2::text IS NULL OR nombre ILIKE '%' || $2 || '%' OR dni ILIKE '%' || $2 || '%' OR ruc ILIKE '%' || $2 || '%' OR telefono ILIKE '%' || $2 || '%')
          ORDER BY nombre, id
          LIMIT $4 OFFSET $5`,
        [...values, limit, offset],
      ),
      pool.query(
        `SELECT count(*)::integer AS total FROM clientes
          WHERE establecimiento_id = $1
            AND ($3::boolean OR activo = true)
            AND ($2::text IS NULL OR nombre ILIKE '%' || $2 || '%' OR dni ILIKE '%' || $2 || '%' OR ruc ILIKE '%' || $2 || '%' OR telefono ILIKE '%' || $2 || '%')`,
        values,
      ),
    ]);
    res.status(200).json({ items: items.rows, pagination: { limit, offset, total: count.rows[0].total } });
  } catch (error) {
    next(error);
  }
});

customersRouter.post("/", authenticate, requirePermission("Clientes"), async (req, res, next) => {
  const parsed = CustomerBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Datos del cliente inválidos." } });
    return;
  }
  const c = parsed.data;
  try {
    const result = await pool.query(
      `INSERT INTO clientes
         (establecimiento_id, nombre, dni, ruc, telefono, correo, direccion, observaciones)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING id, nombre AS name, dni, ruc, telefono AS phone, correo AS email,
                 direccion AS address, fecha_registro AS "registeredAt",
                 total_gastado AS "totalSpent", cantidad_compras AS "purchaseCount",
                 observaciones AS observations, activo AS active, updated_at AS "updatedAt"`,
      [req.auth!.establishmentId, c.name, c.dni ?? null, c.ruc ?? null, c.phone ?? null, c.email ?? null, c.address ?? null, c.observations ?? null],
    );
    res.status(201).json({ customer: result.rows[0] });
  } catch (error) {
    if (duplicateIdentifier(error)) {
      res.status(409).json({ error: { code: "CUSTOMER_IDENTIFIER_ALREADY_EXISTS", message: "Ya existe un cliente con ese DNI o RUC en este establecimiento." } });
      return;
    }
    next(error);
  }
});

customersRouter.patch("/:id", authenticate, requirePermission("Clientes"), async (req, res, next) => {
  const id = z.string().uuid().safeParse(req.params.id);
  const parsed = CustomerUpdate.safeParse(req.body);
  if (!id.success || !parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Identificador o cambios de cliente inválidos." } });
    return;
  }
  const values: unknown[] = [id.data, req.auth!.establishmentId];
  const sets: string[] = [];
  for (const [key, value] of Object.entries(parsed.data)) {
    values.push(value);
    sets.push(`${customerColumns[key]} = $${values.length}`);
  }
  sets.push("updated_at = now()");
  try {
    const result = await pool.query(
      `UPDATE clientes SET ${sets.join(", ")}
        WHERE id = $1 AND establecimiento_id = $2
        RETURNING id, nombre AS name, dni, ruc, telefono AS phone, correo AS email,
                  direccion AS address, fecha_registro AS "registeredAt",
                  ultima_visita AS "lastVisitAt", total_gastado AS "totalSpent",
                  cantidad_compras AS "purchaseCount", observaciones AS observations,
                  activo AS active, updated_at AS "updatedAt"`,
      values,
    );
    if (!result.rowCount) {
      res.status(404).json({ error: { code: "CUSTOMER_NOT_FOUND", message: "No se encontró el cliente." } });
      return;
    }
    res.status(200).json({ customer: result.rows[0] });
  } catch (error) {
    if (duplicateIdentifier(error)) {
      res.status(409).json({ error: { code: "CUSTOMER_IDENTIFIER_ALREADY_EXISTS", message: "Ya existe un cliente con ese DNI o RUC en este establecimiento." } });
      return;
    }
    next(error);
  }
});
