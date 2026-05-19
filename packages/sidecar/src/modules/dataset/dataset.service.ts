import { Inject, Injectable } from "@nestjs/common";

import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { DatasetStateService } from "../../infrastructure/dataset-state/dataset-state.service.ts";
import type { SampleDb } from "../../infrastructure/dataset-state/memory-dataset-db.ts";
import {
  createSupabaseStorageProvider,
  type SupabaseStorageProvider,
} from "../storage/providers/supabase-storage.ts";
import {
  createStorageSyncService,
  type StorageProviderForSync,
} from "../storage/providers/storage-sync.ts";
import { createDatasetService } from "./providers/dataset.domain.ts";
import { createOpenAIAssetMetadataInferer, type InferAssetMetadata } from "./providers/asset-metadata-inference.ts";
import type { StorageSyncJobStatus } from "../../infrastructure/dataset-state/memory-dataset-db.ts";

type DatasetServiceFactories = {
  createStorageProvider?: (config: AppConfigService) => StorageProviderForSync | SupabaseStorageProvider;
  createStorageSync?: (input: {
    db: Awaited<ReturnType<DatasetStateService["activatePersistent"]>>;
    provider: StorageProviderForSync;
  }) => ReturnType<typeof createStorageSyncService>;
  createInferAssetMetadata?: (config: AppConfigService) => InferAssetMetadata | undefined;
};
export const DATASET_SERVICE_FACTORIES = Symbol("DATASET_SERVICE_FACTORIES");

@Injectable()
export class DatasetService {
  private readonly datasetState: DatasetStateService;
  private readonly config: AppConfigService;
  private readonly factories: Required<DatasetServiceFactories>;
  private storageProvider?: StorageProviderForSync;
  private storageSync?: ReturnType<typeof createStorageSyncService>;
  private inferAssetMetadata?: InferAssetMetadata | null;

  constructor(
    @Inject(DatasetStateService) datasetState: DatasetStateService,
    @Inject(AppConfigService) config: AppConfigService,
    @Inject(DATASET_SERVICE_FACTORIES) factories: DatasetServiceFactories = {},
  ) {
    this.datasetState = datasetState;
    this.config = config;
    this.factories = {
      createStorageProvider:
        factories.createStorageProvider
        ?? ((cfg) => createSupabaseStorageProvider({ config: cfg.config.supabaseStorage })),
      createStorageSync: factories.createStorageSync ?? createStorageSyncService,
      createInferAssetMetadata: factories.createInferAssetMetadata ?? ((cfg) => createOpenAIAssetMetadataInferer(cfg)),
    };
  }

  private getInferAssetMetadata() {
    if (this.inferAssetMetadata === undefined) {
      this.inferAssetMetadata = this.factories.createInferAssetMetadata(this.config) ?? null;
    }
    return this.inferAssetMetadata ?? undefined;
  }

  private get delegate() {
    return createDatasetService({
      datasetState: this.datasetState,
      config: this.config,
      inferAssetMetadata: this.getInferAssetMetadata(),
    });
  }

  private async readDb(): Promise<SampleDb> {
    try {
      return await this.datasetState.activatePersistent();
    } catch (error) {
      console.warn(
        "Falling back to in-memory dataset after persistent dataset activation failed:",
        error instanceof Error ? error.message : error,
      );
      return this.datasetState.current();
    }
  }

  private async storageDelegate() {
    if (!this.storageSync) {
      if (!this.storageProvider) {
        this.storageProvider = this.factories.createStorageProvider(this.config) as StorageProviderForSync;
      }
      this.storageSync = this.factories.createStorageSync({
        db: await this.datasetState.activatePersistent(),
        provider: this.storageProvider,
      });
    }
    return this.storageSync;
  }

  importSample(persist: boolean) { return this.delegate.importSample(persist); }
  async listChildren() { return { children: await (await this.readDb()).getChildren() }; }
  createChild(input: { id?: string; name?: string; birthday?: string; notes?: string; metadata?: Record<string, unknown> }) {
    return this.delegate.createChild(input);
  }
  async getChild(id: string) { return { child: await (await this.readDb()).getChild(id) }; }
  updateChild(id: string, updates: { name?: string; birthday?: string; notes?: string; metadata?: Record<string, unknown> }) {
    return this.delegate.updateChild(id, updates);
  }
  deleteChild(id: string) { return this.delegate.deleteChild(id); }
  async listAssets(type?: string, childId?: string, query?: string) {
    return this.delegate.listAssets({ type, childId, query });
  }
  async getAsset(id: string) { return { asset: await (await this.readDb()).getAsset(id) }; }
  importAssets(input: { childId: string; paths: string[]; recursive?: boolean }) { return this.delegate.importAssets(input); }
  updateAsset(id: string, updates: { title?: string; description?: string; tags?: string[]; capturedAt?: string; type?: string }) {
    return this.delegate.updateAsset(id, updates);
  }
  deleteAsset(id: string) { return this.delegate.deleteAsset(id); }
  deleteAssetsBatch(ids: string[]) { return this.delegate.deleteAssetsBatch(ids); }
  enqueueSearchIndexing(assetId: string) { return this.delegate.enqueueSearchIndexing(assetId); }
  runSearchIndexer(input: { limit?: number; now?: Date } = {}) { return this.delegate.runSearchIndexer(input); }
  getSearchIndexingStatus(childId?: string) { return this.delegate.getSearchIndexingStatus(childId); }
  searchAssets(input: { childId: string; query: string; filters?: { types?: string[]; tags?: string[]; capturedFrom?: string; capturedTo?: string }; page?: number; pageSize?: number }) {
    return this.delegate.searchAssets(input);
  }
  listSearchCandidatePool(childId: string) { return this.delegate.listSearchCandidatePool(childId); }
  addSearchCandidatePoolItems(input: { childId: string; assetIds: string[]; sourceQuery?: string }) {
    return this.delegate.addSearchCandidatePoolItems(input);
  }
  removeSearchCandidatePoolItems(input: { childId: string; assetIds: string[] }) {
    return this.delegate.removeSearchCandidatePoolItems(input);
  }
  resetSampleAssets(childId?: string) { return this.delegate.resetSampleAssets(childId); }
  async enqueueAssetStorageSync(assetId: string) {
    return (await this.storageDelegate()).enqueueAssetSync(assetId);
  }
  async enqueueExportArtifactStorageSync(input: { artifactId: string; childId: string }) {
    return (await this.storageDelegate()).enqueueExportArtifactSync(input);
  }
  async runStorageSyncWorker(input: { limit?: number; now?: Date } = {}) {
    return (await this.storageDelegate()).runStorageSyncWorker(input);
  }
  async getStorageSyncStatus() {
    const db = await this.readDb();
    const getByStatus = db.getStorageSyncJobsByStatus?.bind(db);
    if (!getByStatus) {
      return {
        queue: {
          pending: 0,
          running: 0,
          retry_wait: 0,
          done: 0,
          failed: 0,
        },
      };
    }
    const statuses: StorageSyncJobStatus[] = ["pending", "running", "retry_wait", "done", "failed"];
    const rows = await Promise.all(statuses.map((status) => getByStatus(status)));
    const queue = Object.fromEntries(statuses.map((status, idx) => [status, rows[idx].length]));
    return { queue };
  }
  async getExportArtifactShareMetadata(artifactId: string) {
    return (await this.storageDelegate()).getShareMetadata(artifactId);
  }
}
