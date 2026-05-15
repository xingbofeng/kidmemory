import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { loadValidatedBookOutput } from "../../src/modules/books/providers/book-output.ts";

test("loads paired book.json and book.html for export after validation", async () => {
  const workspace = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-book-output-"));
  const output = path.join(workspace, "output");
  await fs.mkdir(output);
  const html = "<html><body><h1>Preview source</h1></body></html>";
  await fs.writeFile(path.join(output, "book.json"), JSON.stringify({
    metadata: { title: "阳光的一天", childName: "澄澄" },
    pages: [
      { kind: "cover", title: "阳光的一天", text: "封面" },
      { kind: "artwork", title: "太阳下的小房子", text: "内容", assetId: "asset-sun-house" },
      { kind: "closing", title: "尾声", text: "结束" },
    ],
  }));
  await fs.writeFile(path.join(output, "book.html"), html);

  const result = await loadValidatedBookOutput(workspace, new Set(["asset-sun-house"]));

  assert.equal(result.ok, true);
  assert.equal(result.html, html);
});

test("rejects invalid paired book output before export", async () => {
  const workspace = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-book-output-invalid-"));
  const output = path.join(workspace, "output");
  await fs.mkdir(output);
  await fs.writeFile(path.join(output, "book.json"), JSON.stringify({ metadata: { title: "bad" }, pages: [] }));
  await fs.writeFile(path.join(output, "book.html"), "<html></html>");

  const result = await loadValidatedBookOutput(workspace, new Set(["asset-sun-house"]));

  assert.equal(result.ok, false);
  assert.match(result.errors.join("\n"), /cover/);
});
