import { createHash, randomBytes, scrypt as scryptCallback, timingSafeEqual } from "node:crypto";
import { promisify } from "node:util";

const scrypt = promisify(scryptCallback);
const KEY_LENGTH = 64;

export function createSessionToken(): string {
  return randomBytes(32).toString("base64url");
}

export function hashSessionToken(token: string): string {
  return createHash("sha256").update(token, "utf8").digest("hex");
}

export async function hashPin(pin: string): Promise<string> {
  if (!/^\d{4}$/.test(pin)) throw new Error("PIN must contain exactly four digits");
  const salt = randomBytes(16).toString("hex");
  const derived = (await scrypt(pin, salt, KEY_LENGTH)) as Buffer;
  return `scrypt$${salt}$${derived.toString("hex")}`;
}

export async function verifyPin(pin: string, stored: string): Promise<boolean> {
  if (!/^\d{4}$/.test(pin)) return false;
  const parts = stored.split("$");
  if (parts.length !== 3 || parts[0] !== "scrypt" || !/^[a-f0-9]{32}$/.test(parts[1] ?? "") || !/^[a-f0-9]{128}$/.test(parts[2] ?? "")) return false;
  const derived = (await scrypt(pin, parts[1]!, KEY_LENGTH)) as Buffer;
  const expected = Buffer.from(parts[2]!, "hex");
  return expected.length === derived.length && timingSafeEqual(expected, derived);
}
