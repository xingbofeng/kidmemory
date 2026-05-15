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

export class DatasetController {
  private readonly datasetService: DatasetService;

  constructor(datasetService: DatasetService) {
    this.datasetService = datasetService;
  }

  importSample(body: unknown) {
    const dto = parseDto<ImportSampleDto>(ImportSampleDtoSchema, body, "sample/import");
    return this.datasetService.importSample(dto.persist === true);
  }
  createChild(body: { id?: string; name?: string }) { return this.datasetService.createChild(body); }
  importAssets(body: unknown) {
    const dto = parseDto<ImportAssetsDto>(ImportAssetsDtoSchema, body, "assets/import");
    return this.datasetService.importAssets(dto);
  }
  listChildren() { return this.datasetService.listChildren(); }
  getChild(id: string) { return this.datasetService.getChild(id); }
  listAssets(type?: string, childId?: string) { return this.datasetService.listAssets(type, childId); }
  getAsset(id: string) { return this.datasetService.getAsset(id); }
  async getAssetPreview(id: string, response: Response) {
    const { asset } = await this.datasetService.getAsset(id);
    const previewPath = resolvePreviewPath(asset);
    if (!previewPath) throw new NotFoundException("Asset preview not found.");
    const resolvedPath = path.resolve(previewPath);
    if (!fs.existsSync(resolvedPath)) throw new NotFoundException("Asset preview file missing.");
    response.setHeader("Content-Type", contentTypeForPath(resolvedPath));
    response.setHeader("Cache-Control", "no-cache");
    return new StreamableFile(fs.createReadStream(resolvedPath));
  }
  updateAsset(id: string, body: unknown) {
    const dto = parseDto<UpdateAssetDto>(UpdateAssetDtoSchema, body, "assets/:id/update");
    return this.datasetService.updateAsset(id, dto);
  }
  deleteAsset(id: string) { return this.datasetService.deleteAsset(id); }
  searchAssets(body: unknown) {
    const dto = parseDto<SearchAssetsDto>(SearchAssetsDtoSchema, body, "search/query");
    return this.datasetService.searchAssets(dto);
  }
  listSearchCandidatePool(childId: string) { return this.datasetService.listSearchCandidatePool(childId); }
  addSearchCandidatePoolItems(body: unknown) {
    const dto = parseDto<SearchCandidatePoolItemsDto>(
      SearchCandidatePoolItemsDtoSchema,
      body,
      "search/candidate-pool/items",
    );
    return this.datasetService.addSearchCandidatePoolItems(dto);
  }
  removeSearchCandidatePoolItems(body: unknown) {
    const dto = parseDto<SearchCandidatePoolItemsDto>(
      SearchCandidatePoolItemsDtoSchema,
      body,
      "search/candidate-pool/items",
    );
    return this.datasetService.removeSearchCandidatePoolItems(dto);
  }
  removeSearchCandidatePoolItemsPost(body: unknown) {
    const dto = parseDto<SearchCandidatePoolItemsDto>(
      SearchCandidatePoolItemsDtoSchema,
      body,
      "search/candidate-pool/items/remove",
    );
    return this.datasetService.removeSearchCandidatePoolItems(dto);
  }
  getSearchIndexingStatus(childId?: string) { return this.datasetService.getSearchIndexingStatus(childId); }
  syncAssetToStorage(id: string) { return this.datasetService.enqueueAssetStorageSync(id); }
  syncExportArtifactToStorage(id: string, body: { childId?: string }) {
    return this.datasetService.enqueueExportArtifactStorageSync({
      artifactId: id,
      childId: String(body?.childId || "").trim(),
    });
  }
  runStorageSync(body: { limit?: number; now?: string } = {}) {
    const now = body.now ? new Date(body.now) : undefined;
    return this.datasetService.runStorageSyncWorker({ limit: body.limit, now: Number.isNaN(now?.getTime()) ? undefined : now });
  }
  getExportArtifactShareMetadata(id: string) {
    return this.datasetService.getExportArtifactShareMetadata(id);
  }
  runSearchIndexer(body: unknown = {}) {
    const dto = parseDto<RunSearchIndexerDto>(RunSearchIndexerDtoSchema, body, "search/indexing/run");
    const now = dto.now ? new Date(dto.now) : undefined;
    return this.datasetService.runSearchIndexer({
      limit: dto.limit,
      now: Number.isNaN(now?.getTime()) ? undefined : now,
    });
  }
  resetSample(body: { childId?: string }) {
    if (!body?.childId || !String(body.childId).trim()) {
      throw new BadRequestException("sample reset requires childId");
    }
    return this.datasetService.resetSampleAssets(body.childId);
  }
}

