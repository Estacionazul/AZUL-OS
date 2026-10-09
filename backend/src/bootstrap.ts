import bcrypt from "bcryptjs";
import { z } from "zod";
import { pool } from "./db.js";

const BootstrapSchema = z.object({
  BOOTSTRAP_CONFIRM: z.literal("CREATE_INITIAL_CEO"),
  BOOTSTRAP_ESTABLISHMENT_NAME: z.string().trim().min(2).max(120),
  BOOTSTRAP_CEO_USERNAME: z.string().trim().min(3).max(80).regex(/^[a-zA-Z0-9._-]+$/),
  BOOTSTRAP_CEO_NAME: z.string().trim().min(2).max(120),
  BOOTSTRAP_CEO_PIN: z.string().regex(/^\d{4}$/),
  BOOTSTRAP_DEVICE_NAME: z.string().trim().min(2).max(120),
  BOOTSTRAP_DEVICE_PLATFORM: z.enum(["windows", "android", "ios", "web"]),
});

async function main(): Promise<void> {
  const parsed = BootstrapSchema.safeParse(process.env);
  if (!parsed.success) {
    throw new Error("Bootstrap detenido: confirma explícitamente la operación y configura todos los campos BOOTSTRAP_* válidos.");
  }
  const input = parsed.data;
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query("SELECT pg_advisory_xact_lock(7319042026)");
    const existing = await client.query(
      "SELECT EXISTS (SELECT 1 FROM establecimientos) AS has_establishments, EXISTS (SELECT 1 FROM usuarios) AS has_users",
    );
    if (existing.rows[0]?.has_establishments || existing.rows[0]?.has_users) {
      throw new Error("Bootstrap bloqueado: ya existe un establecimiento o usuario. No se modificó ningún dato.");
    }

    const establishment = await client.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [input.BOOTSTRAP_ESTABLISHMENT_NAME],
    );
    const establishmentId = establishment.rows[0].id as string;
    const device = await client.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, $3) RETURNING id",
      [establishmentId, input.BOOTSTRAP_DEVICE_NAME, input.BOOTSTRAP_DEVICE_PLATFORM],
    );
    const pinHash = await bcrypt.hash(input.BOOTSTRAP_CEO_PIN, 12);
    const user = await client.query(
      `INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol)
       VALUES ($1, $2, $3, $4, 'CEO') RETURNING id`,
      [establishmentId, input.BOOTSTRAP_CEO_USERNAME, input.BOOTSTRAP_CEO_NAME, pinHash],
    );
    await client.query("COMMIT");
    console.info("Bootstrap completado. Guarda estos identificadores en un gestor seguro:");
    console.info(JSON.stringify({
      establishmentId,
      userId: user.rows[0].id,
      deviceId: device.rows[0].id,
    }, null, 2));
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : "Bootstrap fallido.");
  process.exitCode = 1;
});
