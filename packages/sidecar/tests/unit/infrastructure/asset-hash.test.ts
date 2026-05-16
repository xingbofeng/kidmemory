import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { sha256File } from "../../../src/modules/dataset/providers/asset-import.ts";

test("sha256File is stable for same content", async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-hash-"));
  const file = path.join(dir, "a.jpg");
  await fs.writeFile(file, "same-content");

  const h1 = await sha256File(file);
  const h2 = await sha256File(file);
  assert.equal(h1, h2);
});
