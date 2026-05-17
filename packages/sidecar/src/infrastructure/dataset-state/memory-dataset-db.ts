export type EmbeddingJobStatus = "pending" | "running" | "retry_wait" | "done" | "failed";
export type StorageSyncJobStatus = "pending" | "running" | "retry_wait" | "done" | "failed";

export type SampleAsset = {
  id: string;
  childId?: string;
  type: string;
  title: string;
  tags: string[];
  description: string;
  imagePath: string;
  thumbnailPath: string;
  sourceUrl: string;
  license: string;
  capturedAt?: string;
  hash?: string;
  originalFilename?: string;
  originalPath?: string;
  storageProvider?: string;
  storageStatus?: string;
  storagePath?: string;
  remoteUrl?: string;
  updatedAt?: string;
  embeddingStatus?: "pending" | "ready" | "failed";
  embeddingVersion?: number;
  searchable?: boolean;
  embeddingUpdatedAt?: string;
  lastEmbeddingErrorCode?: string;
  lastEmbeddingErrorMessage?: string;
};

export interface Child {
  id: string;
  name: string;
  birthday?: string;
  notes?: string;
  metadata?: Record<string, unknown>;
  created_at?: string;
  updated_at?: string;
}

export type EmbeddingJob = {
  id: string;
  assetId: string;
  metadataVersion: number;
  status: EmbeddingJobStatus;
  attempt: number;
  maxAttempts: number;
  runAfter: string;
  lockedBy?: string;
  lockedAt?: string;
  sourceQuery?: string;
  lastErrorCode?: string;
  lastErrorMessage?: string;
  createdAt: string;
  updatedAt: string;
};

export type StorageSyncJob = {
  id: string;
  targetType: "asset" | "export_artifact";
  targetId: string;
  provider: "supabase";
  objectPath: string;
  status: StorageSyncJobStatus;
  attempt: number;
  maxAttempts: number;
  runAfter: string;
  lockedBy?: string;
  lockedAt?: string;
  lastErrorCode?: string;
  lastErrorMessage?: string;
  createdAt: string;
  updatedAt: string;
};

export type ExportArtifact = {
  id: string;
  jobId: string;
  kind: "pdf" | "long_image_png" | "long_image_jpg";
  localPath: string;
  storageProvider?: string;
  storageStatus?: string;
  storagePath?: string;
  remoteUrl?: string;
  createdAt?: string;
  updatedAt?: string;
};

export type SearchFilters = {
  types?: string[];
  tags?: string[];
  capturedFrom?: string;
  capturedTo?: string;
};

export type SearchRecallResult = {
  asset: SampleAsset;
  semanticScore: number;
};

export type SearchCandidatePoolItem = {
  childId: string;
  assetId: string;
  sourceQuery?: string;
  createdAt: string;
};

