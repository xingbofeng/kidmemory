import { Injectable } from "@nestjs/common";

import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { PrismaMigrationService } from "../../infrastructure/database/prisma-migration.service.ts";
import { PrismaService } from "../../infrastructure/database/prisma.service.ts";
import { createSupabaseStorageProvider } from "../storage/providers/supabase-storage.ts";
import { createConfigReadinessService } from "./providers/config.domain.ts";

type ConfigReadinessDelegate = ReturnType<typeof createConfigReadinessService>;

@Injectable()
export class ConfigService {
  private readonly config: AppConfigService;
  private readonly prisma: PrismaService;
  private readonly migrations: PrismaMigrationService;
  private readonly storageFetch: typeof fetch;
  private readinessDelegate?: ConfigReadinessDelegate;

  constructor(
    config: AppConfigService,
    prisma: PrismaService,
    migrations?: PrismaMigrationService,
    storageFetch?: typeof fetch,
  ) {
    this.config = config;
    this.prisma = prisma;
    this.migrations = migrations ?? new PrismaMigrationService(config);
    this.storageFetch = storageFetch ?? fetch;
  }

  private get delegate(): ConfigReadinessDelegate {
    if (!this.readinessDelegate) {
      this.readinessDelegate = createConfigReadinessService({
        config: this.config.config,
        prisma: this.prisma,
        migrations: this.migrations,
      });
    }
    return this.readinessDelegate;
  }

  health() { return this.delegate.health(); }
  status() { return this.delegate.status(); }
  uiConfig() { return this.delegate.uiConfig(); }
  updatePaths(body: Record<string, unknown> = {}) {
    const paths = this.config.updatePaths({
      rootDir: stringFromBody(body.rootDir),
      dataDir: stringFromBody(body.dataDir),
      workspaceDir: stringFromBody(body.workspaceDir),
      exportDir: stringFromBody(body.exportDir),
    });
    return { ok: true, paths };
  }
  updatePostgres(body: Record<string, unknown> = {}) {
    const config = this.config.updatePostgresConfig({
      host: stringFromBody(body.host),
      database: stringFromBody(body.database),
      user: stringFromBody(body.user),
      password: stringFromBody(body.password),
      connectionUrl: stringFromBody(body.connectionUrl),
      port: numberFromBody(body.port),
    });
    return { ok: true, config };
  }
  updateOpenAI(body: Record<string, unknown> = {}) {
    const config = this.config.updateOpenAIConfig({
      baseUrl: stringFromBody(body.baseUrl),
      apiKey: stringFromBody(body.apiKey),
      model: stringFromBody(body.model),
    });
    return { ok: true, config };
  }
  updateSupabaseStorage(body: Record<string, unknown> = {}) {
    this.config.updateSupabaseStorageConfig({
      url: stringFromBody(body.url),
      bucket: stringFromBody(body.bucket),
      serviceRoleKey: stringFromBody(body.serviceRoleKey),
      publicBaseUrl: stringFromBody(body.publicBaseUrl),
      signedUrlTtlSeconds: numberFromBody(body.signedUrlTtlSeconds),
      s3: {
        endpoint: stringFromBody(body.s3Endpoint),
        region: stringFromBody(body.s3Region),
        accessKeyId: stringFromBody(body.s3AccessKeyId),
        secretAccessKey: stringFromBody(body.s3SecretAccessKey),
      },
    });
    return {
      ok: true,
      config: this.status().supabaseStorage,
    };
  }
  testSupabaseStorage() {
    return createSupabaseStorageProvider({
      config: this.config.config.supabaseStorage,
      fetch: this.storageFetch,
    }).testConnection();
  }
  postgresReadiness() { return this.delegate.postgresReadiness(); }
  openAIReadiness() { return this.delegate.openAIReadiness(); }
  claudeReadiness() { return this.delegate.claudeReadiness(); }
  pgVectorReadiness() { return this.delegate.pgVectorReadiness(); }
  initializeSchema() { return this.delegate.initializeSchema(); }
}

function stringFromBody(value: unknown) {
  return typeof value === "string" ? value : undefined;
}

function numberFromBody(value: unknown) {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string") {
    const parsed = Number.parseInt(value.trim(), 10);
    return Number.isFinite(parsed) ? parsed : undefined;
  }
  return undefined;
}
