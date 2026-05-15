import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import type { SampleAsset, SampleDb } from "../../../infrastructure/dataset-state/memory-dataset-db.ts";
import { buildSelectedAssetPayload } from "./asset-payload.ts";
export { MemoryDatasetDb } from "../../../infrastructure/dataset-state/memory-dataset-db.ts";
export { buildSelectedAssetPayload } from "./asset-payload.ts";

export type { SampleAsset, SampleDb } from "../../../infrastructure/dataset-state/memory-dataset-db.ts";

export async function importSampleDataset(db: SampleDb, datasetUrl?: URL) {
  const resolvedDatasetUrl = datasetUrl ?? await resolveDefaultSampleDatasetUrl();
  const child = JSON.parse(await fs.readFile(new URL("child.json", resolvedDatasetUrl), "utf8"));
  const metadata = JSON.parse(await fs.readFile(new URL("metadata/assets.json", resolvedDatasetUrl), "utf8"));
  const datasetPath = fileURLToPath(resolvedDatasetUrl);
  await db.upsertChild(child);
  const metadataAssets = (metadata.assets as SampleAsset[]) || [];
  const rasterAssets = await loadRasterAssets(datasetPath);
  const allAssets = [...metadataAssets, ...rasterAssets];
  for (const asset of allAssets) {
    await db.upsertAsset({ ...resolveLocalAssetPaths(asset, datasetPath), childId: child.id });
  }
  return { ok: true, childId: child.id, assetCount: allAssets.length };
}

async function resolveDefaultSampleDatasetUrl() {
  const candidates = [
    new URL("../../../../examples/sample-dataset/", import.meta.url),
    new URL("../../../../../../examples/sample-dataset/", import.meta.url),
  ];
  for (const candidate of candidates) {
    try {
      await fs.access(new URL("child.json", candidate));
      return candidate;
    } catch {
      // Try the next layout: bundled sidecar first, source checkout second.
    }
  }
  return candidates[0];
}

export async function listAssets(db: SampleDb, filter: { type?: string; childId?: string } = {}) {
  return db.getAssets(filter);
}

function resolveLocalAssetPaths(asset: SampleAsset, datasetPath: string): SampleAsset {
  return {
    ...asset,
    imagePath: resolveIfLocalFile(asset.imagePath, datasetPath),
    thumbnailPath: resolveIfLocalFile(asset.thumbnailPath, datasetPath),
  };
}

function resolveIfLocalFile(value: string, datasetPath: string) {
  if (!value || value.includes("://") || path.isAbsolute(value)) return value;
  return path.resolve(datasetPath, value);
}

async function loadRasterAssets(datasetPath: string): Promise<SampleAsset[]> {
  const rasterDir = path.join(datasetPath, "assets", "raster");
  try {
    const dirEntries = await fs.readdir(rasterDir, { withFileTypes: true });
    const rasterFiles = dirEntries
      .filter((entry) => entry.isFile())
      .map((entry) => entry.name)
      .filter((name) => /\.(png|jpg|jpeg|webp|gif|bmp|avif)$/i.test(name))
      .sort();
    return rasterFiles.map((filename) => {
      const stem = path.parse(filename).name;
      return {
        id: `asset-raster-${stem}`,
        type: "photo",
        title: stem,
        tags: [stem],
        description: `${stem} 的示例照片素材。`,
        imagePath: `assets/raster/${filename}`,
        thumbnailPath: `assets/raster/${filename}`,
        sourceUrl: "self-created-cc0",
        license: "CC0-1.0",
        capturedAt: new Date().toISOString().slice(0, 10),
      };
    });
  } catch {
    return [];
  }
}