export type SampleDb = {
  upsertChild(child: Child): Promise<void>;
  upsertAsset(asset: SampleAsset): Promise<void>;
  getAssets(filter?: { type?: string; childId?: string }): Promise<SampleAsset[]>;
  getAssetsByIds(ids: string[]): Promise<SampleAsset[]>;
  getChildren(): Promise<Child[]>;
  getChild?(id: string): Promise<Child | null>;
  deleteChild?(id: string): Promise<boolean>;
  getAsset?(id: string): Promise<SampleAsset | null>;
  findAssetByChildAndHash?(childId: string, hash: string): Promise<SampleAsset | null>;
  updateAssetMetadata?(
    id: string,
    updates: { title?: string; description?: string; tags?: string[]; capturedAt?: string; type?: string },
  ): Promise<SampleAsset | null>;
  deleteAsset?(id: string): Promise<boolean>;
  deleteAssetsByChildId?(childId: string): Promise<number>;
  deleteEmbeddingJobsByAssetIds?(assetIds: string[]): Promise<number>;
  deleteCandidatePoolItemsByChildId?(childId: string): Promise<number>;
  prepareAssetForIndexing?(assetId: string): Promise<{ assetId: string; metadataVersion: number } | null>;
  enqueueEmbeddingJob?(input: { assetId: string; metadataVersion: number; maxAttempts?: number; sourceQuery?: string }): Promise<{ enqueued: boolean; jobId: string }>;
  claimEmbeddingJobs?(options: { limit: number; workerId: string; now?: Date; staleAfterSeconds?: number }): Promise<EmbeddingJob[]>;
  markEmbeddingJobDone?(jobId: string): Promise<void>;
  markEmbeddingJobRetry?(input: { jobId: string; attempt: number; runAfter: Date; errorCode: string; errorMessage: string }): Promise<void>;
  markEmbeddingJobFailed?(input: { jobId: string; attempt: number; errorCode: string; errorMessage: string }): Promise<void>;
  getEmbeddingJobsByStatus?(status: EmbeddingJobStatus, childId?: string): Promise<EmbeddingJob[]>;
  storeAssetEmbedding?(input: { assetId: string; metadataVersion: number; embedding: number[]; model: string }): Promise<boolean>;
  markAssetEmbeddingFailed?(input: { assetId: string; metadataVersion: number; errorCode: string; errorMessage: string }): Promise<void>;
  searchAssetsByVector?(input: { childId: string; vector: number[]; topK: number; filters?: SearchFilters }): Promise<SearchRecallResult[]>;
  listCandidatePoolItems?(childId: string): Promise<SearchCandidatePoolItem[]>;
  addCandidatePoolItems?(input: { childId: string; assetIds: string[]; sourceQuery?: string }): Promise<{ added: number }>;
  removeCandidatePoolItems?(input: { childId: string; assetIds: string[] }): Promise<{ removed: number }>;
  enqueueStorageSyncJob?(input: {
    targetType: "asset" | "export_artifact";
    targetId: string;
    provider?: "supabase";
    objectPath: string;
    maxAttempts?: number;
  }): Promise<{ enqueued: boolean; jobId: string }>;
  claimStorageSyncJobs?(options: { limit: number; workerId: string; now?: Date; staleAfterSeconds?: number }): Promise<StorageSyncJob[]>;
  markStorageSyncJobDone?(jobId: string): Promise<void>;
  markStorageSyncJobRetry?(input: { jobId: string; attempt: number; runAfter: Date; errorCode: string; errorMessage: string }): Promise<void>;
  markStorageSyncJobFailed?(input: { jobId: string; attempt: number; errorCode: string; errorMessage: string }): Promise<void>;
  getStorageSyncJobsByStatus?(status: StorageSyncJobStatus): Promise<StorageSyncJob[]>;
  updateAssetStorageState?(input: { assetId: string; storageProvider: string; storageStatus: string; storagePath?: string; remoteUrl?: string }): Promise<SampleAsset | null>;
  upsertExportArtifact?(artifact: ExportArtifact): Promise<ExportArtifact>;
  getExportArtifact?(id: string): Promise<ExportArtifact | null>;
  updateExportArtifactStorageState?(input: { artifactId: string; storageProvider: string; storageStatus: string; storagePath?: string; remoteUrl?: string }): Promise<ExportArtifact | null>;
};

export class MemoryDatasetDb implements SampleDb {
  children = new Map<string, Child>();
  assets = new Map<string, SampleAsset>();
  private readonly embeddings = new Map<string, number[]>();
  private readonly embeddingJobs = new Map<string, EmbeddingJob>();
  private readonly storageSyncJobs = new Map<string, StorageSyncJob>();
  private readonly exportArtifacts = new Map<string, ExportArtifact>();
  private readonly candidatePool = new Map<string, SearchCandidatePoolItem>();

  async upsertChild(child: Child) {
    this.children.set(child.id, child);
  }

