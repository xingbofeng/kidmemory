import type {
  EmbeddingJob,
  Child,
  SampleAsset,
  SearchFilters,
  SearchRecallResult,
} from "../../../infrastructure/dataset-state/memory-dataset-db.ts";
import type { DatasetStateService } from "../../../infrastructure/dataset-state/dataset-state.service.ts";
import type { AppConfigService } from "../../../infrastructure/config/app-config.service.ts";
import { importLocalAssets } from "./asset-import.ts";
import { importSampleDataset, listAssets } from "./sample-dataset.ts";

const DEFAULT_TOP_K = 100;
const MAX_VECTOR_RECALL_TOP_K = 500;
const DEFAULT_PAGE_SIZE = 30;
const EMBEDDING_DIMENSION = 1536;
const RETRY_BACKOFF_SECONDS = [5, 15, 30, 60];

type DatasetDependencies = {
  datasetState: DatasetStateService;
  config?: AppConfigService;
  embedText?: (text: string) => Promise<number[]>;
};

export function createDatasetService(dependencies: DatasetDependencies) {
  const embedText = dependencies.embedText || deterministicEmbedText;
  const dataDir = dependencies.config?.config.paths.dataDir || ".kidmemory/data";

  return {
    async importSample(persist: boolean) {
      const db = persist ? await dependencies.datasetState.activatePersistent() : await dependencies.datasetState.current();
      return importSampleDataset(db);
    },
    async listChildren() {
      return { children: await (await dependencies.datasetState.current()).getChildren() };
    },
    async createChild(input: { id?: string; name?: string }) {
      const id = sanitizeChildId(input.id || "child-default");
      const name = typeof input.name === "string" && input.name.trim() ? input.name.trim() : "孩子";
      const child = {
        id,
        name,
        birthday: "",
        notes: "",
        metadata: {},
      };
      const db = await dependencies.datasetState.activatePersistent();
      await db.upsertChild(child);
      return { child };
    },
    async getChild(id: string) {
      return { child: await (await dependencies.datasetState.current()).getChild(id) };
    },
    async listAssets(filter: { type?: string; childId?: string } = {}) {
      return { assets: await listAssets(await dependencies.datasetState.current(), filter) };
    },
    async getAsset(id: string) {
      return { asset: await (await dependencies.datasetState.current()).getAsset(id) };
    },
    async importAssets(input: { childId: string; paths: string[]; recursive?: boolean }) {
      const currentDb = await dependencies.datasetState.current();
      const selectedChild = await findChild(currentDb, input.childId);
      const db = await dependencies.datasetState.activatePersistent();
      const persistentChild = await findChild(db, input.childId);
      if (selectedChild && !persistentChild) {
        await db.upsertChild(selectedChild);
      }
      const report = await importLocalAssets(db, {
        ...input,
        dataDir,
      });
      for (const imported of report.imported) {
        await enqueueAssetIndexing(db, imported.id);
      }
      return { ok: true, ...report };
    },
    async updateAsset(id: string, updates: { title?: string; description?: string; tags?: string[]; capturedAt?: string; type?: string }) {
      const db = await dependencies.datasetState.activatePersistent();
      const updated = await db.updateAssetMetadata?.(id, updates);
      if (updated?.id) {
        await enqueueAssetIndexing(db, updated.id);
      }
      return { asset: updated };
    },
    async deleteAsset(id: string) {
      const db = await dependencies.datasetState.activatePersistent();
      const deleted = await db.deleteAsset?.(id);
      return { ok: deleted === true };
    },
    async enqueueSearchIndexing(assetId: string) {
      const db = await dependencies.datasetState.activatePersistent();
      return enqueueAssetIndexing(db, assetId);
    },
    async runSearchIndexer(input: { limit?: number; now?: Date } = {}) {
      const db = await dependencies.datasetState.activatePersistent();
      if (!db.claimEmbeddingJobs) {
        return { processed: 0, succeeded: 0, retried: 0, failed: 0, skipped: 0 };
      }
      const now = input.now || new Date();
      const jobs = await db.claimEmbeddingJobs({
        limit: Math.max(1, input.limit || 10),
        workerId: "sidecar-search-worker",
        now,
        staleAfterSeconds: 60,
      });
      const summary = {
        processed: jobs.length,
        succeeded: 0,
        retried: 0,
        failed: 0,
        skipped: 0,
      };

      for (const job of jobs) {
        const processed = await processEmbeddingJob({ db, job, now, embedText });
        if (processed === "succeeded") summary.succeeded += 1;
        if (processed === "retried") summary.retried += 1;
        if (processed === "failed") summary.failed += 1;
        if (processed === "skipped") summary.skipped += 1;
      }
      return summary;
    },
    async getSearchIndexingStatus(childId?: string) {
      const db = await dependencies.datasetState.current();
      if (!db.getEmbeddingJobsByStatus) {
        return { pending: 0, running: 0, retryWait: 0, done: 0, failed: 0, searchable: 0 };
      }
      const [pending, running, retryWait, done, failed] = await Promise.all([
        db.getEmbeddingJobsByStatus("pending", childId),
        db.getEmbeddingJobsByStatus("running", childId),
        db.getEmbeddingJobsByStatus("retry_wait", childId),
        db.getEmbeddingJobsByStatus("done", childId),
        db.getEmbeddingJobsByStatus("failed", childId),
      ]);
      const assets = await db.getAssets({ childId });
      return {
        pending: pending.length,
        running: running.length,
        retryWait: retryWait.length,
        done: done.length,
        failed: failed.length,
        searchable: assets.filter((asset) => asset.searchable === true).length,
      };
    },
    async resetSampleAssets(childId = "sample-child-001") {
      const resolvedChildId = `${childId}`.trim();
      if (!resolvedChildId) {
        throw new Error("childId is required");
      }
      const db = await dependencies.datasetState.activatePersistent();
      const sampleAssets = await db.getAssets({ childId: resolvedChildId });
      const targetAssetIds = sampleAssets.map((asset) => asset.id);
      const deletedAssets = typeof db.deleteAssetsByChildId === "function"
        ? await db.deleteAssetsByChildId(resolvedChildId)
        : (await Promise.all(sampleAssets.map((asset) => db.deleteAsset?.(asset.id)))).filter(Boolean).length;
      const deletedEmbeddingJobs = typeof db.deleteEmbeddingJobsByAssetIds === "function"
        ? await db.deleteEmbeddingJobsByAssetIds(targetAssetIds)
        : 0;
      const deletedCandidatePoolItems =
        typeof db.deleteCandidatePoolItemsByChildId === "function"
          ? await db.deleteCandidatePoolItemsByChildId(resolvedChildId)
          : 0;
      return {
        ok: true,
        childId: resolvedChildId,
        deletedAssets,
        deletedEmbeddingJobs,
        deletedCandidatePoolItems,
      };
    },
    async searchAssets(input: {
      childId: string;
      query: string;
      filters?: SearchFilters;
      page?: number;
      pageSize?: number;
    }) {
      const db = await dependencies.datasetState.current();
      const query = String(input.query || "").trim();
      const page = Math.max(1, Number(input.page || 1));
      const pageSize = Math.min(100, Math.max(1, Number(input.pageSize || DEFAULT_PAGE_SIZE)));
      const filters = normalizeSearchFilters(input.filters);
      const capturedRangeError = validateCapturedRange(filters);
      if (capturedRangeError) {
        return {
          items: [],
          total: 0,
          page,
          pageSize,
          code: "SEARCH_FILTER_INVALID",
          message: capturedRangeError,
          action: "adjust_filters",
        };
      }
      if (!query) {
        return {
          items: [],
          total: 0,
          page,
          pageSize,
          code: "SEARCH_QUERY_EMPTY",
          message: "Search query cannot be empty.",
          action: "adjust_filters",
        };
      }
      if (!db.searchAssetsByVector) {
        return {
          items: [],
          total: 0,
          page,
          pageSize,
          code: "SEARCH_BACKEND_UNAVAILABLE",
          message: "Search backend is not available.",
          action: "retry",
        };
      }
      const queryVector = await embedText(query);
      const requestedRecall = Math.max(DEFAULT_TOP_K, page * pageSize * 2);
      const recall = await db.searchAssetsByVector({
        childId: input.childId,
        vector: queryVector,
        topK: Math.min(MAX_VECTOR_RECALL_TOP_K, requestedRecall),
        filters,
      });
      const ranked = rerankSearchResults(recall, query, filters);
      const total = ranked.length;
      const start = (page - 1) * pageSize;
      const items = ranked.slice(start, start + pageSize).map((entry) => ({
        asset: entry.asset,
        score: Number(entry.score.toFixed(4)),
        reasons: buildMatchReasons(entry.asset, query, filters),
      }));
      return {
        items,
        total,
        page,
        pageSize,
      };
    },
    async listSearchCandidatePool(childId: string) {
      const db = await dependencies.datasetState.current();
      const items = await db.listCandidatePoolItems?.(childId);
      return { items: items || [] };
    },
    async addSearchCandidatePoolItems(input: { childId: string; assetIds: string[]; sourceQuery?: string }) {
      const db = await dependencies.datasetState.activatePersistent();
      const existing = new Set((await db.getAssets({ childId: input.childId })).map((asset) => asset.id));
      const uniqueAssetIds = [...new Set(input.assetIds)].filter((assetId) => existing.has(assetId));
      const added = await db.addCandidatePoolItems?.({
        childId: input.childId,
        assetIds: uniqueAssetIds,
        sourceQuery: input.sourceQuery,
      });
      return {
        added: added?.added || 0,
        requested: input.assetIds.length,
        accepted: uniqueAssetIds.length,
      };
    },
    async removeSearchCandidatePoolItems(input: { childId: string; assetIds: string[] }) {
      const db = await dependencies.datasetState.activatePersistent();
      const uniqueAssetIds = [...new Set(input.assetIds)];
      const removed = await db.removeCandidatePoolItems?.({
        childId: input.childId,
        assetIds: uniqueAssetIds,
      });
      return {
        removed: removed?.removed || 0,
      };
    },
  };
}

