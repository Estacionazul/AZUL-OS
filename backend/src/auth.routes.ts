import { Router } from "express";
import { z } from "zod";
import { authenticate, login, logout } from "./auth.js";

export const authRouter = Router();

const LoginSchema = z.object({
  establishmentId: z.string().uuid(),
  username: z.string().trim().min(1).max(80),
  pin: z.string().regex(/^\d{4}$/, "El PIN debe tener exactamente 4 dígitos."),
  deviceId: z.string().uuid(),
});

authRouter.post("/login", async (req, res, next) => {
  const parsed = LoginSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({
      error: { code: "VALIDATION_ERROR", message: "Datos de inicio de sesión inválidos." },
    });
    return;
  }
  try {
    const result = await login(parsed.data);
    if (!result) {
      res.status(401).json({
        error: { code: "LOGIN_FAILED", message: "Credenciales incorrectas, usuario bloqueado o dispositivo no autorizado." },
      });
      return;
    }
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
});

authRouter.post("/logout", authenticate, async (req, res, next) => {
  try {
    await logout(req);
    res.status(204).end();
  } catch (error) {
    next(error);
  }
});

authRouter.get("/me", authenticate, (req, res) => {
  res.status(200).json({ userId: req.auth!.userId, establishmentId: req.auth!.establishmentId, role: req.auth!.role });
});
