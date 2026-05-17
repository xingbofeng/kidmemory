import fs from "node:fs";
import path from "node:path";

import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Inject,
  HttpException,
  NotFoundException,
  Param,
  Patch,
  Post,
  Query,
  Res,
  StreamableFile,
} from "@nestjs/common";
import type { Response } from "express";

import { parseDto } from "../../infrastructure/validation/parse-dto.ts";
import { DatasetService } from "./dataset.service.ts";
import { ImportAssetsDtoSchema } from "./dto/import-assets.dto.ts";
import { ImportSampleDtoSchema } from "./dto/import-sample.dto.ts";
import { DeleteAssetsBatchDtoSchema } from "./dto/delete-assets-batch.dto.ts";
import { CreateChildDtoSchema } from "./dto/create-child.dto.ts";
import { UpdateChildDtoSchema } from "./dto/update-child.dto.ts";
import { RunSearchIndexerDtoSchema } from "./dto/run-search-indexer.dto.ts";
import { SearchAssetsDtoSchema } from "./dto/search-assets.dto.ts";
import {
  SearchCandidatePoolItemsDtoSchema,
} from "./dto/search-candidate-pool-items.dto.ts";
import { UpdateAssetDtoSchema } from "./dto/update-asset.dto.ts";

@Controller()
export class DatasetController {
  constructor(@Inject(DatasetService) private readonly datasetService: DatasetService) {}

  @Post("sample/import")
  importSample(@Body() body: unknown) {
    const dto = parseDto(ImportSampleDtoSchema, body, "sample/import");
    return this.datasetService.importSample(dto.persist === true);
  }

  @Post("children")
  createChild(@Body() body: unknown) {
    const dto = parseDto(CreateChildDtoSchema, body, "children");
    return this.datasetService.createChild(dto);
  }

  @Post("assets/import")
  async importAssets(@Body() body: unknown) {
    const dto = parseDto(ImportAssetsDtoSchema, body, "assets/import");
    const result = await this.datasetService.importAssets(dto);
    if (
      Array.isArray(result.imported)
      && Array.isArray(result.duplicates)
      && Array.isArray(result.failed)
      && Array.isArray(result.skipped)
      && result.imported.length === 0
      && result.duplicates.length === 0
      && (result.failed.length > 0 || result.skipped.length > 0)
    ) {
      throw new BadRequestException({
        message: "No importable assets found in request.",
        report: result,
      });
    }
    return result;
  }

  @Get("children")
  listChildren() { return this.datasetService.listChildren(); }

  @Get("children/:id")
  getChild(@Param("id") id: string) { return this.datasetService.getChild(id); }

  @Patch("children/:id")
  async updateChild(@Param("id") id: string, @Body() body: unknown) {
    const dto = parseDto(UpdateChildDtoSchema, body, "children/:id");
    const result = await this.datasetService.updateChild(id, dto);
    if (result.status !== 200) {
      throw new HttpException(result.data, result.status);
    }
    return result.data;
  }

  @Delete("children/:id")
  async deleteChild(@Param("id") id: string) {
    const result = await this.datasetService.deleteChild(id);
    if (result.status !== 200) {
      throw new HttpException(result.data, result.status);
    }
    return result.data;
  }

  @Get("assets")
  listAssets(@Query("type") type?: string, @Query("childId") childId?: string, @Query("query") query?: string) {
    return this.datasetService.listAssets(type, childId, query);
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

  @Patch("assets/:id")
  updateAssetPatch(@Param("id") id: string, @Body() body: unknown) {
    const dto = parseDto(UpdateAssetDtoSchema, body, "assets/:id");
    return this.updateAssetOrThrow(id, dto);
  }

  @Delete("assets/batch")
  deleteAssetsBatch(@Body() body: unknown) {
    const dto = parseDto(DeleteAssetsBatchDtoSchema, body, "assets/batch");
    return this.datasetService.deleteAssetsBatch(dto.ids);
  }

  @Delete("assets/:id")
  async deleteAsset(@Param("id") id: string) {
    const result = await this.datasetService.deleteAsset(id);
    if (!result?.ok) {
      throw new NotFoundException("Asset not found.");
    }
    return result;
  }

  @Post("search/query")
  searchAssets(@Body() body: unknown) {
    const dto = parseDto(SearchAssetsDtoSchema, body, "search/query");
    return this.datasetService.searchAssets(dto);
  }

  @Get("search/candidate-pool")
  listSearchCandidatePool(@Query("childId") childId: string) {
    return this.datasetService.listSearchCandidatePool(childId);
  }

  @Post("search/candidate-pool/items")
  addSearchCandidatePoolItems(@Body() body: unknown) {
    const dto = parseDto(
      SearchCandidatePoolItemsDtoSchema,
      body,
      "search/candidate-pool/items",
    );
    return this.datasetService.addSearchCandidatePoolItems(dto);
  }

  @Delete("search/candidate-pool/items")
  removeSearchCandidatePoolItems(@Body() body: unknown) {
    const dto = parseDto(
      SearchCandidatePoolItemsDtoSchema,
      body,
      "search/candidate-pool/items",
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
    const dto = parseDto(RunSearchIndexerDtoSchema, body, "search/indexing/run");
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

  private async updateAssetOrThrow(
    id: string,
    dto: Parameters<DatasetService["updateAsset"]>[1],
  ) {
    const result = await this.datasetService.updateAsset(id, dto);
    if (!result?.asset) {
      throw new NotFoundException("Asset not found.");
    }
    return result;
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
