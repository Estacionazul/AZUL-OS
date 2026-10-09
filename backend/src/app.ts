import express, { type ErrorRequestHandler } from "express";
import helmet from "helmet";
import { pool } from "./db.js";
import { config } from "./config.js";
import { authRouter } from "./auth.routes.js";
import { catalogRouter } from "./catalog.routes.js";
import { inventoryRouter } from "./inventory.routes.js";

export const app = express();
app.disable("x-powered-by");
app.use(helmet());

app.use((req, res, next) => {
  const origin = req.header("origin");
  res.vary("Origin");

  if (origin && !config.corsOrigins.includes(origin)) {
    if (req.method === "OPTIONS") {
      res.status(403).end();
    } else {
      res.status(403).json({
        error: { code: "ORIGIN_NOT_ALLOWED", message: "Origen no autorizado." },
      });
    }
    return;
  }

  if (origin) {
    res.setHeader("Access-Control-Allow-Origin", origin);
    res.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type, Idempotency-Key");
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
  }

  if (req.method === "OPTIONS") {
    res.status(204).end();
    return;
  }
  next();
});

app.use(express.json({ limit: "256kb" }));
app.use("/api/v1/auth", authRouter);
app.use("/api/v1/catalog", catalogRouter);
app.use("/api/v1/inventory", inventoryRouter);

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