async function processEmbeddingJob(input: {
  db: Awaited<ReturnType<DatasetStateService["current"]>>;
  job: EmbeddingJob;
  now: Date;
  embedText: (text: string) => Promise<number[]>;
}) {
  const asset = await input.db.getAsset?.(input.job.assetId);
  if (!asset) {
    await input.db.markEmbeddingJobFailed?.({
      jobId: input.job.id,
      attempt: input.job.attempt + 1,
      errorCode: "ASSET_NOT_FOUND",
      errorMessage: "asset_not_found",
    });
    return "failed" as const;
  }

  const text = buildAssetSearchText(asset);
  try {
    const embedding = await input.embedText(text);
    const stored = await input.db.storeAssetEmbedding?.({
      assetId: input.job.assetId,
      metadataVersion: input.job.metadataVersion,
      embedding,
      model: "kidmemory-local-embedding-v1",
    });
    await input.db.markEmbeddingJobDone?.(input.job.id);
    return stored === false ? "skipped" as const : "succeeded" as const;
  } catch (error: unknown) {
    const normalized = normalizeEmbeddingError(error);
    const nextAttempt = input.job.attempt + 1;
    if (normalized.retryable && nextAttempt < input.job.maxAttempts) {
      const waitSeconds = RETRY_BACKOFF_SECONDS[Math.min(nextAttempt - 1, RETRY_BACKOFF_SECONDS.length - 1)];
      const runAfter = new Date(input.now.getTime() + waitSeconds * 1000);
      await input.db.markEmbeddingJobRetry?.({
        jobId: input.job.id,
        attempt: nextAttempt,
        runAfter,
        errorCode: normalized.errorCode,
        errorMessage: normalized.errorMessage,
      });
      return "retried" as const;
    }
    await input.db.markEmbeddingJobFailed?.({
      jobId: input.job.id,
      attempt: nextAttempt,
      errorCode: normalized.errorCode,
      errorMessage: normalized.errorMessage,
    });
    await input.db.markAssetEmbeddingFailed?.({
      assetId: input.job.assetId,
      metadataVersion: input.job.metadataVersion,
      errorCode: normalized.errorCode,
      errorMessage: normalized.errorMessage,
    });
    return "failed" as const;
  }
}

