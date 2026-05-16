import { Inject, Injectable } from "@nestjs/common";
import { Tool } from "@rekog/mcp-nest";
import { z } from "zod";

import { DatasetService } from "../../dataset/dataset.service.ts";

const listRecentAssetsSchema = z.object({
  childId: z.string().optional(),
  limit: z.number().int().positive().max(200).optional(),
});

const searchAssetsSchema = z.object({
  childId: z.string(),
  query: z.string(),
  page: z.number().int().positive().optional(),
  pageSize: z.number().int().positive().max(200).optional(),
  types: z.array(z.string()).optional(),
  tags: z.array(z.string()).optional(),
  capturedFrom: z.string().optional(),
  capturedTo: z.string().optional(),
});

const getAssetSchema = z.object({
  assetId: z.string(),
});

const updateAssetMetadataSchema = z.object({
  assetId: z.string(),
  title: z.string().optional(),
  description: z.string().optional(),
  tags: z.array(z.string()).optional(),
  capturedAt: z.string().optional(),
  type: z.string().optional(),
});

const childProfileSchema = z.object({
  childId: z.string(),
});

@Injectable()
export class AssetMcpTools {
  constructor(@Inject(DatasetService) private readonly datasetService: DatasetService) {}

  @Tool({
    name: "list_children",
    description: "List all children currently available in dataset.",
    parameters: z.object({}),
  })
  async listChildren() {
    return toJson(await this.datasetService.listChildren());
  }

  @Tool({
    name: "get_child_profile",
    description: "Get child profile by childId.",
    parameters: childProfileSchema,
  })
  async getChildProfile({ childId }: z.infer<typeof childProfileSchema>) {
    return toJson(await this.datasetService.getChild(childId));
  }

  @Tool({
    name: "list_recent_assets",
    description: "List assets by child scope with an optional limit.",
    parameters: listRecentAssetsSchema,
  })
  async listRecentAssets({ childId, limit }: z.infer<typeof listRecentAssetsSchema>) {
    const result = await this.datasetService.listAssets(undefined, childId);
    const assets = Array.isArray(result.assets) ? result.assets.slice(0, limit ?? 20) : [];
    return toJson({ assets });
  }

  @Tool({
    name: "search_assets",
    description: "Search assets using dataset semantic/text search pipeline.",
    parameters: searchAssetsSchema,
  })
  async searchAssets(input: z.infer<typeof searchAssetsSchema>) {
    return toJson(
      await this.datasetService.searchAssets({
        childId: input.childId,
        query: input.query,
        page: input.page,
        pageSize: input.pageSize,
        filters: {
          types: input.types,
          tags: input.tags,
          capturedFrom: input.capturedFrom,
          capturedTo: input.capturedTo,
        },
      }),
    );
  }

  @Tool({
    name: "search_assets_by_vector",
    description: "Search assets by vector-like prompt using the same domain search service.",
    parameters: searchAssetsSchema,
  })
  async searchAssetsByVector(input: z.infer<typeof searchAssetsSchema>) {
    return toJson(
      await this.datasetService.searchAssets({
        childId: input.childId,
        query: input.query,
        page: input.page,
        pageSize: input.pageSize,
        filters: {
          types: input.types,
          tags: input.tags,
          capturedFrom: input.capturedFrom,
          capturedTo: input.capturedTo,
        },
      }),
    );
  }

  @Tool({
    name: "get_asset_metadata",
    description: "Get full metadata for an asset.",
    parameters: getAssetSchema,
  })
  async getAssetMetadata({ assetId }: z.infer<typeof getAssetSchema>) {
    return toJson(await this.datasetService.getAsset(assetId));
  }

  @Tool({
    name: "get_asset_preview",
    description: "Get preview URL path for an asset.",
    parameters: getAssetSchema,
  })
  async getAssetPreview({ assetId }: z.infer<typeof getAssetSchema>) {
    return toJson({ assetId, previewPath: `/assets/${assetId}/preview` });
  }

  @Tool({
    name: "update_asset_metadata",
    description: "Update mutable metadata for an asset.",
    parameters: updateAssetMetadataSchema,
  })
  async updateAssetMetadata({ assetId, ...updates }: z.infer<typeof updateAssetMetadataSchema>) {
    return toJson(await this.datasetService.updateAsset(assetId, updates));
  }
}

function toJson(value: unknown) {
  return JSON.stringify(value);
}
