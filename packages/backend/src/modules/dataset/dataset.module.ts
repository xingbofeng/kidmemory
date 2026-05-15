import { Module } from "@nestjs/common";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { DatasetController } from "./dataset.controller.ts";
import { DatasetService } from "./dataset.service.ts";

export class DatasetModule {}

Module({
  imports: [InfrastructureModule],
  controllers: [DatasetController],
  providers: [DatasetService],
  exports: [DatasetService],
})(DatasetModule);
