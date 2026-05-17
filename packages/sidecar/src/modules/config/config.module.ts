import { Module } from "@nestjs/common";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { ConfigController } from "./config.controller.ts";
import { CONFIG_STORAGE_FETCH, ConfigService } from "./config.service.ts";

@Module({
  imports: [InfrastructureModule],
  controllers: [ConfigController],
  providers: [
    ConfigService,
    {
      provide: CONFIG_STORAGE_FETCH,
      useValue: fetch,
    },
  ],
  exports: [ConfigService],
})
export class ConfigModule {}
