import { Router, type NextFunction, type Request, type Response } from "express";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { pool } from "./db.js";
import { authenticate } from "./auth.js";

export const adminRouter = Router();

const MODULES = [
  "Cafetería",
  "Productos",
  "Inventario",
  "Recetas",
  "Producción",
  "Ventas",
  "Clientes",
  "Caja",
  "Reportes",
  "Configuración",
  "Pedidos",
] as const;

function requireCeo(req: Request, res: Response, next: NextFunction): void {
  if (!req.auth) {
    res.status(401).json({ error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." } });
    return;
  }
  if (req.auth.role !== "CEO") {
    res.status(403).json({ error: { code: "CEO_REQUIRED", message: "Esta operación está reservada al CEO." } });
    return;
  }
  next();
}

adminRouter.use(authenticate, requireCeo);

adminRouter.get("/devices", async (req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT id, nombre AS name, plataforma AS platform, activo AS active,
              ultimo_acceso AS "lastSeenAt", created_at AS "createdAt"
         FROM dispositivos
        WHERE establecimiento_id = $1
        ORDER BY created_at DESC, nombre`,
      [req.auth!.establishmentId],
    );
    res.status(200).json({ items: result.rows });
  } catch (error) {
    next(error);
  }
});

const CreateDeviceBody = z.object({
  name: z.string().trim().min(2).max(120),
  platform: z.enum(["windows", "android", "tablet", "ios", "other"]),
});

adminRouter.post("/devices", async (req, res, next) => {
  const parsed = CreateDeviceBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Datos del dispositivo inválidos." } });
    return;
  }
  try {
    const result = await pool.query(
      `INSERT INTO dispositivos (id, establecimiento_id, nombre, plataforma)
       VALUES ($1, $2, $3, $4)
       RETURNING id, nombre AS name, plataforma AS platform, activo AS active, created_at AS "createdAt"`,
      [randomUUID(), req.auth!.establishmentId, parsed.data.name, parsed.data.platform],
    );
    res.status(201).json({ device: result.rows[0] });
  } catch (error) {
    next(error);
  }
});

const DeviceUpdateBody = z.object({ active: z.boolean() }).strict();

adminRouter.patch("/devices/:id", async (req, res, next) => {
  const id = z.string().uuid().safeParse(req.params.id);
  const parsed = DeviceUpdateBody.safeParse(req.body);
  if (!id.success || !parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Identificador o cambio de dispositivo inválido." } });
    return;
  }
  try {
    const result = await pool.query(
      `UPDATE dispositivos SET activo = $3
        WHERE id = $1 AND establecimiento_id = $2
        RETURNING id, nombre AS name, plataforma AS platform, activo AS active,
                  ultimo_acceso AS "lastSeenAt", created_at AS "createdAt"`,
      [id.data, req.auth!.establishmentId, parsed.data.active],
    );
    if (!result.rowCount) {
      res.status(404).json({ error: { code: "DEVICE_NOT_FOUND", message: "No se encontró el dispositivo." } });
      return;
    }
    res.status(200).json({ device: result.rows[0] });
  } catch (error) {
    next(error);
  }
});

adminRouter.get("/users", async (req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT u.id, u.usuario AS username, u.nombre AS name, u.rol AS role,
              u.activo AS active, u.created_at AS "createdAt",
              COALESCE((
                SELECT json_object_agg(p.modulo, p.permitido ORDER BY p.modulo)
                  FROM permisos_usuario p WHERE p.usuario_id = u.id
              ), '{}'::json) AS permissions
         FROM usuarios u
        WHERE u.establecimiento_id = $1
        ORDER BY u.created_at DESC, u.usuario`,
      [req.auth!.establishmentId],
    );
    res.status(200).json({ items: result.rows });
  } catch (error) {
    next(error);
  }
});

const UserBody = z.object({
  username: z.string().trim().min(3).max(80).regex(/^[a-zA-Z0-9._-]+$/),
  name: z.string().trim().min(2).max(120),
  pin: z.string().regex(/^\d{4}$/),
  permissions: z.array(z.enum(MODULES)).max(MODULES.length).default([]),
});

adminRouter.post("/users", async (req, res, next) => {
  const parsed = UserBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Datos del usuario inválidos. El PIN debe tener cuatro dígitos." } });
    return;
  }
  if (["0000", "1111", "1234", "4321", "1212"].includes(parsed.data.pin)) {
    res.status(400).json({ error: { code: "WEAK_PIN", message: "Elige un PIN de cuatro dígitos menos predecible." } });
    return;
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const id = randomUUID();
    const pinHash = await bcrypt.hash(parsed.data.pin, 12);
    const inserted = await client.query(
      `INSERT INTO usuarios (id, establecimiento_id, usuario, nombre, pin_hash, rol)
       VALUES ($1, $2, $3, $4, $5, 'CAJERO')
       RETURNING id, usuario AS username, nombre AS name, rol AS role, activo AS active, created_at AS "createdAt"`,
      [id, req.auth!.establishmentId, parsed.data.username, parsed.data.name, pinHash],
    );
    const permissions = new Set(parsed.data.permissions);
    await client.query(
      `INSERT INTO permisos_usuario (usuario_id, modulo, permitido)
       SELECT $1, module_name, module_name = ANY($2::text[])
         FROM unnest($3::text[]) AS module_name`,
      [id, parsed.data.permissions, MODULES],
    );
    await client.query("COMMIT");
    res.status(201).json({
      user: { ...inserted.rows[0], permissions: Object.fromEntries(MODULES.map((module) => [module, permissions.has(module)])) },
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => undefined);
    if (typeof error === "object" && error !== null && "code" in error && error.code === "23505") {
      res.status(409).json({ error: { code: "USERNAME_ALREADY_EXISTS", message: "Ese nombre de usuario ya existe en el establecimiento." } });
      return;
    }
    next(error);
  } finally {
    client.release();
  }
});

