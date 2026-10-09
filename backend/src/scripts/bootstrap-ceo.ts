import "dotenv/config";
import bcrypt from "bcryptjs";
import { pool } from "../db.js";

const required = [
  "BOOTSTRAP_ESTABLISHMENT_NAME",
  "BOOTSTRAP_USERNAME",
  "BOOTSTRAP_CEO_NAME",
  "BOOTSTRAP_PIN",
  "BOOTSTRAP_DEVICE_NAME",
  "BOOTSTRAP_DEVICE_PLATFORM",
] as const;

function readInput(): Record<(typeof required)[number], string> {
  const values = {} as Record<(typeof required)[number], string>;
  for (const key of required) {
    const value = process.env[key]?.trim();
    if (!value || value.startsWith("REPLACE_WITH_") || value.toLowerCase() === "change_me") {
      throw new Error(`Missing or placeholder bootstrap variable: ${key}`);
    }
    values[key] = value;
  }
  if (!/^\d{4}$/.test(values.BOOTSTRAP_PIN)) {
    throw new Error("BOOTSTRAP_PIN must contain exactly four digits.");
  }
  if (["0000", "1111", "1234", "4321"].includes(values.BOOTSTRAP_PIN)) {
    throw new Error("Choose a non-obvious four-digit CEO PIN.");
  }
  if (values.BOOTSTRAP_USERNAME.length > 80) {
    throw new Error("BOOTSTRAP_USERNAME must be 80 characters or fewer.");
  }
  return values;
}

async function main(): Promise<void> {
  const input = readInput();
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query("SELECT pg_advisory_xact_lock(847263901)");
    const existing = await client.query("SELECT EXISTS (SELECT 1 FROM establecimientos) AS exists");
    if (existing.rows[0]?.exists) {
      throw new Error("Bootstrap refused: this database already has an establishment. Use the controlled admin process instead.");
    }

    const establishment = await client.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [input.BOOTSTRAP_ESTABLISHMENT_NAME],
    );
    const establishmentId = establishment.rows[0].id as string;
    const pinHash = await bcrypt.hash(input.BOOTSTRAP_PIN, 12);
    const user = await client.query(
      `INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol)
       VALUES ($1, $2, $3, $4, 'CEO') RETURNING id`,
      [establishmentId, input.BOOTSTRAP_USERNAME, input.BOOTSTRAP_CEO_NAME, pinHash],
    );
    const device = await client.query(
      `INSERT INTO dispositivos (establecimiento_id, nombre, plataforma)
       VALUES ($1, $2, $3) RETURNING id`,
      [establishmentId, input.BOOTSTRAP_DEVICE_NAME, input.BOOTSTRAP_DEVICE_PLATFORM],
    );
    await client.query("COMMIT");
    console.info("Bootstrap completed. Store these IDs securely for client configuration:");
    console.info(JSON.stringify({
      establishmentId,
      userId: user.rows[0].id,
      deviceId: device.rows[0].id,
    }, null, 2));
    console.info("The PIN is not printed or stored in plaintext. Remove bootstrap variables from the environment now.");
  } catch (error) {
    await client.query("ROLLBACK").catch(() => undefined);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((error: unknown) => {
  console.error("Bootstrap failed:", error instanceof Error ? error.message : "unknown error");
  process.exitCode = 1;
});