  async upsertAsset(asset: SampleAsset) {
    const current = this.assets.get(asset.id);
    const next: SampleAsset = {
      ...current,
      ...asset,
    };
    if (!next.embeddingStatus) next.embeddingStatus = "pending";
    if (typeof next.embeddingVersion !== "number") next.embeddingVersion = 0;
    if (!next.storageProvider) next.storageProvider = "local";
    if (!next.storageStatus || next.storageStatus === "ready") {
      next.storageStatus = "local_only";
    }
    if (!next.storagePath) next.storagePath = next.imagePath;
    next.searchable = next.embeddingStatus === "ready";
    this.assets.set(asset.id, next);
  }

  async getAssets(filter: { type?: string; childId?: string } = {}) {
    return [...this.assets.values()].filter((asset) => {
      if (filter.type && asset.type !== filter.type) return false;
      if (filter.childId && asset.childId !== filter.childId) return false;
      return true;
    });
  }

  async getAssetsByIds(ids: string[]) {
    return ids.map((id) => this.assets.get(id)).filter(Boolean) as SampleAsset[];
  }

  async getAsset(id: string) {
    return this.assets.get(id) || null;
  }

  async findAssetByChildAndHash(childId: string, hash: string) {
    for (const asset of this.assets.values()) {
      if (asset.childId === childId && asset.hash === hash) return asset;
    }
    return null;
  }

  async updateAssetMetadata(
    id: string,
    updates: { title?: string; description?: string; tags?: string[]; capturedAt?: string; type?: string },
  ) {
    const current = this.assets.get(id);
    if (!current) return null;
    const next: SampleAsset = {
      ...current,
      ...updates,
      updatedAt: new Date().toISOString(),
    };
    this.assets.set(id, next);
    return next;
  }

  async deleteAsset(id: string) {
    this.embeddings.delete(id);
    for (const [jobId, job] of this.embeddingJobs.entries()) {
      if (job.assetId === id) this.embeddingJobs.delete(jobId);
    }
    for (const [key, item] of this.candidatePool.entries()) {
      if (item.assetId === id) this.candidatePool.delete(key);
    }
    for (const [jobId, job] of this.storageSyncJobs.entries()) {
      if (job.targetType === "asset" && job.targetId === id) {
        this.storageSyncJobs.delete(jobId);
      }
    }
    return this.assets.delete(id);
  }

  async deleteAssetsByChildId(childId: string) {
    let deleted = 0;
    for (const [id, asset] of this.assets.entries()) {
      if (asset.childId === childId) {
        this.assets.delete(id);
        this.embeddings.delete(id);
        for (const [jobId, job] of this.storageSyncJobs.entries()) {
          if (job.targetType === "asset" && job.targetId === id) {
            this.storageSyncJobs.delete(jobId);
          }
        }
        deleted += 1;
      }
    }
    for (const [key, item] of this.candidatePool.entries()) {
      if (item.childId === childId) {
        this.candidatePool.delete(key);
      }
    }
    return deleted;
  }

  async deleteEmbeddingJobsByAssetIds(assetIds: string[]) {
    if (assetIds.length === 0) return 0;
    const targets = new Set(assetIds);
    let deleted = 0;
    for (const [id, job] of this.embeddingJobs.entries()) {
      if (targets.has(job.assetId)) {
        this.embeddingJobs.delete(id);
        deleted += 1;
      }
    }
    return deleted;
  }

  async getChild(id: string) {
    return this.children.get(id) || null;
  }

  async deleteChild(id: string) {
    return this.children.delete(id);
  }

  async getChildren() {
    return [...this.children.values()];
  }

  async prepareAssetForIndexing(assetId: string) {
    const asset = this.assets.get(assetId);
    if (!asset) return null;
    const metadataVersion = (asset.embeddingVersion || 0) + 1;
    this.assets.set(assetId, {
      ...asset,
      embeddingStatus: "pending",
      searchable: false,
      embeddingVersion: metadataVersion,
      embeddingUpdatedAt: new Date().toISOString(),
      lastEmbeddingErrorCode: "",
      lastEmbeddingErrorMessage: "",
    });
    this.embeddings.delete(assetId);
    return { assetId, metadataVersion };
  }

