import test from "node:test";
import assert from "node:assert/strict";
import { once } from "node:events";

process.env.NODE_ENV ??= "test";
process.env.DATABASE_URL ??= "postgres://test:test@127.0.0.1:5432/test";
process.env.JWT_SECRET ??= "x".repeat(40);

test("inventory movements enforce idempotency, non-negative stock and recipe restrictions", { skip: process.env.CI !== "true" }, async (t) => {
  const [{ app }, { pool }, bcryptModule] = await Promise.all([
    import("./app.js"),
    import("./db.js"),
    import("bcryptjs"),
  ]);
  const establishment = await pool.query(
    "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
    ["CI inventory integration"],
  );
  const establishmentId = establishment.rows[0].id as string;
  let foreignEstablishmentId: string | undefined;
  let foreignCategoryId: string | undefined;
  let foreignProductId: string | undefined;
  let deviceId: string | undefined;
  let userId: string | undefined;
  let categoryId: string | undefined;
  let productId: string | undefined;
  let recipeProductId: string | undefined;
  let server: ReturnType<typeof app.listen> | undefined;

  try {
    const device = await pool.query(
      "INSERT INTO dispositivos (establecimiento_id, nombre, plataforma) VALUES ($1, $2, $3) RETURNING id",
      [establishmentId, "CI integration device", "test"],
    );
    deviceId = device.rows[0].id as string;
    const user = await pool.query(
      `INSERT INTO usuarios (establecimiento_id, usuario, nombre, pin_hash, rol)
       VALUES ($1, $2, $3, $4, 'CEO') RETURNING id`,
      [establishmentId, "ci-inventory-ceo", "CI CEO", await bcryptModule.default.hash("4826", 4)],
    );
    userId = user.rows[0].id as string;
    const category = await pool.query(
      "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
      [establishmentId, `CI inventory ${establishmentId}`],
    );
    categoryId = category.rows[0].id as string;
    const product = await pool.query(
      `INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, tipo_inventario)
       VALUES ($1, $2, $3, $4, 'producto') RETURNING id`,
      [establishmentId, `CI-${establishmentId.slice(0, 8)}-P`, "CI Inventory Product", categoryId],
    );
    productId = product.rows[0].id as string;
    const recipe = await pool.query(
      `INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, tipo_inventario)
       VALUES ($1, $2, $3, $4, 'receta') RETURNING id`,
      [establishmentId, `CI-${establishmentId.slice(0, 8)}-R`, "CI Recipe Product", categoryId],
    );
    recipeProductId = recipe.rows[0].id as string;

    const foreignEstablishment = await pool.query(
      "INSERT INTO establecimientos (nombre) VALUES ($1) RETURNING id",
      ["CI foreign establishment"],
    );
    foreignEstablishmentId = foreignEstablishment.rows[0].id as string;
    const foreignCategory = await pool.query(
      "INSERT INTO categorias (establecimiento_id, nombre) VALUES ($1, $2) RETURNING id",
      [foreignEstablishmentId, "CI foreign category"],
    );
    foreignCategoryId = foreignCategory.rows[0].id as string;
    const foreignProduct = await pool.query(
      `INSERT INTO productos (establecimiento_id, codigo, nombre, categoria_id, tipo_inventario)
       VALUES ($1, $2, $3, $4, 'producto') RETURNING id`,
      [foreignEstablishmentId, `CI-${foreignEstablishmentId.slice(0, 8)}-X`, "CI Foreign Product", foreignCategoryId],
    );
    foreignProductId = foreignProduct.rows[0].id as string;
    await pool.query(
      "INSERT INTO movimientos_inventario (establecimiento_id, tipo, nombre_item, unidad, producto_id, cantidad, signo, idempotency_key) VALUES ($1, 'ENTRADA', 'CI Foreign Product', 'unid', $2, 7, 1, $3)",
      [foreignEstablishmentId, foreignProductId, "77777777-7777-4777-8777-777777777777"],
    );

    server = app.listen(0, "127.0.0.1");
    await once(server, "listening");
    const address = server.address();
    assert.ok(address && typeof address !== "string");
    const base = `http://127.0.0.1:${address.port}`;
    const login = await fetch(`${base}/api/v1/auth/login`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ establishmentId, username: "ci-inventory-ceo", pin: "4826", deviceId }),
    });
    assert.equal(login.status, 200);
    const { token } = await login.json() as { token: string };

    const sendMovement = (key: string, body: object) => fetch(`${base}/api/v1/inventory/movements`, {
      method: "POST",
      headers: {
        authorization: `Bearer ${token}`,
        "content-type": "application/json",
        "idempotency-key": key,
      },
      body: JSON.stringify(body),
    });
    const entryKey = "33333333-3333-4333-8333-333333333333";
    const entry = { itemType: "producto", itemId: productId, type: "ENTRADA", quantity: 10, note: "CI entry" };

    const created = await sendMovement(entryKey, entry);
    assert.equal(created.status, 201);
    const replay = await sendMovement(entryKey, entry);
    assert.equal(replay.status, 200);
    assert.equal((await replay.json() as { replayed: boolean }).replayed, true);

    const conflict = await sendMovement(entryKey, { ...entry, quantity: 11 });
    assert.equal(conflict.status, 409);
    assert.equal((await conflict.json() as { error: { code: string } }).error.code, "IDEMPOTENCY_CONFLICT");

    const shortage = await sendMovement("44444444-4444-4444-8444-444444444444", {
      itemType: "producto", itemId: productId, type: "SALIDA", quantity: 20,
    });
    assert.equal(shortage.status, 409);
    assert.equal((await shortage.json() as { error: { code: string } }).error.code, "STOCK_INSUFFICIENTE");

    const recipeMovement = await sendMovement("55555555-5555-4555-8555-555555555555", {
      itemType: "producto", itemId: recipeProductId, type: "ENTRADA", quantity: 1,
    });
    assert.equal(recipeMovement.status, 409);
    assert.equal((await recipeMovement.json() as { error: { code: string } }).error.code, "RECIPE_STOCK_CONTROLLED");

    const stock = await fetch(`${base}/api/v1/inventory/stock?itemType=producto&q=CI%20Inventory%20Product`, {
      headers: { authorization: `Bearer ${token}` },
    });
    assert.equal(stock.status, 200);
    const stockBody = await stock.json() as { items: Array<{ id: string; currentStock: string | number }> };
    const current = stockBody.items.find((item) => item.id === productId);
    assert.ok(current);
    assert.equal(Number(current.currentStock), 10);

    const allStock = await fetch(`${base}/api/v1/inventory/stock?itemType=producto`, {
      headers: { authorization: `Bearer ${token}` },
    });
    assert.equal(allStock.status, 200);
    const allStockBody = await allStock.json() as { items: Array<{ id: string }> };
    assert.equal(allStockBody.items.some((item) => item.id === foreignProductId), false);

    const movements = await fetch(`${base}/api/v1/inventory/movements?itemType=producto`, {
      headers: { authorization: `Bearer ${token}` },
    });
    assert.equal(movements.status, 200);
    const movementsBody = await movements.json() as { items: Array<{ productId: string }> };
    assert.equal(movementsBody.items.some((movement) => movement.productId === foreignProductId), false);

    const foreignMovement = await sendMovement("66666666-6666-4666-8666-666666666666", {
      itemType: "producto", itemId: foreignProductId, type: "ENTRADA", quantity: 1,
    });
    assert.equal(foreignMovement.status, 404);
    assert.equal((await foreignMovement.json() as { error: { code: string } }).error.code, "ITEM_NOT_FOUND");
  } finally {
    if (server) await new Promise<void>((resolve) => server!.close(() => resolve()));
    if (productId) await pool.query("DELETE FROM movimientos_inventario WHERE producto_id = $1", [productId]);
    if (foreignProductId) await pool.query("DELETE FROM movimientos_inventario WHERE producto_id = $1", [foreignProductId]);
    if (recipeProductId) await pool.query("DELETE FROM movimientos_inventario WHERE producto_id = $1", [recipeProductId]);
    if (userId) await pool.query("DELETE FROM sesiones WHERE usuario_id = $1", [userId]);
    if (productId) await pool.query("DELETE FROM productos WHERE id = $1", [productId]);
    if (recipeProductId) await pool.query("DELETE FROM productos WHERE id = $1", [recipeProductId]);
    if (foreignProductId) await pool.query("DELETE FROM productos WHERE id = $1", [foreignProductId]);
    if (categoryId) await pool.query("DELETE FROM categorias WHERE id = $1", [categoryId]);
    if (foreignCategoryId) await pool.query("DELETE FROM categorias WHERE id = $1", [foreignCategoryId]);
    if (userId) await pool.query("DELETE FROM usuarios WHERE id = $1", [userId]);
    if (deviceId) await pool.query("DELETE FROM dispositivos WHERE id = $1", [deviceId]);
    if (foreignEstablishmentId) await pool.query("DELETE FROM establecimientos WHERE id = $1", [foreignEstablishmentId]);
    await pool.query("DELETE FROM establecimientos WHERE id = $1", [establishmentId]);
  }
});