async function enqueueAssetIndexing(db: Awaited<ReturnType<DatasetStateService["current"]>>, assetId: string) {
  const prepared = await db.prepareAssetForIndexing?.(assetId);
  if (!prepared) return { enqueued: false, reason: "asset_not_found" };
  const enqueued = await db.enqueueEmbeddingJob?.({
    assetId: prepared.assetId,
    metadataVersion: prepared.metadataVersion,
    maxAttempts: 5,
  });
  return {
    enqueued: enqueued?.enqueued === true,
    metadataVersion: prepared.metadataVersion,
    jobId: enqueued?.jobId || "",
  };
}

function buildAssetSearchText(asset: SampleAsset) {
  const parts = [
    asset.title || "",
    asset.description || "",
    asset.type || "",
    ...(asset.tags || []),
    asset.capturedAt || "",
  ];
  return parts.join(" ").trim();
}

function rerankSearchResults(recall: SearchRecallResult[], query: string, filters: SearchFilters) {
  return recall
    .map((entry) => {
      const semantic = normalizeSemanticScore(entry.semanticScore);
      const tagScore = filters.tags?.length ? tagMatchRatio(entry.asset.tags || [], filters.tags) : 0;
      const typeScore = filters.types?.length ? (filters.types.includes(entry.asset.type) ? 1 : 0) : 0;
      const recencyScore = recencyNormalized(entry.asset.capturedAt);
      const textScore = textTokenMatch(entry.asset, query);
      const score = semantic * 0.55 + textScore * 0.15 + tagScore * 0.15 + typeScore * 0.1 + recencyScore * 0.05;
      return {
        ...entry,
        score,
      };
    })
    .sort((a, b) => b.score - a.score);
}

