import { Body, Controller, Get, Inject, Post } from "@nestjs/common";

import { parseDto } from "../../infrastructure/validation/parse-dto.ts";
import { ConfigService } from "./config.service.ts";
import { UpdateOpenAIDtoSchema, type UpdateOpenAIDto } from "./dto/update-openai.dto.ts";
import { UpdatePathsDtoSchema, type UpdatePathsDto } from "./dto/update-paths.dto.ts";
import { UpdatePostgresDtoSchema, type UpdatePostgresDto } from "./dto/update-postgres.dto.ts";
import {
  UpdateSupabaseStorageDtoSchema,
  type UpdateSupabaseStorageDto,
} from "./dto/update-supabase-storage.dto.ts";

export class ConfigController {
  private readonly configService: ConfigService;

  constructor(configService: ConfigService) {
    this.configService = configService;
  }

  health() { return this.configService.health(); }
  status() { return this.configService.status(); }
  uiConfig() { return this.configService.uiConfig(); }
  updatePaths(body: unknown) {
    const dto = parseDto<UpdatePathsDto>(UpdatePathsDtoSchema, body, "config/paths");
    return this.configService.updatePaths(dto);
  }
  updatePostgres(body: unknown) {
    const dto = parseDto<UpdatePostgresDto>(UpdatePostgresDtoSchema, body, "config/postgres");
    return this.configService.updatePostgres(dto);
  }
  updateOpenAI(body: unknown) {
    const dto = parseDto<UpdateOpenAIDto>(UpdateOpenAIDtoSchema, body, "config/openai");
    return this.configService.updateOpenAI(dto);
  }
  updateSupabaseStorage(body: unknown) {
    const dto = parseDto<UpdateSupabaseStorageDto>(
      UpdateSupabaseStorageDtoSchema,
      body,
      "config/supabase-storage",
    );
    return this.configService.updateSupabaseStorage(dto);
  }
  testSupabaseStorage() { return this.configService.testSupabaseStorage(); }
  postgresReadiness() { return this.configService.postgresReadiness(); }
  openAIReadiness() { return this.configService.openAIReadiness(); }
  claudeReadiness() { return this.configService.claudeReadiness(); }
  pgVectorReadiness() { return this.configService.pgVectorReadiness(); }
  initializeSchema() { return this.configService.initializeSchema(); }
}

Inject(ConfigService)(ConfigController, undefined, 0);
Controller()(ConfigController);
Get("health")(ConfigController.prototype, "health", Object.getOwnPropertyDescriptor(ConfigController.prototype, "health")!);
Get("config/status")(ConfigController.prototype, "status", Object.getOwnPropertyDescriptor(ConfigController.prototype, "status")!);
Get("config/ui")(ConfigController.prototype, "uiConfig", Object.getOwnPropertyDescriptor(ConfigController.prototype, "uiConfig")!);
Post("config/paths")(ConfigController.prototype, "updatePaths", Object.getOwnPropertyDescriptor(ConfigController.prototype, "updatePaths")!);
Body()(ConfigController.prototype, "updatePaths", 0);
Post("config/postgres")(ConfigController.prototype, "updatePostgres", Object.getOwnPropertyDescriptor(ConfigController.prototype, "updatePostgres")!);
Body()(ConfigController.prototype, "updatePostgres", 0);
Post("config/openai")(ConfigController.prototype, "updateOpenAI", Object.getOwnPropertyDescriptor(ConfigController.prototype, "updateOpenAI")!);
Body()(ConfigController.prototype, "updateOpenAI", 0);
Post("config/supabase-storage")(ConfigController.prototype, "updateSupabaseStorage", Object.getOwnPropertyDescriptor(ConfigController.prototype, "updateSupabaseStorage")!);
Body()(ConfigController.prototype, "updateSupabaseStorage", 0);
Post("config/supabase-storage/test")(ConfigController.prototype, "testSupabaseStorage", Object.getOwnPropertyDescriptor(ConfigController.prototype, "testSupabaseStorage")!);
Post("config/check/postgres")(ConfigController.prototype, "postgresReadiness", Object.getOwnPropertyDescriptor(ConfigController.prototype, "postgresReadiness")!);
Post("config/check/openai")(ConfigController.prototype, "openAIReadiness", Object.getOwnPropertyDescriptor(ConfigController.prototype, "openAIReadiness")!);
Post("config/check/claude")(ConfigController.prototype, "claudeReadiness", Object.getOwnPropertyDescriptor(ConfigController.prototype, "claudeReadiness")!);
Post("config/check/pgvector")(ConfigController.prototype, "pgVectorReadiness", Object.getOwnPropertyDescriptor(ConfigController.prototype, "pgVectorReadiness")!);
Post("schema/init")(ConfigController.prototype, "initializeSchema", Object.getOwnPropertyDescriptor(ConfigController.prototype, "initializeSchema")!);
