import test from "node:test";
import assert from "node:assert/strict";
import { hashPin, verifyPin, createSessionToken, hashSessionToken } from "./security.js";

test("PIN hashes verify without storing the PIN itself", async () => {
  const hash = await hashPin("4826");
  assert.notEqual(hash, "4826");
  assert.equal(await verifyPin("4826", hash), true);
  assert.equal(await verifyPin("0000", hash), false);
});

test("PIN validation requires exactly four digits", async () => {
  await assert.rejects(() => hashPin("123"));
  await assert.rejects(() => hashPin("12a4"));
});

test("session tokens can be stored as one-way hashes", () => {
  const token = createSessionToken();
  assert.ok(token.length >= 40);
  assert.notEqual(hashSessionToken(token), token);
  assert.equal(hashSessionToken(token), hashSessionToken(token));
});