Inject(DatasetService)(DatasetController, undefined, 0);
Controller()(DatasetController);
Post("sample/import")(DatasetController.prototype, "importSample", Object.getOwnPropertyDescriptor(DatasetController.prototype, "importSample")!);
Body()(DatasetController.prototype, "importSample", 0);
Post("children")(DatasetController.prototype, "createChild", Object.getOwnPropertyDescriptor(DatasetController.prototype, "createChild")!);
Body()(DatasetController.prototype, "createChild", 0);
Post("assets/import")(DatasetController.prototype, "importAssets", Object.getOwnPropertyDescriptor(DatasetController.prototype, "importAssets")!);
Body()(DatasetController.prototype, "importAssets", 0);
Get("children")(DatasetController.prototype, "listChildren", Object.getOwnPropertyDescriptor(DatasetController.prototype, "listChildren")!);
Get("children/:id")(DatasetController.prototype, "getChild", Object.getOwnPropertyDescriptor(DatasetController.prototype, "getChild")!);
Param("id")(DatasetController.prototype, "getChild", 0);
Get("assets")(DatasetController.prototype, "listAssets", Object.getOwnPropertyDescriptor(DatasetController.prototype, "listAssets")!);
Query("type")(DatasetController.prototype, "listAssets", 0);
Query("childId")(DatasetController.prototype, "listAssets", 1);
Get("assets/:id")(DatasetController.prototype, "getAsset", Object.getOwnPropertyDescriptor(DatasetController.prototype, "getAsset")!);
Param("id")(DatasetController.prototype, "getAsset", 0);
Get("assets/:id/preview")(DatasetController.prototype, "getAssetPreview", Object.getOwnPropertyDescriptor(DatasetController.prototype, "getAssetPreview")!);
Param("id")(DatasetController.prototype, "getAssetPreview", 0);
Res({ passthrough: true })(DatasetController.prototype, "getAssetPreview", 1);
Post("assets/:id/update")(DatasetController.prototype, "updateAsset", Object.getOwnPropertyDescriptor(DatasetController.prototype, "updateAsset")!);
Param("id")(DatasetController.prototype, "updateAsset", 0);
Body()(DatasetController.prototype, "updateAsset", 1);
Delete("assets/:id")(DatasetController.prototype, "deleteAsset", Object.getOwnPropertyDescriptor(DatasetController.prototype, "deleteAsset")!);
Param("id")(DatasetController.prototype, "deleteAsset", 0);
Post("search/query")(DatasetController.prototype, "searchAssets", Object.getOwnPropertyDescriptor(DatasetController.prototype, "searchAssets")!);
Body()(DatasetController.prototype, "searchAssets", 0);
Get("search/candidate-pool")(DatasetController.prototype, "listSearchCandidatePool", Object.getOwnPropertyDescriptor(DatasetController.prototype, "listSearchCandidatePool")!);
Query("childId")(DatasetController.prototype, "listSearchCandidatePool", 0);
Post("search/candidate-pool/items")(DatasetController.prototype, "addSearchCandidatePoolItems", Object.getOwnPropertyDescriptor(DatasetController.prototype, "addSearchCandidatePoolItems")!);
Body()(DatasetController.prototype, "addSearchCandidatePoolItems", 0);
Delete("search/candidate-pool/items")(DatasetController.prototype, "removeSearchCandidatePoolItems", Object.getOwnPropertyDescriptor(DatasetController.prototype, "removeSearchCandidatePoolItems")!);
Body()(DatasetController.prototype, "removeSearchCandidatePoolItems", 0);
Post("search/candidate-pool/items/remove")(DatasetController.prototype, "removeSearchCandidatePoolItemsPost", Object.getOwnPropertyDescriptor(DatasetController.prototype, "removeSearchCandidatePoolItemsPost")!);
Body()(DatasetController.prototype, "removeSearchCandidatePoolItemsPost", 0);
Get("search/indexing-status")(DatasetController.prototype, "getSearchIndexingStatus", Object.getOwnPropertyDescriptor(DatasetController.prototype, "getSearchIndexingStatus")!);
Query("childId")(DatasetController.prototype, "getSearchIndexingStatus", 0);
Post("storage/assets/:id/sync")(DatasetController.prototype, "syncAssetToStorage", Object.getOwnPropertyDescriptor(DatasetController.prototype, "syncAssetToStorage")!);
Param("id")(DatasetController.prototype, "syncAssetToStorage", 0);
Post("storage/export-artifacts/:id/sync")(DatasetController.prototype, "syncExportArtifactToStorage", Object.getOwnPropertyDescriptor(DatasetController.prototype, "syncExportArtifactToStorage")!);
Param("id")(DatasetController.prototype, "syncExportArtifactToStorage", 0);
Body()(DatasetController.prototype, "syncExportArtifactToStorage", 1);
Post("storage/sync/run")(DatasetController.prototype, "runStorageSync", Object.getOwnPropertyDescriptor(DatasetController.prototype, "runStorageSync")!);
Body()(DatasetController.prototype, "runStorageSync", 0);
Get("storage/export-artifacts/:id/share")(DatasetController.prototype, "getExportArtifactShareMetadata", Object.getOwnPropertyDescriptor(DatasetController.prototype, "getExportArtifactShareMetadata")!);
Param("id")(DatasetController.prototype, "getExportArtifactShareMetadata", 0);
Post("search/indexing/run")(DatasetController.prototype, "runSearchIndexer", Object.getOwnPropertyDescriptor(DatasetController.prototype, "runSearchIndexer")!);
Body()(DatasetController.prototype, "runSearchIndexer", 0);
Post("sample/reset")(DatasetController.prototype, "resetSample", Object.getOwnPropertyDescriptor(DatasetController.prototype, "resetSample")!);
Body()(DatasetController.prototype, "resetSample", 0);

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
