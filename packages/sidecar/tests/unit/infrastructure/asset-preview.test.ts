import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { StreamableFile } from "@nestjs/common";

import { DatasetController } from "../../../src/modules/dataset/dataset.controller.ts";

test("asset preview endpoint serves the thumbnail when available", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-preview-"));
  const imagePath = path.join(root, "photo.jpg");
  const thumbnailPath = path.join(root, "thumb.png");
  await fs.writeFile(imagePath, "image");
  await fs.writeFile(thumbnailPath, "thumb");

  const controller = new DatasetController({
    getAsset: async () => ({
      asset: {
        imagePath,
        thumbnailPath,
      },
    }),
  } as any);

  const headers: Record<string, string> = {};
  const response = {
    setHeader(name: string, value: string) {
      headers[name] = value;
    },
  } as any;

  const result = await controller.getAssetPreview("asset-1", response);

  assert.ok(result instanceof StreamableFile);
  assert.equal(headers["Content-Type"], "image/png");
  assert.equal(headers["Cache-Control"], "no-cache");
});
