import { Module } from "@nestjs/common";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { ConfigController } from "./config.controller.ts";
import { ConfigService } from "./config.service.ts";

export class ConfigModule {}

Module({
  imports: [InfrastructureModule],
  controllers: [ConfigController],
  providers: [ConfigService],
  exports: [ConfigService],
})(ConfigModule);