const UserUpdateBody = z.object({
  name: z.string().trim().min(2).max(120).optional(),
  active: z.boolean().optional(),
  pin: z.string().regex(/^\d{4}$/).optional(),
  permissions: z.array(z.enum(MODULES)).max(MODULES.length).optional(),
}).strict().refine((value) => Object.keys(value).length > 0, "Debes indicar al menos un cambio");

adminRouter.patch("/users/:id", async (req, res, next) => {
  const id = z.string().uuid().safeParse(req.params.id);
  const parsed = UserUpdateBody.safeParse(req.body);
  if (!id.success || !parsed.success) {
    res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Identificador o cambios de usuario inválidos." } });
    return;
  }
  if (parsed.data.pin && ["0000", "1111", "1234", "4321", "1212"].includes(parsed.data.pin)) {
    res.status(400).json({ error: { code: "WEAK_PIN", message: "Elige un PIN de cuatro dígitos menos predecible." } });
    return;
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const current = await client.query(
      "SELECT id, rol FROM usuarios WHERE id = $1 AND establecimiento_id = $2 FOR UPDATE",
      [id.data, req.auth!.establishmentId],
    );
    if (!current.rowCount) {
      await client.query("ROLLBACK");
      res.status(404).json({ error: { code: "USER_NOT_FOUND", message: "No se encontró el usuario." } });
      return;
    }
    if (current.rows[0].rol === "CEO" && parsed.data.active === false) {
      await client.query("ROLLBACK");
      res.status(409).json({ error: { code: "CEO_DEACTIVATION_BLOCKED", message: "No se puede desactivar el CEO desde esta operación." } });
      return;
    }

    const updates: string[] = [];
    const values: unknown[] = [id.data, req.auth!.establishmentId];
    if (parsed.data.name !== undefined) {
      values.push(parsed.data.name);
      updates.push(`nombre = $${values.length}`);
    }
    if (parsed.data.active !== undefined) {
      values.push(parsed.data.active);
      updates.push(`activo = $${values.length}`);
    }
    if (parsed.data.pin !== undefined) {
      values.push(await bcrypt.hash(parsed.data.pin, 12));
      updates.push(`pin_hash = $${values.length}`);
      updates.push("intentos_fallidos = 0", "bloqueado_hasta = NULL");
    }
    let user: Record<string, unknown> | undefined;
    if (updates.length) {
      updates.push("updated_at = now()");
      const updated = await client.query(
        `UPDATE usuarios SET ${updates.join(", ")}
          WHERE id = $1 AND establecimiento_id = $2
          RETURNING id, usuario AS username, nombre AS name, rol AS role, activo AS active, created_at AS "createdAt"`,
        values,
      );
      user = updated.rows[0];
    } else {
      const unchanged = await client.query(
        `SELECT id, usuario AS username, nombre AS name, rol AS role, activo AS active, created_at AS "createdAt"
           FROM usuarios WHERE id = $1 AND establecimiento_id = $2`,
        [id.data, req.auth!.establishmentId],
      );
      user = unchanged.rows[0];
    }

    if (parsed.data.permissions !== undefined) {
      await client.query("DELETE FROM permisos_usuario WHERE usuario_id = $1", [id.data]);
      await client.query(
        `INSERT INTO permisos_usuario (usuario_id, modulo, permitido)
         SELECT $1, module_name, module_name = ANY($2::text[])
           FROM unnest($3::text[]) AS module_name`,
        [id.data, parsed.data.permissions, MODULES],
      );
    }
    if (parsed.data.active === false || parsed.data.pin !== undefined) {
      await client.query(
        `UPDATE sesiones SET estado = 'CERRADA', fecha_cierre = now()
          WHERE usuario_id = $1 AND estado = 'ACTIVA'`,
        [id.data],
      );
    }
    const permissions = await client.query(
      "SELECT modulo, permitido FROM permisos_usuario WHERE usuario_id = $1 ORDER BY modulo",
      [id.data],
    );
    await client.query("COMMIT");
    res.status(200).json({ user: { ...user, permissions: Object.fromEntries(permissions.rows.map((row) => [row.modulo, row.permitido])) } });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => undefined);
    next(error);
  } finally {
    client.release();
  }
});
