import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { exportHtmlToLongImage } from "../../../../src/modules/books/providers/long-image.ts";

test("exports HTML to PNG through an injected renderer", async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-long-image-png-"));
  const outputPath = path.join(dir, "book.png");

  const result = await exportHtmlToLongImage({
    html: "<html><body>book</body></html>",
    targetPath: outputPath,
    format: "png",
    renderer: {
      render: async ({ targetPath }) => {
        await fs.writeFile(targetPath, Buffer.from([0x89, 0x50, 0x4e, 0x47]));
      },
    },
  });

  const bytes = await fs.readFile(outputPath);
  assert.equal(result.ok, true);
  assert.equal(result.path, outputPath);
  assert.equal(bytes.subarray(0, 4).toString("hex"), "89504e47");
});

test("exports HTML to JPG through an injected renderer", async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-long-image-jpg-"));
  const outputPath = path.join(dir, "book.jpg");

  const result = await exportHtmlToLongImage({
    html: "<html><body>book</body></html>",
    targetPath: outputPath,
    format: "jpg",
    renderer: {
      render: async ({ targetPath }) => {
        await fs.writeFile(targetPath, Buffer.from([0xff, 0xd8, 0xff, 0xd9]));
      },
    },
  });

  const bytes = await fs.readFile(outputPath);
  assert.equal(result.ok, true);
  assert.equal(bytes.subarray(0, 2).toString("hex"), "ffd8");
});

test("long image export failures are actionable and remove invalid output", async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-long-image-fail-"));
  const outputPath = path.join(dir, "book.png");

  const result = await exportHtmlToLongImage({
    html: "<html><body>book</body></html>",
    targetPath: outputPath,
    format: "png",
    renderer: {
      render: async ({ targetPath }) => {
        await fs.writeFile(targetPath, "");
        throw new Error("canvas too tall");
      },
    },
  });

  await assert.rejects(() => fs.stat(outputPath));
  assert.equal(result.ok, false);
  assert.equal(result.retryable, true);
  assert.match(result.action, /retry|重新导出/i);
});
