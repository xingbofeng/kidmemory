import { Module } from "@nestjs/common";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { SearchIndexingWorkerService } from "./providers/search-indexing.worker.ts";
import { DatasetController } from "./dataset.controller.ts";
import { DATASET_SERVICE_FACTORIES, DatasetService } from "./dataset.service.ts";

@Module({
  imports: [InfrastructureModule],
  controllers: [DatasetController],
  providers: [
    DatasetService,
    SearchIndexingWorkerService,
    {
      provide: DATASET_SERVICE_FACTORIES,
      useValue: {},
    },
  ],
  exports: [DatasetService],
})
export class DatasetModule {}
