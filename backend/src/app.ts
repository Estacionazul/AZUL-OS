import express, { type ErrorRequestHandler } from "express";
import helmet from "helmet";
import { pool } from "./db.js";
import { authRouter } from "./auth.routes.js";

export const app = express();
app.disable("x-powered-by");
app.use(helmet());
app.use(express.json({ limit: "256kb" }));
app.use("/api/v1/auth", authRouter);

app.get("/health/live", (_req, res) => {
  res.status(200).json({ status: "ok", service: "azul-os-backend" });
});

app.get("/health/ready", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.status(200).json({ status: "ready", database: "connected" });
  } catch {
    res.status(503).json({ status: "not_ready", database: "unavailable" });
  }
});

app.use((_req, res) => {
  res.status(404).json({
    error: { code: "NOT_FOUND", message: "Ruta no encontrada." },
  });
});

const errorHandler: ErrorRequestHandler = (error, _req, res, _next) => {
  console.error("Unhandled API error", error);
  if (res.headersSent) return;
  res.status(500).json({
    error: { code: "INTERNAL_ERROR", message: "Error interno del servidor." },
  });
};
app.use(errorHandler);
