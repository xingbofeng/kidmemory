import { Module } from "@nestjs/common";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { DatasetController } from "./dataset.controller.ts";
import { DatasetService } from "./dataset.service.ts";

@Module({
  imports: [InfrastructureModule],
  controllers: [DatasetController],
  providers: [DatasetService],
  exports: [DatasetService],
})
export class DatasetModule {}