function buildMatchReasons(asset: SampleAsset, query: string, filters: SearchFilters) {
  const reasons: string[] = [];
  const tokens = tokenize(query);
  const text = `${asset.title || ""} ${asset.description || ""} ${(asset.tags || []).join(" ")}`.toLowerCase();
  const tokenHits = tokens.filter((token) => text.includes(token));
  if (tokenHits.length > 0) {
    reasons.push(`文本语义匹配：${tokenHits.slice(0, 2).join(" / ")}`);
  }
  if (filters.tags?.length) {
    const matched = filters.tags.filter((tag) => asset.tags?.includes(tag));
    if (matched.length) reasons.push(`标签匹配：${matched.slice(0, 2).join(" / ")}`);
  }
  if (filters.types?.length && filters.types.includes(asset.type)) {
    reasons.push(`类型匹配：${asset.type}`);
  }
  if ((filters.capturedFrom || filters.capturedTo) && asset.capturedAt) {
    reasons.push(`时间范围匹配：${asset.capturedAt.slice(0, 10)}`);
  }
  if (!reasons.length) reasons.push("语义相似匹配");
  return reasons.slice(0, 2);
}

function normalizeSearchFilters(filters: SearchFilters | undefined): SearchFilters {
  return {
    types: (filters?.types || []).map((value) => String(value).trim()).filter(Boolean),
    tags: (filters?.tags || []).map((value) => String(value).trim()).filter(Boolean),
    capturedFrom: filters?.capturedFrom ? String(filters.capturedFrom).trim() : "",
    capturedTo: filters?.capturedTo ? String(filters.capturedTo).trim() : "",
  };
}

