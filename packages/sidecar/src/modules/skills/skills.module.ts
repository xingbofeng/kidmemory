import { Module } from "@nestjs/common";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { BooksModule } from "../books/books.module.ts";
import { ConfigModule } from "../config/config.module.ts";
import { DatasetModule } from "../dataset/dataset.module.ts";
import { MediaModule } from "../media/media.module.ts";
import { SkillLoaderService } from "./skill-loader.service.ts";
import { SkillPermissionService } from "./skill-permission.service.ts";
import { SkillRegistryService } from "./skill-registry.service.ts";
import { SkillRuntimeService } from "./skill-runtime.service.ts";
import { SkillWorkspaceService } from "./skill-workspace.service.ts";

@Module({
  imports: [InfrastructureModule, ConfigModule, DatasetModule, BooksModule, MediaModule],
  providers: [
    SkillLoaderService,
    SkillRegistryService,
    SkillWorkspaceService,
    SkillPermissionService,
    SkillRuntimeService,
  ],
  exports: [
    SkillLoaderService,
    SkillRegistryService,
    SkillWorkspaceService,
    SkillPermissionService,
    SkillRuntimeService,
  ],
})
export class SkillsModule {}
