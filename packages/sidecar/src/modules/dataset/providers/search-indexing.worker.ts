import { Inject, Injectable, Logger, OnModuleDestroy, OnModuleInit } from "@nestjs/common";

import { DatasetService } from "../dataset.service.ts";

const DEFAULT_INDEXING_INTERVAL_MS = 3_000;
const DEFAULT_INDEXING_BATCH_SIZE = 10;

@Injectable()
export class SearchIndexingWorkerService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(SearchIndexingWorkerService.name);
  private timer: NodeJS.Timeout | null = null;
  private running = false;

  constructor(@Inject(DatasetService) private readonly datasetService: DatasetService) {}

  onModuleInit() {
    if (this.isWorkerDisabled()) {
      this.logger.log("Search indexing worker disabled by env");
      return;
    }
    const intervalMs = this.resolveIntervalMs();
    this.logger.log(`Starting search indexing worker (interval=${intervalMs}ms)`);
    this.timer = setInterval(() => {
      void this.consumeOnce();
    }, intervalMs);
    void this.consumeOnce();
  }

  onModuleDestroy() {
    if (!this.timer) return;
    clearInterval(this.timer);
    this.timer = null;
    this.logger.log("Search indexing worker stopped");
  }

  private async consumeOnce() {
    if (this.running) return;
    this.running = true;
    try {
      const result = await this.datasetService.runSearchIndexer({
        limit: this.resolveBatchSize(),
      });
      if (result.processed > 0 || result.failed > 0 || result.retried > 0) {
        this.logger.log(
          `Indexing run: processed=${result.processed}, succeeded=${result.succeeded}, retried=${result.retried}, failed=${result.failed}, skipped=${result.skipped}`,
        );
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      this.logger.warn(`Search indexing worker tick failed: ${message}`);
    } finally {
      this.running = false;
    }
  }

  private isWorkerDisabled() {
    const value = String(process.env.KIDMEMORY_DISABLE_INDEXING_WORKER || "").trim().toLowerCase();
    return value === "1" || value === "true" || value === "yes" || value === "on";
  }

  private resolveIntervalMs() {
    const value = Number(process.env.KIDMEMORY_INDEXING_INTERVAL_MS || DEFAULT_INDEXING_INTERVAL_MS);
    return Number.isFinite(value) && value > 0 ? Math.floor(value) : DEFAULT_INDEXING_INTERVAL_MS;
  }

  private resolveBatchSize() {
    const value = Number(process.env.KIDMEMORY_INDEXING_BATCH_SIZE || DEFAULT_INDEXING_BATCH_SIZE);
    return Number.isFinite(value) && value > 0 ? Math.floor(value) : DEFAULT_INDEXING_BATCH_SIZE;
  }
}