  async enqueueEmbeddingJob(input: { assetId: string; metadataVersion: number; maxAttempts?: number; sourceQuery?: string }) {
    for (const existing of this.embeddingJobs.values()) {
      if (existing.assetId === input.assetId && existing.metadataVersion === input.metadataVersion) {
        return { enqueued: false, jobId: existing.id };
      }
    }
    const now = new Date().toISOString();
    const job: EmbeddingJob = {
      id: `embjob_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
      assetId: input.assetId,
      metadataVersion: input.metadataVersion,
      status: "pending",
      attempt: 0,
      maxAttempts: input.maxAttempts || 5,
      runAfter: now,
      sourceQuery: input.sourceQuery || "",
      createdAt: now,
      updatedAt: now,
    };
    this.embeddingJobs.set(job.id, job);
    return { enqueued: true, jobId: job.id };
  }

  async claimEmbeddingJobs(options: { limit: number; workerId: string; now?: Date; staleAfterSeconds?: number }) {
    const now = options.now || new Date();
    const staleAfterMs = (options.staleAfterSeconds || 60) * 1000;

    for (const [jobId, job] of this.embeddingJobs.entries()) {
      if (job.status !== "running" || !job.lockedAt) continue;
      const lockedAtMs = new Date(job.lockedAt).getTime();
      if (!Number.isFinite(lockedAtMs) || now.getTime() - lockedAtMs <= staleAfterMs) continue;
      const attempt = job.attempt + 1;
      if (attempt >= job.maxAttempts) {
        this.embeddingJobs.set(jobId, {
          ...job,
          attempt,
          status: "failed",
          lockedAt: "",
          lockedBy: "",
          lastErrorCode: job.lastErrorCode || "stale_timeout",
          lastErrorMessage: job.lastErrorMessage || "job lock timeout",
          updatedAt: now.toISOString(),
        });
      } else {
        this.embeddingJobs.set(jobId, {
          ...job,
          attempt,
          status: "pending",
          runAfter: now.toISOString(),
          lockedAt: "",
          lockedBy: "",
          updatedAt: now.toISOString(),
        });
      }
    }

    const due = [...this.embeddingJobs.values()]
      .filter((job) => (job.status === "pending" || job.status === "retry_wait") && new Date(job.runAfter).getTime() <= now.getTime())
      .sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime())
      .slice(0, Math.max(1, options.limit));

    const claimed: EmbeddingJob[] = [];
    for (const job of due) {
      const next = {
        ...job,
        status: "running" as EmbeddingJobStatus,
        lockedBy: options.workerId,
        lockedAt: now.toISOString(),
        updatedAt: now.toISOString(),
      };
      this.embeddingJobs.set(next.id, next);
      claimed.push(next);
    }

    return claimed;
  }

  async markEmbeddingJobDone(jobId: string) {
    const job = this.embeddingJobs.get(jobId);
    if (!job) return;
    this.embeddingJobs.set(jobId, {
      ...job,
      status: "done",
      lockedBy: "",
      lockedAt: "",
      updatedAt: new Date().toISOString(),
    });
  }

  async markEmbeddingJobRetry(input: { jobId: string; attempt: number; runAfter: Date; errorCode: string; errorMessage: string }) {
    const job = this.embeddingJobs.get(input.jobId);
    if (!job) return;
    this.embeddingJobs.set(input.jobId, {
      ...job,
      status: "retry_wait",
      attempt: input.attempt,
      runAfter: input.runAfter.toISOString(),
      lockedBy: "",
      lockedAt: "",
      lastErrorCode: input.errorCode,
      lastErrorMessage: input.errorMessage,
      updatedAt: new Date().toISOString(),
    });
  }

  async markEmbeddingJobFailed(input: { jobId: string; attempt: number; errorCode: string; errorMessage: string }) {
    const job = this.embeddingJobs.get(input.jobId);
    if (!job) return;
    this.embeddingJobs.set(input.jobId, {
      ...job,
      status: "failed",
      attempt: input.attempt,
      lockedBy: "",
      lockedAt: "",
      lastErrorCode: input.errorCode,
      lastErrorMessage: input.errorMessage,
      updatedAt: new Date().toISOString(),
    });
  }

  async getEmbeddingJobsByStatus(status: EmbeddingJobStatus, childId?: string) {
    const jobs = [...this.embeddingJobs.values()].filter((job) => job.status === status);
    if (!childId) return jobs;
    return jobs.filter((job) => this.assets.get(job.assetId)?.childId === childId);
  }

  async storeAssetEmbedding(input: { assetId: string; metadataVersion: number; embedding: number[]; model: string }) {
    const asset = this.assets.get(input.assetId);
    if (!asset) return false;
    if ((asset.embeddingVersion || 0) !== input.metadataVersion) return false;
    this.embeddings.set(input.assetId, input.embedding);
    this.assets.set(input.assetId, {
      ...asset,
      embeddingStatus: "ready",
      searchable: true,
      embeddingUpdatedAt: new Date().toISOString(),
      lastEmbeddingErrorCode: "",
      lastEmbeddingErrorMessage: "",
    });
    return true;
  }

  async markAssetEmbeddingFailed(input: { assetId: string; metadataVersion: number; errorCode: string; errorMessage: string }) {
    const asset = this.assets.get(input.assetId);
    if (!asset) return;
    if ((asset.embeddingVersion || 0) !== input.metadataVersion) return;
    this.assets.set(input.assetId, {
      ...asset,
      embeddingStatus: "failed",
      searchable: false,
      embeddingUpdatedAt: new Date().toISOString(),
      lastEmbeddingErrorCode: input.errorCode,
      lastEmbeddingErrorMessage: input.errorMessage,
    });
  }

  async searchAssetsByVector(input: { childId: string; vector: number[]; topK: number; filters?: SearchFilters }) {
    const filtered = [...this.assets.values()].filter((asset) => {
      if (asset.childId !== input.childId) return false;
      if (asset.embeddingStatus !== "ready") return false;
      if (!this.embeddings.has(asset.id)) return false;
      if (input.filters?.types?.length && !input.filters.types.includes(asset.type)) return false;
      if (input.filters?.tags?.length && !input.filters.tags.every((tag) => asset.tags.includes(tag))) return false;
      if (input.filters?.capturedFrom && (!asset.capturedAt || new Date(asset.capturedAt).getTime() < new Date(input.filters.capturedFrom).getTime())) {
        return false;
      }
      if (input.filters?.capturedTo && (!asset.capturedAt || new Date(asset.capturedAt).getTime() > new Date(input.filters.capturedTo).getTime())) {
        return false;
      }
      return true;
    });

    return filtered
      .map((asset) => {
        const embedding = this.embeddings.get(asset.id)!;
        return {
          asset,
          semanticScore: cosineSimilarity(input.vector, embedding),
        };
      })
      .sort((a, b) => b.semanticScore - a.semanticScore)
      .slice(0, Math.max(1, input.topK));
  }

  async listCandidatePoolItems(childId: string) {
    return [...this.candidatePool.values()]
      .filter((item) => item.childId === childId)
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }

  async addCandidatePoolItems(input: { childId: string; assetIds: string[]; sourceQuery?: string }) {
    let added = 0;
    for (const assetId of input.assetIds) {
      const key = `${input.childId}:${assetId}`;
      if (this.candidatePool.has(key)) continue;
      this.candidatePool.set(key, {
        childId: input.childId,
        assetId,
        sourceQuery: input.sourceQuery || "",
        createdAt: new Date().toISOString(),
      });
      added += 1;
    }
    return { added };
  }

  async removeCandidatePoolItems(input: { childId: string; assetIds: string[] }) {
    let removed = 0;
    for (const assetId of input.assetIds) {
      const key = `${input.childId}:${assetId}`;
      if (!this.candidatePool.has(key)) continue;
      this.candidatePool.delete(key);
      removed += 1;
    }
    return { removed };
  }

  async deleteCandidatePoolItemsByChildId(childId: string) {
    let deleted = 0;
    for (const [key, item] of this.candidatePool.entries()) {
      if (item.childId === childId) {
        this.candidatePool.delete(key);
        deleted += 1;
      }
    }
    return deleted;
  }

  async enqueueStorageSyncJob(input: {
    targetType: "asset" | "export_artifact";
    targetId: string;
    provider?: "supabase";
    objectPath: string;
    maxAttempts?: number;
  }) {
    const provider = input.provider || "supabase";
    for (const existing of this.storageSyncJobs.values()) {
      if (
        existing.targetType === input.targetType
        && existing.targetId === input.targetId
        && existing.provider === provider
        && existing.objectPath === input.objectPath
      ) {
        return { enqueued: false, jobId: existing.id };
      }
    }
    const now = new Date().toISOString();
    const job: StorageSyncJob = {
      id: `storagejob_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
      targetType: input.targetType,
      targetId: input.targetId,
      provider,
      objectPath: input.objectPath,
      status: "pending",
      attempt: 0,
      maxAttempts: input.maxAttempts || 5,
      runAfter: now,
      createdAt: now,
      updatedAt: now,
    };
    this.storageSyncJobs.set(job.id, job);
    return { enqueued: true, jobId: job.id };
  }

