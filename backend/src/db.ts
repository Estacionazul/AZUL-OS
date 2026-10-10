import pg from "pg";
import { config } from "./config.js";

export const pool = new pg.Pool({
  connectionString: config.DATABASE_URL,
  max: 10,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 5_000,
  application_name: "azul-os-backend",
});

pool.on("error", (error) => {
  console.error("Unexpected idle PostgreSQL client error", error);
});
