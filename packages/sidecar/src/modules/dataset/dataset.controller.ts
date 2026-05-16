import fs from "node:fs";
import path from "node:path";

import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Inject,
  NotFoundException,
  Param,
  Post,
  Query,
  Res,
  StreamableFile,
} from "@nestjs/common";
import type { Response } from "express";

import { parseDto } from "../../infrastructure/validation/parse-dto.ts";
import { DatasetService } from "./dataset.service.ts";
import { ImportAssetsDtoSchema, type ImportAssetsDto } from "./dto/import-assets.dto.ts";
import { ImportSampleDtoSchema, type ImportSampleDto } from "./dto/import-sample.dto.ts";
import { RunSearchIndexerDtoSchema, type RunSearchIndexerDto } from "./dto/run-search-indexer.dto.ts";
import { SearchAssetsDtoSchema, type SearchAssetsDto } from "./dto/search-assets.dto.ts";
import {
  SearchCandidatePoolItemsDtoSchema,
  type SearchCandidatePoolItemsDto,
} from "./dto/search-candidate-pool-items.dto.ts";
import { UpdateAssetDtoSchema, type UpdateAssetDto } from "./dto/update-asset.dto.ts";

@Controller()
export class DatasetController {
  constructor(@Inject(DatasetService) private readonly datasetService: DatasetService) {}

  @Post("sample/import")
  importSample(@Body() body: unknown) {
    const dto = parseDto<ImportSampleDto>(ImportSampleDtoSchema, body, "sample/import");
    return this.datasetService.importSample(dto.persist === true);
  }

  @Post("children")
  createChild(@Body() body: { id?: string; name?: string }) {
    return this.datasetService.createChild(body);
  }

  @Post("assets/import")
  importAssets(@Body() body: unknown) {
    const dto = parseDto<ImportAssetsDto>(ImportAssetsDtoSchema, body, "assets/import");
    return this.datasetService.importAssets(dto);
  }

  @Get("children")
  listChildren() { return this.datasetService.listChildren(); }

  @Get("children/:id")
  getChild(@Param("id") id: string) { return this.datasetService.getChild(id); }

  @Get("assets")
  listAssets(@Query("type") type?: string, @Query("childId") childId?: string) {
    return this.datasetService.listAssets(type, childId);
  }

  @Get("assets/:id")
  getAsset(@Param("id") id: string) { return this.datasetService.getAsset(id); }

  @Get("assets/:id/preview")
  async getAssetPreview(@Param("id") id: string, @Res({ passthrough: true }) response: Response) {
    const { asset } = await this.datasetService.getAsset(id);
    const previewPath = resolvePreviewPath(asset);
    if (!previewPath) throw new NotFoundException("Asset preview not found.");
    const resolvedPath = path.resolve(previewPath);
    if (!fs.existsSync(resolvedPath)) throw new NotFoundException("Asset preview file missing.");
    response.setHeader("Content-Type", contentTypeForPath(resolvedPath));
    response.setHeader("Cache-Control", "no-cache");
    return new StreamableFile(fs.createReadStream(resolvedPath));
  }

  @Post("assets/:id/update")
  updateAsset(@Param("id") id: string, @Body() body: unknown) {
    const dto = parseDto<UpdateAssetDto>(UpdateAssetDtoSchema, body, "assets/:id/update");
    return this.datasetService.updateAsset(id, dto);
  }

  @Delete("assets/:id")
  deleteAsset(@Param("id") id: string) { return this.datasetService.deleteAsset(id); }

  @Post("search/query")
  searchAssets(@Body() body: unknown) {
    const dto = parseDto<SearchAssetsDto>(SearchAssetsDtoSchema, body, "search/query");
    return this.datasetService.searchAssets(dto);
  }

  @Get("search/candidate-pool")
  listSearchCandidatePool(@Query("childId") childId: string) {
    return this.datasetService.listSearchCandidatePool(childId);
  }

