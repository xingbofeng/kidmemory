import { Body, Controller, Get, Inject, Post } from "@nestjs/common";

import { parseDto } from "../../infrastructure/validation/parse-dto.ts";
import { ConfigService } from "./config.service.ts";
import { UpdatePathsDtoSchema } from "./dto/update-paths.dto.ts";
import { UpdatePostgresDtoSchema } from "./dto/update-postgres.dto.ts";
import {
  UpdateSupabaseStorageDtoSchema,
} from "./dto/update-supabase-storage.dto.ts";

@Controller()
export class ConfigController {
  constructor(@Inject(ConfigService) private readonly configService: ConfigService) {}

  @Get("health")
  health() { return this.configService.health(); }

  @Get("config/status")
  status() { return this.configService.status(); }

  @Get("config/ui")
  uiConfig() { return this.configService.uiConfig(); }

  @Post("config/paths")
  updatePaths(@Body() body: unknown) {
    const dto = parseDto(UpdatePathsDtoSchema, body, "config/paths");
    return this.configService.updatePaths(dto);
  }

  @Post("config/postgres")
  updatePostgres(@Body() body: unknown) {
    const dto = parseDto(UpdatePostgresDtoSchema, body, "config/postgres");
    return this.configService.updatePostgres(dto);
  }

  @Post("config/supabase-storage")
  updateSupabaseStorage(@Body() body: unknown) {
    const dto = parseDto(
      UpdateSupabaseStorageDtoSchema,
      body,
      "config/supabase-storage",
    );
    return this.configService.updateSupabaseStorage(dto);
  }

  @Post("config/supabase-storage/test")
  testSupabaseStorage() { return this.configService.testSupabaseStorage(); }

  @Post("config/check/postgres")
  postgresReadiness() { return this.configService.postgresReadiness(); }

  @Post("config/check/claude")
  claudeReadiness() { return this.configService.claudeReadiness(); }

  @Post("config/check/pgvector")
  pgVectorReadiness() { return this.configService.pgVectorReadiness(); }

  @Post("schema/init")
  initializeSchema() { return this.configService.initializeSchema(); }
}
