import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { DatasetStateService } from "../../infrastructure/dataset-state/dataset-state.service.ts";
import type { SampleDb } from "../../infrastructure/dataset-state/memory-dataset-db.ts";
import { registerInjectable } from "../../infrastructure/nest/register-injectable.ts";
import {
  createSupabaseStorageProvider,
  type SupabaseStorageProvider,
} from "../storage/providers/supabase-storage.ts";
import {
  createStorageSyncService,
  type StorageProviderForSync,
} from "../storage/providers/storage-sync.ts";
import { createDatasetService } from "./providers/dataset.domain.ts";

type DatasetServiceFactories = {
  createStorageProvider?: (config: AppConfigService) => StorageProviderForSync | SupabaseStorageProvider;
  createStorageSync?: (input: {
    db: Awaited<ReturnType<DatasetStateService["activatePersistent"]>>;
    provider: StorageProviderForSync;
  }) => ReturnType<typeof createStorageSyncService>;
};

export class DatasetService {
  private readonly datasetState: DatasetStateService;
  private readonly config: AppConfigService;
  private readonly factories: Required<DatasetServiceFactories>;
  private storageProvider?: StorageProviderForSync;
  private storageSync?: ReturnType<typeof createStorageSyncService>;

  constructor(
    datasetState: DatasetStateService,
    config: AppConfigService,
    factories: DatasetServiceFactories = {},
  ) {
    this.datasetState = datasetState;
    this.config = config;
    this.factories = {
      createStorageProvider:
        factories.createStorageProvider
        ?? ((cfg) => createSupabaseStorageProvider({ config: cfg.config.supabaseStorage })),
      createStorageSync: factories.createStorageSync ?? createStorageSyncService,
    };
  }

  private get delegate() {
    return createDatasetService({ datasetState: this.datasetState, config: this.config });
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
  createChild(input: { id?: string; name?: string }) { return this.delegate.createChild(input); }
  async getChild(id: string) { return { child: await (await this.readDb()).getChild(id) }; }
  async listAssets(type?: string, childId?: string) { return { assets: await (await this.readDb()).getAssets({ type, childId }) }; }
  async getAsset(id: string) { return { asset: await (await this.readDb()).getAsset(id) }; }
  importAssets(input: { childId: string; paths: string[]; recursive?: boolean }) { return this.delegate.importAssets(input); }
  updateAsset(id: string, updates: { title?: string; description?: string; tags?: string[]; capturedAt?: string; type?: string }) {
    return this.delegate.updateAsset(id, updates);
  }
  deleteAsset(id: string) { return this.delegate.deleteAsset(id); }
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
  async getExportArtifactShareMetadata(artifactId: string) {
    return (await this.storageDelegate()).getShareMetadata(artifactId);
  }
}

registerInjectable(DatasetService, [DatasetStateService, AppConfigService]);