  @Post("search/candidate-pool/items")
  addSearchCandidatePoolItems(@Body() body: unknown) {
    const dto = parseDto<SearchCandidatePoolItemsDto>(
      SearchCandidatePoolItemsDtoSchema,
      body,
      "search/candidate-pool/items",
    );
    return this.datasetService.addSearchCandidatePoolItems(dto);
  }

  @Delete("search/candidate-pool/items")
  removeSearchCandidatePoolItems(@Body() body: unknown) {
    const dto = parseDto<SearchCandidatePoolItemsDto>(
      SearchCandidatePoolItemsDtoSchema,
      body,
      "search/candidate-pool/items",
    );
    return this.datasetService.removeSearchCandidatePoolItems(dto);
  }

  @Post("search/candidate-pool/items/remove")
  removeSearchCandidatePoolItemsPost(@Body() body: unknown) {
    const dto = parseDto<SearchCandidatePoolItemsDto>(
      SearchCandidatePoolItemsDtoSchema,
      body,
      "search/candidate-pool/items/remove",
    );
    return this.datasetService.removeSearchCandidatePoolItems(dto);
  }

  @Get("search/indexing-status")
  getSearchIndexingStatus(@Query("childId") childId?: string) {
    return this.datasetService.getSearchIndexingStatus(childId);
  }

  @Post("storage/assets/:id/sync")
  syncAssetToStorage(@Param("id") id: string) {
    return this.datasetService.enqueueAssetStorageSync(id);
  }

  @Post("storage/export-artifacts/:id/sync")
  syncExportArtifactToStorage(@Param("id") id: string, @Body() body: { childId?: string }) {
    return this.datasetService.enqueueExportArtifactStorageSync({
      artifactId: id,
      childId: String(body?.childId || "").trim(),
    });
  }

  @Post("storage/sync/run")
  runStorageSync(@Body() body: { limit?: number; now?: string } = {}) {
    const now = body.now ? new Date(body.now) : undefined;
    return this.datasetService.runStorageSyncWorker({
      limit: body.limit,
      now: Number.isNaN(now?.getTime()) ? undefined : now,
    });
  }

  @Get("storage/export-artifacts/:id/share")
  getExportArtifactShareMetadata(@Param("id") id: string) {
    return this.datasetService.getExportArtifactShareMetadata(id);
  }

  @Post("search/indexing/run")
  runSearchIndexer(@Body() body: unknown = {}) {
    const dto = parseDto<RunSearchIndexerDto>(RunSearchIndexerDtoSchema, body, "search/indexing/run");
    const now = dto.now ? new Date(dto.now) : undefined;
    return this.datasetService.runSearchIndexer({
      limit: dto.limit,
      now: Number.isNaN(now?.getTime()) ? undefined : now,
    });
  }

  @Post("sample/reset")
  resetSample(@Body() body: { childId?: string }) {
    if (!body?.childId || !String(body.childId).trim()) {
      throw new BadRequestException("sample reset requires childId");
    }
    return this.datasetService.resetSampleAssets(body.childId);
  }
}


function resolvePreviewPath(asset: { thumbnailPath?: string; imagePath?: string } | null) {
  if (!asset) return "";
  const thumbnailPath = typeof asset.thumbnailPath === "string" ? asset.thumbnailPath.trim() : "";
  if (thumbnailPath) return thumbnailPath;
  const imagePath = typeof asset.imagePath === "string" ? asset.imagePath.trim() : "";
  return imagePath;
}

function contentTypeForPath(filePath: string) {
  switch (path.extname(filePath).toLowerCase()) {
    case ".jpg":
    case ".jpeg":
      return "image/jpeg";
    case ".png":
      return "image/png";
    case ".webp":
      return "image/webp";
    case ".gif":
      return "image/gif";
    case ".bmp":
      return "image/bmp";
    case ".avif":
      return "image/avif";
    default:
      return "application/octet-stream";
  }
}
