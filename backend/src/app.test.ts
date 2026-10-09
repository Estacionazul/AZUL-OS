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

test("login rejects an invalid PIN before touching the database", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/v1/auth/login`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      establishmentId: "00000000-0000-4000-8000-000000000001",
      username: "cajero",
      pin: "12",
      deviceId: "00000000-0000-4000-8000-000000000002",
    }),
  });
  assert.equal(response.status, 400);
  assert.deepEqual(await response.json(), {
    error: { code: "VALIDATION_ERROR", message: "Datos de inicio de sesión inválidos." },
  });
});

test("protected profile route rejects missing bearer token", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/v1/auth/me`);
  assert.equal(response.status, 401);
  assert.deepEqual(await response.json(), {
    error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." },
  });
});
