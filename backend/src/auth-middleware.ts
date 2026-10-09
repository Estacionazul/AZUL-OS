import { createHash } from "node:crypto";
import type { NextFunction, Request, Response } from "express";
import { pool } from "./db.js";
export interface AuthContext {
  sessionId: string; userId: string; username: string; name: string; role: string;
  establishmentId: string; deviceId: string;
}
export type AuthenticatedRequest = Request & { auth: AuthContext };
export async function requireAuth(req: Request, res: Response, next: NextFunction): Promise<void> {
  const match = req.header("authorization")?.match(/^Bearer ([A-Za-z0-9_-]{40,})$/);
  if (!match) {
    res.status(401).json({ error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." } });
    return;
  }
  const hash = createHash("sha256").update(match[1], "utf8").digest("hex");
  try {
    const result = await pool.query<{
      session_id: string; user_id: string; usuario: string; nombre: string; rol: string;
      establecimiento_id: string; dispositivo_id: string;
    }>(
      `SELECT s.id AS session_id, u.id AS user_id, u.usuario, u.nombre, u.rol,
              u.establecimiento_id, d.id AS dispositivo_id
         FROM sesiones s JOIN usuarios u ON u.id = s.usuario_id
         JOIN dispositivos d ON d.id = s.dispositivo_id
        WHERE s.token_hash = $1 AND s.estado = 'ACTIVA' AND s.expira_en > now()
          AND s.fecha_cierre IS NULL AND u.activo = true AND d.activo = true
          AND d.establecimiento_id = u.establecimiento_id`,
      [hash],
    );
    const row = result.rows[0];
    if (!row) {
      res.status(401).json({ error: { code: "SESSION_INVALID", message: "La sesión expiró o fue revocada." } });
      return;
    }
    await pool.query("UPDATE sesiones SET fecha_ultimo_acceso = now() WHERE id = $1", [row.session_id]);
    (req as AuthenticatedRequest).auth = {
      sessionId: row.session_id, userId: row.user_id, username: row.usuario, name: row.nombre,
      role: row.rol, establishmentId: row.establecimiento_id, deviceId: row.dispositivo_id,
    };
    next();
  } catch (error) { next(error); }
}
export function requirePermission(moduleName: string) {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const auth = (req as Partial<AuthenticatedRequest>).auth;
    if (!auth) {
      res.status(401).json({ error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." } });
      return;
    }
    if (auth.role === "CEO") { next(); return; }
    try {
      const result = await pool.query(
        "SELECT 1 FROM permisos_usuario WHERE usuario_id = $1 AND modulo = $2 AND permitido = true",
        [auth.userId, moduleName],
      );
      if (result.rowCount !== 1) {
        res.status(403).json({ error: { code: "FORBIDDEN", message: "No tienes permiso para este módulo." } });
        return;
      }
      next();
    } catch (error) { next(error); }
  };
}
