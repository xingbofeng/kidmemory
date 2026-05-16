import { Module } from "@nestjs/common";

import { AppConfigService } from "./config/app-config.service.ts";
import { DatasetStateService } from "./dataset-state/dataset-state.service.ts";
import { PrismaDatasetDbService } from "./dataset-state/prisma-dataset-db.service.ts";
import { PrismaMigrationService } from "./database/prisma-migration.service.ts";
import { PrismaService } from "./database/prisma.service.ts";
import { FileJobStoreService } from "./jobs/file-job-store.service.ts";
import { FileLoggerService } from "./logging/file-logger.service.ts";
import { LogCleanupWorker } from "./logging/log-cleanup.worker.ts";
import { TraceContextService } from "./logging/trace-context.service.ts";
import { TraceRequestLoggingMiddleware } from "./http/trace-request-logging.middleware.ts";
import { SecurityMonitorController } from "./security/security-monitor.controller.ts";
import { RateLimitMiddleware } from "./security/rate-limit.middleware.ts";
import { SessionQuotaMiddleware } from "./security/session-quota.middleware.ts";
import { InputValidationMiddleware } from "./security/input-validation.middleware.ts";

export class InfrastructureModule {}

Module({
  controllers: [SecurityMonitorController],
  providers: [
    AppConfigService,
    PrismaService,
    PrismaMigrationService,
    PrismaDatasetDbService,
    FileJobStoreService,
    FileLoggerService,
    TraceContextService,
    LogCleanupWorker,
    TraceRequestLoggingMiddleware,
    DatasetStateService,
    RateLimitMiddleware,
    SessionQuotaMiddleware,
    InputValidationMiddleware,
  ],
  exports: [
    AppConfigService,
    PrismaService,
    PrismaMigrationService,
    PrismaDatasetDbService,
    FileJobStoreService,
    FileLoggerService,
    TraceContextService,
    LogCleanupWorker,
    TraceRequestLoggingMiddleware,
    DatasetStateService,
    RateLimitMiddleware,
    SessionQuotaMiddleware,
    InputValidationMiddleware,
  ],
})(InfrastructureModule);
