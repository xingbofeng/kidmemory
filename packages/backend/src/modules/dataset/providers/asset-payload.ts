import type { SampleDb } from "../../../infrastructure/dataset-state/memory-dataset-db.ts";

export async function buildSelectedAssetPayload(db: SampleDb, ids: string[]) {
  const assets = await db.getAssetsByIds(ids);
  return {
    selectedAssetIds: assets.map((asset) => asset.id),
    assets,
  };
}