function validateCapturedRange(filters: SearchFilters) {
  if (!filters.capturedFrom || !filters.capturedTo) return "";
  const from = new Date(filters.capturedFrom).getTime();
  const to = new Date(filters.capturedTo).getTime();
  if (!Number.isFinite(from) || !Number.isFinite(to)) return "Captured time range is invalid.";
  if (from > to) return "capturedFrom must be earlier than capturedTo.";
  return "";
}

function normalizeSemanticScore(score: number) {
  if (!Number.isFinite(score)) return 0;
  const raw = score >= -1 && score <= 1 ? (score + 1) / 2 : score;
  return clamp(raw, 0, 1);
}

function recencyNormalized(capturedAt?: string) {
  if (!capturedAt) return 0;
  const ts = new Date(capturedAt).getTime();
  if (!Number.isFinite(ts)) return 0;
  const days = Math.max(0, (Date.now() - ts) / 86_400_000);
  return clamp(1 - days / 3650, 0, 1);
}

function tagMatchRatio(assetTags: string[], requiredTags: string[]) {
  if (!requiredTags.length) return 0;
  const matched = requiredTags.filter((tag) => assetTags.includes(tag)).length;
  return matched / requiredTags.length;
}

function textTokenMatch(asset: SampleAsset, query: string) {
  const tokens = tokenize(query);
  if (!tokens.length) return 0;
  const text = `${asset.title || ""} ${asset.description || ""} ${(asset.tags || []).join(" ")}`.toLowerCase();
  const matched = tokens.filter((token) => text.includes(token)).length;
  return matched / tokens.length;
}

function tokenize(text: string) {
  return String(text || "")
    .toLowerCase()
    .split(/[\s,.;:!?()[\]{}"'`，。；：！？、]+/)
    .map((token) => token.trim())
    .filter(Boolean);
}

function clamp(value: number, min: number, max: number) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

function normalizeEmbeddingError(error: unknown) {
  const errorRecord = error && typeof error === "object" ? error as { code?: unknown; message?: unknown } : {};
  const codeRaw = String(errorRecord.code || "").trim();
  const messageRaw = String(errorRecord.message || "embedding_failed").trim();
  const haystack = `${codeRaw} ${messageRaw}`.toLowerCase();
  const retryable = (
    haystack.includes("timeout")
    || haystack.includes("timedout")
    || haystack.includes("rate limit")
    || haystack.includes("429")
    || haystack.includes("econnreset")
    || /(?:^|\s)5\d\d(?:\s|$)/.test(haystack)
  );
  const errorCode = retryable ? "EMBEDDING_RETRYABLE" : "EMBEDDING_FAILED";
  return {
    retryable,
    errorCode,
    errorMessage: messageRaw || "embedding_failed",
  };
}

async function findChild(db: Awaited<ReturnType<DatasetStateService["current"]>>, childId: string) {
  const direct = await db.getChild?.(childId);
  if (direct) return direct;
  return (await db.getChildren()).find((child: Child) => child.id === childId) || null;
}

function sanitizeChildId(value: string) {
  const safe = value.trim().replace(/[^a-zA-Z0-9_-]/g, "-").replace(/-+/g, "-");
  return safe && safe !== "." && safe !== ".." ? safe : "child-default";
}

async function deterministicEmbedText(text: string) {
  const tokens = tokenize(text);
  const payload = tokens.length ? tokens : ["__empty__"];
  const vector = new Array(EMBEDDING_DIMENSION).fill(0);
  for (const [tokenIndex, token] of payload.entries()) {
    const seed = fnv1a(`${token}:${tokenIndex}`);
    const idx = seed % EMBEDDING_DIMENSION;
    const direction = (seed & 1) === 0 ? 1 : -1;
    vector[idx] += direction * (1 + (token.length % 3) * 0.25);
  }
  let norm = 0;
  for (const value of vector) norm += value * value;
  norm = Math.sqrt(norm);
  if (norm === 0) return vector;
  return vector.map((value) => value / norm);
}

function fnv1a(input: string) {
  let hash = 0x811c9dc5;
  for (let index = 0; index < input.length; index += 1) {
    hash ^= input.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193);
  }
  return hash >>> 0;
}
