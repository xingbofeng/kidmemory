import { Module } from "@nestjs/common";

import { AppConfigService } from "./config/app-config.service.ts";
import { DatasetStateService } from "./dataset-state/dataset-state.service.ts";
import { PrismaDatasetDbService } from "./dataset-state/prisma-dataset-db.service.ts";
import { PrismaMigrationService } from "./database/prisma-migration.service.ts";
import { PrismaService } from "./database/prisma.service.ts";
import { FileJobStoreService } from "./jobs/file-job-store.service.ts";

export class InfrastructureModule {}

Module({
  providers: [AppConfigService, PrismaService, PrismaMigrationService, PrismaDatasetDbService, FileJobStoreService, DatasetStateService],
  exports: [AppConfigService, PrismaService, PrismaMigrationService, PrismaDatasetDbService, FileJobStoreService, DatasetStateService],
})(InfrastructureModule);
