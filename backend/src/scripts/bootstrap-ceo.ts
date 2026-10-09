import "dotenv/config";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";
import { pool } from "../db.js";

function required(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`Missing required environment variable: ${name}`);
  return value;
}

async function main(): Promise<void> {
  const establishmentName = required("BOOTSTRAP_ESTABLISHMENT_NAME");
  const username = required("BOOTSTRAP_USERNAME");
  const ceoName = required("BOOTSTRAP_CEO_NAME");
  const pin = required("BOOTSTRAP_PIN");
  const deviceName = required("BOOTSTRAP_DEVICE_NAME");
  const platform = required("BOOTSTRAP_DEVICE_PLATFORM");

  if (!/^\d{4}$/.test(pin)) {
    throw new Error("BOOTSTRAP_PIN must be exactly four digits");
  }
  if (username.length > 80 || ceoName.length > 120 || establishmentName.length > 160) {
    throw new Error("Bootstrap names exceed the supported length");
  }
  if (!["windows", "android", "ios", "tablet", "other"].includes(platform.toLowerCase())) {
    throw new Error("BOOTSTRAP_DEVICE_PLATFORM must be windows, android, ios, tablet, or other");
  }

  const pinHash = await bcrypt.hash(pin, 12);
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query("SELECT pg_advisory_xact_lock(hashtext('azul-os-bootstrap'))");
    const existing = await client.query("SELECT 1 FROM establecimientos LIMIT 1");
    if (existing.rowCount) {
      throw new Error("Bootstrap refused: an establishment already exists. This command is only for an empty database.");
    }

    const establishmentId = randomUUID();
    const deviceId = randomUUID();
    const userId = randomUUID();

    await client.query(
      "INSERT INTO establecimientos (id, nombre) VALUES ($1, $2)",
      [establishmentId, establishmentName],
    );
    await client.query(
      "INSERT INTO dispositivos (id, establecimiento_id, nombre, plataforma) VALUES ($1, $2, $3, $4)",
      [deviceId, establishmentId, deviceName, platform.toLowerCase()],
    );
    await client.query(
      `INSERT INTO usuarios (id, establecimiento_id, usuario, nombre, pin_hash, rol)
       VALUES ($1, $2, $3, $4, $5, 'CEO')`,
      [userId, establishmentId, username, ceoName, pinHash],
    );
    await client.query("COMMIT");
    console.info("Initial CEO created successfully.");
    console.info(`Establishment ID: ${establishmentId}`);
    console.info(`CEO user ID: ${userId}`);
    console.info(`Registered device ID: ${deviceId}`);
    console.info("Keep these IDs safe. The PIN is not printed.");
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : "Bootstrap failed");
  process.exitCode = 1;
});
