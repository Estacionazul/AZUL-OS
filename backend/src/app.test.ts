import test from "node:test";
import assert from "node:assert/strict";

test("backend configuration requires DATABASE_URL", async () => {
  const { spawnSync } = await import("node:child_process");
  const result = spawnSync(process.execPath, ["--input-type=module", "-e",
    "process.env.DATABASE_URL=''; import('./dist/config.js')"
  ], { encoding: "utf8" });
  assert.notEqual(result.status, 0);
});
