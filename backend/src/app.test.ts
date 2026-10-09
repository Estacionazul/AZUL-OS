import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { app } from "./app.js";

test("GET /health/live responds without accessing PostgreSQL", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/health/live`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: "ok", service: "azul-os-backend" });
});

test("unknown routes return a structured 404", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/route-that-does-not-exist`);
  assert.equal(response.status, 404);
  assert.deepEqual(await response.json(), {
    error: { code: "NOT_FOUND", message: "Ruta no encontrada." },
  });
});
