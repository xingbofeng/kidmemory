import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { PrismaMigrationService } from "../../infrastructure/database/prisma-migration.service.ts";
import { PrismaService } from "../../infrastructure/database/prisma.service.ts";
import { registerInjectable } from "../../infrastructure/nest/register-injectable.ts";
import { createSupabaseStorageProvider } from "../storage/providers/supabase-storage.ts";
import { createConfigReadinessService } from "./providers/config.domain.ts";

type ConfigReadinessDelegate = ReturnType<typeof createConfigReadinessService>;

type ConfigServiceFactories = {
  createReadiness?: (input: {
    config: AppConfigService;
    prisma: PrismaService;
    migrations: PrismaMigrationService;
  }) => ConfigReadinessDelegate;
};

export class ConfigService {
  private readonly config: AppConfigService;
  private readonly prisma: PrismaService;
  private readonly migrations: PrismaMigrationService;
  private readonly storageFetch: typeof fetch;
  private readonly createReadiness: NonNullable<ConfigServiceFactories["createReadiness"]>;
  private readinessDelegate?: ConfigReadinessDelegate;

  constructor(
    config: AppConfigService,
    prisma: PrismaService,
    migrationsOrFetch: PrismaMigrationService | typeof fetch = new PrismaMigrationService(config),
    storageFetchOrFactories: typeof fetch | ConfigServiceFactories = fetch,
    factories: ConfigServiceFactories = {},
  ) {
    this.config = config;
    this.prisma = prisma;
    if (typeof migrationsOrFetch === "function") {
      this.migrations = new PrismaMigrationService(config);
      this.storageFetch = migrationsOrFetch;
      factories = isFactories(storageFetchOrFactories) ? storageFetchOrFactories : factories;
    } else {
      this.migrations = migrationsOrFetch;
      this.storageFetch = typeof storageFetchOrFactories === "function" ? storageFetchOrFactories : fetch;
      factories = isFactories(storageFetchOrFactories) ? storageFetchOrFactories : factories;
    }
    this.createReadiness =
      factories.createReadiness
      ?? (({ config: appConfig, prisma, migrations }) =>
        createConfigReadinessService({ config: appConfig.config, prisma, migrations }));
  }

  private get delegate(): ConfigReadinessDelegate {
    if (!this.readinessDelegate) {
      this.readinessDelegate = this.createReadiness({
        config: this.config,
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

registerInjectable(ConfigService, [AppConfigService, PrismaService, PrismaMigrationService]);

function isFactories(value: unknown): value is ConfigServiceFactories {
  return Boolean(value)
    && typeof value === "object"
    && ("createReadiness" in value);
}
