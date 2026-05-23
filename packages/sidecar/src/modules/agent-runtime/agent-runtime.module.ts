import { Module } from "@nestjs/common";
import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { AgentConfigModule } from "../agent-config/agent-config.module.ts";
import { AgentRuntimeService } from "./agent-runtime.service.ts";

@Module({
  imports: [InfrastructureModule, AgentConfigModule],
  providers: [AgentRuntimeService],
  exports: [AgentRuntimeService],
})
export class KidMemoryAgentRuntimeModule {}
