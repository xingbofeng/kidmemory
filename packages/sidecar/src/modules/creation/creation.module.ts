import { Module } from "@nestjs/common";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { AgentConfigModule } from "../agent-config/agent-config.module.ts";
import { KidMemoryAgentRuntimeModule } from "../agent-runtime/agent-runtime.module.ts";
import { DatasetModule } from "../dataset/dataset.module.ts";
import { CreationController } from "./creation.controller.ts";
import { CreationService } from "./creation.service.ts";

@Module({
  imports: [InfrastructureModule, AgentConfigModule, KidMemoryAgentRuntimeModule, DatasetModule],
  controllers: [CreationController],
  providers: [CreationService],
  exports: [CreationService],
})
export class CreationModule {}