  async claimStorageSyncJobs(options: { limit: number; workerId: string; now?: Date; staleAfterSeconds?: number }) {
    const now = options.now || new Date();
    const staleAfterMs = (options.staleAfterSeconds || 60) * 1000;

    for (const [jobId, job] of this.storageSyncJobs.entries()) {
      if (job.status !== "running" || !job.lockedAt) continue;
      const lockedAtMs = new Date(job.lockedAt).getTime();
      if (!Number.isFinite(lockedAtMs) || now.getTime() - lockedAtMs <= staleAfterMs) continue;
      const attempt = job.attempt + 1;
      if (attempt >= job.maxAttempts) {
        this.storageSyncJobs.set(jobId, {
          ...job,
          attempt,
          status: "failed",
          lockedAt: "",
          lockedBy: "",
          lastErrorCode: job.lastErrorCode || "stale_timeout",
          lastErrorMessage: job.lastErrorMessage || "storage sync lock timeout",
          updatedAt: now.toISOString(),
        });
      } else {
        this.storageSyncJobs.set(jobId, {
          ...job,
          attempt,
          status: "pending",
          runAfter: now.toISOString(),
          lockedAt: "",
          lockedBy: "",
          updatedAt: now.toISOString(),
        });
      }
    }

    const due = [...this.storageSyncJobs.values()]
      .filter((job) => (job.status === "pending" || job.status === "retry_wait") && new Date(job.runAfter).getTime() <= now.getTime())
      .sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime())
      .slice(0, Math.max(1, options.limit));

