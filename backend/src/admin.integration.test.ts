import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);
const { app } = await import("./app.js");

test("CEO can register devices and cashier users; non-CEO cannot access administration", { skip: process.env.CI !== "true" }, async (t) => {
  const { pool } = await import("./db.js");
  const suffix = randomUUID();
  let establishmentId: string | undefined;
  let ceoId: string | undefined;
  let cashierId: string | undefined;
  let deviceId: string | undefined;
  let createdDeviceId: string | undefined;
  let createdUserId: string | undefined;
  let createdCategoryId: string | undefined;
  let createdProductId: string | undefined;
  let createdInsumoId: string | undefined;
  let createdRecipeId: string | undefined;
  let createdCustomerId: string | undefined;
  let server: ReturnType<typeof app.listen> | undefined;

  try {
    const establishment = await pool.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      [`CI admin establishment ${suffix}`],
    );
    establishmentId = establishment.rows[0].id as string;
    const ceo = await pool.query(
      `INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol)
       VALUES ($1, $2, 'CI CEO', $3, 'CEO') RETURNING id`,
      [establishmentId, `ci-ceo-${suffix}`, await bcrypt.hash("6842", 4)],
    );
    ceoId = ceo.rows[0].id as string;
    const cashier = await pool.query(
      `INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol)
       VALUES ($1, $2, 'CI Cashier', $3, 'CAJERO') RETURNING id`,
      [establishmentId, `ci-cashier-${suffix}`, await bcrypt.hash("5739", 4)],
    );
    cashierId = cashier.rows[0].id as string;
    await pool.query(
      "INSERT INTO permisos_usuario (usuario_id, modulo, permitido) VALUES ($1, 'Caja', true)",
      [cashierId],
    );
    const device = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, 'windows') RETURNING id",
      [establishmentId, `CI admin device ${suffix}`],
    );
    deviceId = device.rows[0].id as string;

    server = app.listen(0, "127.0.0.1");
    await once(server, "listening");
    const address = server.address();
    assert.ok(address && typeof address !== "string");
    const baseUrl = `http://127.0.0.1:${address.port}`;

    async function token(username: string, pin: string): Promise<string> {
      const response = await fetch(`${baseUrl}/api/v1/auth/login`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ establishmentId, username, pin, deviceId }),
      });
      assert.equal(response.status, 200);
      return (await response.json() as { token: string }).token;
    }

    const cashierToken = await token(`ci-cashier-${suffix}`, "5739");
    const forbidden = await fetch(`${baseUrl}/api/v1/admin/devices`, {
      headers: { authorization: `Bearer ${cashierToken}` },
    });
    assert.equal(forbidden.status, 403);
    assert.equal((await forbidden.json() as { error: { code: string } }).error.code, "CEO_REQUIRED");

    const ceoToken = await token(`ci-ceo-${suffix}`, "6842");
    const selfDisable = await fetch(`${baseUrl}/api/v1/admin/devices/${deviceId}`, {
      method: "PATCH",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({ active: false }),
    });
    assert.equal(selfDisable.status, 409);
    assert.equal((await selfDisable.json() as { error: { code: string } }).error.code, "CURRENT_DEVICE_DEACTIVATION_BLOCKED");

    const category = await fetch(`${baseUrl}/api/v1/admin/catalog/categories`, {
      method: "POST",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({ name: `CI category ${suffix}`, icon: "📦", sortOrder: 5 }),
    });
    assert.equal(category.status, 201);
    createdCategoryId = (await category.json() as { category: { id: string } }).category.id;

    const product = await fetch(`${baseUrl}/api/v1/admin/catalog/products`, {
      method: "POST",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({
        code: `CI-P-${suffix}`, name: "CI Test Product", categoryId: createdCategoryId,
        salePrice: 8.5, cost: 2.25, minimumStock: 0, inventoryType: "producto",
      }),
    });
    assert.equal(product.status, 201);
    createdProductId = (await product.json() as { product: { id: string } }).product.id;

    const insumo = await fetch(`${baseUrl}/api/v1/admin/catalog/insumos`, {
      method: "POST",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({
        code: `CI-I-${suffix}`, name: "CI Test Ingredient", categoryId: createdCategoryId, unit: "unid",
      }),
    });
    assert.equal(insumo.status, 201);
    createdInsumoId = (await insumo.json() as { insumo: { id: string } }).insumo.id;

    const recipe = await fetch(`${baseUrl}/api/v1/admin/catalog/recipes`, {
      method: "POST",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({
        productId: createdProductId, name: "CI Test Recipe",
        ingredients: [{ insumoId: createdInsumoId, quantity: 1.5, unit: "unid" }],
      }),
    });
    assert.equal(recipe.status, 201);
    createdRecipeId = (await recipe.json() as { recipe: { id: string } }).recipe.id;

    const recipeUpdate = await fetch(`${baseUrl}/api/v1/admin/catalog/recipes/${createdRecipeId}`, {
      method: "PATCH",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({
        name: "CI Updated Recipe",
        ingredients: [{ insumoId: createdInsumoId, quantity: 2, unit: "unid" }],
      }),
    });
    assert.equal(recipeUpdate.status, 200);
    const recipeBody = await recipeUpdate.json() as { recipe: { name: string; ingredients: { quantity: number }[] } };
    assert.equal(recipeBody.recipe.name, "CI Updated Recipe");
    const updatedIngredient = recipeBody.recipe.ingredients[0];
    assert.ok(updatedIngredient);
    assert.equal(Number(updatedIngredient.quantity), 2);

    const customerDni = suffix.replace(/\D/g, "").slice(0, 8).padEnd(8, "7");
    const customer = await fetch(`${baseUrl}/api/v1/customers`, {
      method: "POST",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({ name: "CI Test Customer", dni: customerDni, phone: "999111222" }),
    });
    assert.equal(customer.status, 201);
    createdCustomerId = (await customer.json() as { customer: { id: string } }).customer.id;

    const customerUpdate = await fetch(`${baseUrl}/api/v1/customers/${createdCustomerId}`, {
      method: "PATCH",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({ name: "CI Updated Customer" }),
    });
    assert.equal(customerUpdate.status, 200);
    assert.equal((await customerUpdate.json() as { customer: { name: string } }).customer.name, "CI Updated Customer");

    const productUpdate = await fetch(`${baseUrl}/api/v1/admin/catalog/products/${createdProductId}`, {
      method: "PATCH",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({ active: false }),
    });
    assert.equal(productUpdate.status, 200);
    assert.equal((await productUpdate.json() as { product: { active: boolean } }).product.active, false);

    const createdDevice = await fetch(`${baseUrl}/api/v1/admin/devices`, {
      method: "POST",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({ name: `CI Android ${suffix}`, platform: "android" }),
    });
    assert.equal(createdDevice.status, 201);
    const createdBody = await createdDevice.json() as { device: { id: string; platform: string } };
    createdDeviceId = createdBody.device.id;
    assert.equal(createdBody.device.platform, "android");

    const createdUser = await fetch(`${baseUrl}/api/v1/admin/users`, {
      method: "POST",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({ username: `ci-new-${suffix}`, name: "New Cashier", pin: "8274", permissions: ["Caja", "Ventas"] }),
    });
    assert.equal(createdUser.status, 201);
    const userBody = await createdUser.json() as { user: { id: string; role: string; permissions: Record<string, boolean> } };
    createdUserId = userBody.user.id;
    assert.equal(userBody.user.role, "CAJERO");
    assert.equal(userBody.user.permissions.Caja, true);
    assert.equal(userBody.user.permissions.Productos, false);

    const disabled = await fetch(`${baseUrl}/api/v1/admin/devices/${createdDeviceId}`, {
      method: "PATCH",
      headers: { authorization: `Bearer ${ceoToken}`, "content-type": "application/json" },
      body: JSON.stringify({ active: false }),
    });
    assert.equal(disabled.status, 200);
    assert.equal((await disabled.json() as { device: { active: boolean } }).device.active, false);
  } finally {
    if (server) await new Promise<void>((resolve) => server!.close(() => resolve()));
    if (createdCustomerId) await pool.query("DELETE FROM clientes WHERE id = $1", [createdCustomerId]);
    if (createdRecipeId) await pool.query("DELETE FROM recetas WHERE id = $1", [createdRecipeId]);
    if (createdProductId) await pool.query("DELETE FROM productos WHERE id = $1", [createdProductId]);
    if (createdInsumoId) await pool.query("DELETE FROM insumos WHERE id = $1", [createdInsumoId]);
    if (createdCategoryId) await pool.query("DELETE FROM categorias WHERE id = $1", [createdCategoryId]);
    if (createdUserId) await pool.query("DELETE FROM sesiones WHERE usuario_id = $1", [createdUserId]);
    if (createdUserId) await pool.query("DELETE FROM permisos_usuario WHERE usuario_id = $1", [createdUserId]);
    if (createdUserId) await pool.query("DELETE FROM usuarios WHERE id = $1", [createdUserId]);
    if (createdDeviceId) await pool.query("DELETE FROM dispositivos WHERE id = $1", [createdDeviceId]);
    if (cashierId) await pool.query("DELETE FROM sesiones WHERE usuario_id = $1", [cashierId]);
    if (ceoId) await pool.query("DELETE FROM sesiones WHERE usuario_id = $1", [ceoId]);
    if (cashierId) await pool.query("DELETE FROM permisos_usuario WHERE usuario_id = $1", [cashierId]);
    if (cashierId) await pool.query("DELETE FROM usuarios WHERE id = $1", [cashierId]);
    if (ceoId) await pool.query("DELETE FROM usuarios WHERE id = $1", [ceoId]);
    if (deviceId) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceId]);
    if (establishmentId) await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentId]);
  }
});
