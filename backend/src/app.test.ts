import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

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
  const response = await fetch(`http://127.0.0.1:${address.port}/api/v1/auth/login`, {
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
  const response = await fetch(`http://127.0.0.1:${address.port}/api/v1/auth/me`);
  assert.equal(response.status, 401);
  assert.deepEqual(await response.json(), {
    error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." },
  });
});

test("login rejects a PIN that is not exactly four digits", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/api/v1/auth/login`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      establishmentId: "11111111-1111-4111-8111-111111111111",
      username: "cajero",
      pin: "123",
      deviceId: "22222222-2222-4222-8222-222222222222",
    }),
  });
  assert.equal(response.status, 400);
  assert.deepEqual(await response.json(), {
    error: { code: "VALIDATION_ERROR", message: "Datos de inicio de sesión inválidos." },
  });
});

test("CORS allows only configured browser origins", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");

  const allowed = await fetch(`http://127.0.0.1:${address.port}/health/live`, {
    headers: { origin: "http://localhost:3000" },
  });
  assert.equal(allowed.headers.get("access-control-allow-origin"), "http://localhost:3000");

  const blocked = await fetch(`http://127.0.0.1:${address.port}/health/live`, {
    headers: { origin: "https://untrusted.example" },
  });
  assert.equal(blocked.headers.get("access-control-allow-origin"), null);
});

test("CORS rejects preflight requests from unlisted origins", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/api/v1/auth/login`, {
    method: "OPTIONS",
    headers: {
      origin: "https://untrusted.example",
      "access-control-request-method": "POST",
    },
  });
  assert.equal(response.status, 403);
});


test("catalog endpoints reject requests without a session", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  for (const path of ["/api/v1/catalog/products", "/api/v1/catalog/insumos", "/api/v1/catalog/recipes"]) {
    const response: globalThis.Response = await fetch(`http://127.0.0.1:${address.port}${path}`);
    assert.equal(response.status, 401, `${path} should require authentication`);
  }
});

test("catalog routes reject requests without a bearer token", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/api/v1/catalog/products`);
  assert.equal(response.status, 401);
  assert.deepEqual(await response.json(), {
    error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." },
  });
});

test("catalog endpoints require authentication before querying data", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/api/v1/catalog/products`);
  assert.equal(response.status, 401);
  assert.deepEqual(await response.json(), {
    error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." },
  });
});

test("inventory endpoints reject requests without a session", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/api/v1/inventory/stock`);
  assert.equal(response.status, 401);
  assert.deepEqual(await response.json(), {
    error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." },
  });
});

test("inventory stock and movement endpoints require authentication", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  for (const [path, method] of [
    ["/api/v1/inventory/stock", "GET"],
    ["/api/v1/inventory/movements", "GET"],
    ["/api/v1/inventory/movements", "POST"],
  ] as const) {
    const response: globalThis.Response = await fetch(`http://127.0.0.1:${address.port}${path}`, {
      method,
      ...(method === "POST" ? { headers: { "content-type": "application/json" }, body: "{}" } : {}),
    });
    assert.equal(response.status, 401, `${method} ${path} must require authentication`);
  }
});


test("readiness confirms PostgreSQL connectivity in CI", { skip: process.env.CI !== "true" }, async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/health/ready`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: "ready", database: "connected" });
});

test("configured CORS origin is allowed", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/health/live`, {
    headers: { origin: "http://localhost:3000" },
  });
  assert.equal(response.status, 200);
  assert.equal(response.headers.get("access-control-allow-origin"), "http://localhost:3000");
});

test("unconfigured CORS origin is rejected", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/health/live`, {
    headers: { origin: "https://not-approved.example" },
  });
  assert.equal(response.status, 403);
  assert.deepEqual(await response.json(), {
    error: { code: "ORIGIN_NOT_ALLOWED", message: "Origen no autorizado." },
  });
});

test("CORS allows configured origin", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/health/live`, {
    headers: { origin: "http://localhost:3000" },
  });
  assert.equal(response.headers.get("access-control-allow-origin"), "http://localhost:3000");
});

test("CORS preflight rejects unconfigured origin", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response = await fetch(`http://127.0.0.1:${address.port}/v1/auth/login`, {
    method: "OPTIONS",
    headers: { origin: "https://untrusted.example", "access-control-request-method": "POST" },
  });
  assert.equal(response.status, 403);
});


test("cash register endpoints require authentication", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  for (const [path, method] of [
    ["/api/v1/cash/current", "GET"],
    ["/api/v1/cash/open", "POST"],
    ["/api/v1/cash/close", "POST"],
  ] as const) {
    const response: globalThis.Response = await fetch(`http://127.0.0.1:${address.port}${path}`, {
      method,
      ...(method === "POST" ? { headers: { "content-type": "application/json" }, body: "{}" } : {}),
    });
    assert.equal(response.status, 401, `${method} ${path} must require authentication`);
    assert.deepEqual(await response.json(), {
      error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." },
    });
  }
});


test("sales endpoint requires authentication", async (t) => {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => server.close());
  const address = server.address();
  assert.ok(address && typeof address !== "string");
  const response: globalThis.Response = await fetch(`http://127.0.0.1:${address.port}/api/v1/sales`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ items: [] }),
  });
  assert.equal(response.status, 401);
  assert.deepEqual(await response.json(), {
    error: { code: "UNAUTHENTICATED", message: "Inicia sesión para continuar." },
  });
});
