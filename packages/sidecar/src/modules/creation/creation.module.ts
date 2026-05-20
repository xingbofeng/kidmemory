import { Module } from "@nestjs/common";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { AgentConfigModule } from "../agent-config/agent-config.module.ts";
import { BooksModule } from "../books/books.module.ts";
import { DatasetModule } from "../dataset/dataset.module.ts";
import { MediaModule } from "../media/media.module.ts";
import { SkillsModule } from "../skills/skills.module.ts";
import { CreationController } from "./creation.controller.ts";
import { CreationPlanningService } from "./creation-planning.service.ts";
import { CreationService } from "./creation.service.ts";

@Module({
  imports: [InfrastructureModule, AgentConfigModule, BooksModule, DatasetModule, MediaModule, SkillsModule],
  controllers: [CreationController],
  providers: [CreationService, CreationPlanningService],
  exports: [CreationService, CreationPlanningService],
})
export class CreationModule {}