    const claimed: StorageSyncJob[] = [];
    for (const job of due) {
      const next = {
        ...job,
        status: "running" as StorageSyncJobStatus,
        lockedBy: options.workerId,
        lockedAt: now.toISOString(),
        updatedAt: now.toISOString(),
      };
      this.storageSyncJobs.set(next.id, next);
      claimed.push(next);
    }
    return claimed;
  }

  async markStorageSyncJobDone(jobId: string) {
    const job = this.storageSyncJobs.get(jobId);
    if (!job) return;
    this.storageSyncJobs.set(jobId, {
      ...job,
      status: "done",
      lockedBy: "",
      lockedAt: "",
      updatedAt: new Date().toISOString(),
    });
  }

  async markStorageSyncJobRetry(input: { jobId: string; attempt: number; runAfter: Date; errorCode: string; errorMessage: string }) {
    const job = this.storageSyncJobs.get(input.jobId);
    if (!job) return;
    this.storageSyncJobs.set(input.jobId, {
      ...job,
      status: "retry_wait",
      attempt: input.attempt,
      runAfter: input.runAfter.toISOString(),
      lockedBy: "",
      lockedAt: "",
      lastErrorCode: input.errorCode,
      lastErrorMessage: input.errorMessage,
      updatedAt: new Date().toISOString(),
    });
  }

  async markStorageSyncJobFailed(input: { jobId: string; attempt: number; errorCode: string; errorMessage: string }) {
    const job = this.storageSyncJobs.get(input.jobId);
    if (!job) return;
    this.storageSyncJobs.set(input.jobId, {
      ...job,
      status: "failed",
      attempt: input.attempt,
      lockedBy: "",
      lockedAt: "",
      lastErrorCode: input.errorCode,
      lastErrorMessage: input.errorMessage,
      updatedAt: new Date().toISOString(),
    });
  }

  async getStorageSyncJobsByStatus(status: StorageSyncJobStatus) {
    return [...this.storageSyncJobs.values()].filter((job) => job.status === status);
  }

  async updateAssetStorageState(input: { assetId: string; storageProvider: string; storageStatus: string; storagePath?: string; remoteUrl?: string }) {
    const asset = this.assets.get(input.assetId);
    if (!asset) return null;
    const next = {
      ...asset,
      storageProvider: input.storageProvider,
      storageStatus: input.storageStatus,
      storagePath: input.storagePath || asset.storagePath,
      remoteUrl: input.remoteUrl || asset.remoteUrl,
      updatedAt: new Date().toISOString(),
    };
    this.assets.set(input.assetId, next);
    return next;
  }

  async upsertExportArtifact(artifact: ExportArtifact) {
    const current = this.exportArtifacts.get(artifact.id);
    const now = new Date().toISOString();
    const next: ExportArtifact = {
      ...current,
      ...artifact,
      storageProvider: artifact.storageProvider || current?.storageProvider || "local",
      storageStatus: artifact.storageStatus || current?.storageStatus || "local_only",
      createdAt: current?.createdAt || artifact.createdAt || now,
      updatedAt: now,
    };
    this.exportArtifacts.set(artifact.id, next);
    return next;
  }

  async getExportArtifact(id: string) {
    return this.exportArtifacts.get(id) || null;
  }

  async updateExportArtifactStorageState(input: { artifactId: string; storageProvider: string; storageStatus: string; storagePath?: string; remoteUrl?: string }) {
    const artifact = this.exportArtifacts.get(input.artifactId);
    if (!artifact) return null;
    const next = {
      ...artifact,
      storageProvider: input.storageProvider,
      storageStatus: input.storageStatus,
      storagePath: input.storagePath || artifact.storagePath,
      remoteUrl: input.remoteUrl || artifact.remoteUrl,
      updatedAt: new Date().toISOString(),
    };
    this.exportArtifacts.set(input.artifactId, next);
    return next;
  }
}

function cosineSimilarity(a: number[], b: number[]) {
  const size = Math.min(a.length, b.length);
  if (size === 0) return 0;
  let dot = 0;
  let normA = 0;
  let normB = 0;
  for (let index = 0; index < size; index += 1) {
    dot += a[index] * b[index];
    normA += a[index] * a[index];
    normB += b[index] * b[index];
  }
  if (normA === 0 || normB === 0) return 0;
  return dot / (Math.sqrt(normA) * Math.sqrt(normB));
}
