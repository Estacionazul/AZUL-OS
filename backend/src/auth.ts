import { createHash, randomUUID } from "node:crypto";
import type { NextFunction, Request, Response } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { pool } from "./db.js";

const SESSION_HOURS = 12;
const MAX_FAILED_ATTEMPTS = 5;
const LOCK_MINUTES = 15;
const JWT_ISSUER = "azul-os-backend";
const JWT_AUDIENCE = "azul-os-clients";

function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

function jwtSecret(): string {
  const value = process.env.JWT_SECRET;
  if (!value || value.length < 32) {
    throw new Error("JWT_SECRET must contain at least 32 characters");
  }
  return value;
}

export type AuthenticatedUser = {
  userId: string;
  establishmentId: string;
  sessionId: string;
  role: string;
};

declare global {
  namespace Express {
    interface Request {
      auth?: AuthenticatedUser;
    }
  }
}

export async function login(input: {
  establishmentId: string;
  username: string;
  pin: string;
  deviceId: string;
}) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const found = await client.query(
      `SELECT id, establecimiento_id, usuario, nombre, pin_hash, rol, activo,
              intentos_fallidos, bloqueado_hasta
         FROM usuarios
        WHERE establecimiento_id = $1 AND lower(usuario) = lower($2)
        FOR UPDATE`,
      [input.establishmentId, input.username],
    );
    const user = found.rows[0];
    if (!user || !user.activo) {
      await client.query("ROLLBACK");
      return null;
    }
    if (user.bloqueado_hasta && new Date(user.bloqueado_hasta).getTime() > Date.now()) {
      await client.query("ROLLBACK");
      return null;
    }
    const validPin = await bcrypt.compare(input.pin, user.pin_hash);
    if (!validPin) {
      const attempts = Number(user.intentos_fallidos) + 1;
      await client.query(
        `UPDATE usuarios
            SET intentos_fallidos = $2,
                bloqueado_hasta = CASE WHEN $2 >= $3 THEN now() + ($4 * interval '1 minute') ELSE NULL END,
                updated_at = now()
          WHERE id = $1`,
        [user.id, attempts, MAX_FAILED_ATTEMPTS, LOCK_MINUTES],
      );
      await client.query("COMMIT");
      return null;
    }
    const device = await client.query(
      "SELECT id FROM dispositivos WHERE id = $1 AND establecimiento_id = $2 AND activo = true",
      [input.deviceId, input.establishmentId],
    );
    if (!device.rowCount) {
      await client.query("ROLLBACK");
      return null;
    }

    await client.query(
      "UPDATE usuarios SET intentos_fallidos = 0, bloqueado_hasta = NULL, updated_at = now() WHERE id = $1",
      [user.id],
    );
    const sessionId = randomUUID();
    const token = jwt.sign(
      { sub: user.id, sid: sessionId, eid: user.establecimiento_id, role: user.rol },
      jwtSecret(),
      { expiresIn: SESSION_HOURS * 60 * 60, issuer: JWT_ISSUER, audience: JWT_AUDIENCE },
    );
    const expiry = new Date(Date.now() + SESSION_HOURS * 60 * 60 * 1000);
    await client.query(
      `INSERT INTO sesiones (id, usuario_id, dispositivo_id, token_hash, expira_en)
       VALUES ($1, $2, $3, $4, $5)`,
      [sessionId, user.id, input.deviceId, sha256(token), expiry],
    );
    await client.query("COMMIT");
    return {
      token,
      expiresAt: expiry.toISOString(),
      user: {
        id: user.id,
        username: user.usuario,
        name: user.nombre,
        role: user.rol,
      },
    };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export async function authenticate(req: Request, res: Response, next: NextFunction) {
  const header = req.header("authorization");
  if (!header?.startsWith("Bearer ")) {
    res.status(401).json({ error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." } });
    return;
  }
  const token = header.slice(7).trim();
  if (!token) {
    res.status(401).json({ error: { code: "UNAUTHENTICATED", message: "Token inválido." } });
    return;
  }

  let decoded: jwt.JwtPayload;
  try {
    const verified = jwt.verify(token, jwtSecret(), {
      issuer: JWT_ISSUER,
      audience: JWT_AUDIENCE,
    });
    if (typeof verified === "string" || !verified.sub || typeof verified.sid !== "string" || typeof verified.eid !== "string") {
      res.status(401).json({ error: { code: "UNAUTHENTICATED", message: "Token inválido." } });
      return;
    }
    decoded = verified;
  } catch {
    res.status(401).json({ error: { code: "UNAUTHENTICATED", message: "Token inválido o vencido." } });
    return;
  }

  try {
    const result = await pool.query(
      `SELECT s.id AS session_id, u.id AS user_id, u.establecimiento_id, u.rol
         FROM sesiones s
         JOIN usuarios u ON u.id = s.usuario_id
        WHERE s.id = $1 AND s.usuario_id = $2
          AND s.token_hash = $3 AND s.estado = 'ACTIVA'
          AND s.fecha_cierre IS NULL AND s.expira_en > now()
          AND u.activo = true AND u.establecimiento_id = $4`,
      [decoded.sid, decoded.sub, sha256(token), decoded.eid],
    );
    const row = result.rows[0];
    if (!row) {
      res.status(401).json({ error: { code: "SESSION_REVOKED", message: "La sesión venció o fue cerrada. Inicia sesión nuevamente." } });
      return;
    }
    req.auth = {
      userId: row.user_id,
      establishmentId: row.establecimiento_id,
      sessionId: row.session_id,
      role: row.rol,
    };
    void pool.query("UPDATE sesiones SET fecha_ultimo_acceso = now() WHERE id = $1", [row.session_id]).catch(() => undefined);
    next();
  } catch (error) {
    next(error);
  }
}

export async function requirePermission(moduleName: string, req: Request, res: Response, next: NextFunction) {
  if (!req.auth) {
    res.status(401).json({ error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." } });
    return;
  }
  if (req.auth.role === "CEO") {
    next();
    return;
  }
  try {
    const result = await pool.query(
      `SELECT 1 FROM permisos_usuario
        WHERE usuario_id = $1 AND modulo = $2 AND permitido = true`,
      [req.auth.userId, moduleName],
    );
    if (!result.rowCount) {
      res.status(403).json({ error: { code: "FORBIDDEN", message: "No tienes permiso para este módulo." } });
      return;
    }
    next();
  } catch (error) {
    next(error);
  }
}

export async function logout(req: Request): Promise<void> {
  if (!req.auth) return;
  await pool.query(
    `UPDATE sesiones SET estado = 'CERRADA', fecha_cierre = now()
      WHERE id = $1 AND usuario_id = $2 AND estado = 'ACTIVA'`,
    [req.auth.sessionId, req.auth.userId],
  );
}
