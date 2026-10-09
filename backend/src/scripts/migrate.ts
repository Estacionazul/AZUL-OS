import "dotenv/config";
import { readdir, readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { pool } from "../db.js";

const CONFIRMATION = "APPLY_AZUL_MIGRATIONS";
const LOCK_ID = 7319042026;

async function main(): Promise<void> {
  if (process.env.MIGRATIONS_CONFIRM !== CONFIRMATION) {
    throw new Error(`Migration stopped. Set MIGRATIONS_CONFIRM=${CONFIRMATION} explicitly after verifying DATABASE_URL.`);
  }

  const client = await pool.connect();
  let lockAcquired = false;
  try {
    await client.query("SELECT pg_advisory_lock($1)", [LOCK_ID]);
    lockAcquired = true;

    const markerExists = await client.query("SELECT to_regclass('public.schema_migrations') AS table_name");
    if (!markerExists.rows[0]?.table_name) {
      const existingTables = await client.query(
        "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') AS present",
      );
      if (existingTables.rows[0]?.present) {
        throw new Error("Migration stopped: database is not empty and has no schema_migrations table. Review it manually; this runner will not adopt an unknown schema.");
      }
      await client.query(`CREATE TABLE schema_migrations (
        version text PRIMARY KEY,
        applied_at timestamptz NOT NULL DEFAULT now()
      )`);
    }

    const migrationsDirectory = resolve(process.cwd(), "migrations");
    const files = (await readdir(migrationsDirectory))
      .filter((file) => /^\d+_[a-z0-9_-]+\.sql$/.test(file))
      .sort();

    if (files.length === 0) {
      throw new Error(`No versioned SQL migrations found in ${migrationsDirectory}`);
    }

    for (const file of files) {
      const alreadyApplied = await client.query(
        "SELECT 1 FROM schema_migrations WHERE version = $1",
        [file],
      );
      if (alreadyApplied.rowCount) {
        console.info(`Skipping applied migration ${file}`);
        continue;
      }

      const sql = await readFile(resolve(migrationsDirectory, file), "utf8");
      console.info(`Applying ${file}`);
      await client.query("BEGIN");
      try {
        await client.query(sql);
        await client.query("INSERT INTO schema_migrations (version) VALUES ($1)", [file]);
        await client.query("COMMIT");
      } catch (error) {
        await client.query("ROLLBACK");
        throw error;
      }
      console.info(`Applied ${file}`);
    }
  } finally {
    if (lockAcquired) {
      await client.query("SELECT pg_advisory_unlock($1)", [LOCK_ID]).catch(() => undefined);
    }
    client.release();
    await pool.end();
  }
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : "Migration failed.");
  process.exitCode = 1;
});
