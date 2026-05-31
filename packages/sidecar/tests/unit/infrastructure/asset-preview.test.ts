import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { StreamableFile } from "@nestjs/common";
import type { Response } from "express";

import { DatasetController } from "../../../src/modules/dataset/dataset.controller.ts";
import type { DatasetService } from "../../../src/modules/dataset/dataset.service.ts";

test("asset preview endpoint serves the thumbnail when available", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-preview-"));
  const imagePath = path.join(root, "photo.jpg");
  const thumbnailPath = path.join(root, "thumb.png");
  await fs.writeFile(imagePath, "image");
  await fs.writeFile(thumbnailPath, "thumb");

  const datasetService = {
    getAsset: async () => ({
      asset: {
        imagePath,
        thumbnailPath,
      },
    }),
  } as Pick<DatasetService, "getAsset">;
  const controller = new DatasetController(datasetService as DatasetService);

  const headers: Record<string, string> = {};
  const response = {
    setHeader(name: string, value: number | string | readonly string[]) {
      headers[name] = Array.isArray(value) ? value.join(", ") : String(value);
      return response as Response;
    },
  } satisfies Partial<Response>;

  const result = await controller.getAssetPreview("asset-1", response as Response);

  assert.ok(result instanceof StreamableFile);
  assert.equal(headers["Content-Type"], "image/png");
  assert.equal(headers["Cache-Control"], "no-cache");
});
