import { Inject, Injectable, Optional } from "@nestjs/common";
import { Prisma } from "@prisma/client";

import {
  AppConfigService,
  type AppConfig,
  type SupabaseStorageUpdateConfig,
} from "../../infrastructure/config/app-config.service.ts";
import { PrismaMigrationService } from "../../infrastructure/database/prisma-migration.service.ts";
import { PrismaService } from "../../infrastructure/database/prisma.service.ts";
import { createSupabaseStorageProvider } from "../storage/providers/supabase-storage.ts";
import { createConfigReadinessService } from "./providers/config.domain.ts";

type ConfigReadinessDelegate = ReturnType<typeof createConfigReadinessService>;
export const CONFIG_STORAGE_FETCH = Symbol("CONFIG_STORAGE_FETCH");
const SUPABASE_STORAGE_RUNTIME_CONFIG_KEY = "supabaseStorage";

@Injectable()
export class ConfigService {
  private readonly config: AppConfigService;
  private readonly prisma: PrismaService;
  private readonly migrations: PrismaMigrationService;
  private readonly storageFetch: typeof fetch;
  private readinessDelegate?: ConfigReadinessDelegate;
  private runtimeConfigHydrated = false;
  private runtimeConfigHydration?: Promise<void>;

  constructor(
    @Inject(AppConfigService) config: AppConfigService,
    @Inject(PrismaService) prisma: PrismaService,
    @Optional() @Inject(PrismaMigrationService) migrations?: PrismaMigrationService,
    @Optional() @Inject(CONFIG_STORAGE_FETCH) storageFetch?: typeof fetch,
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
        migrations: this.migrations,
      });
    }
    return this.readinessDelegate;
  }

  health() { return this.delegate.health(); }
  async status() {
    await this.hydrateRuntimeConfig();
    return this.delegate.status();
  }
  async uiConfig() {
    await this.hydrateRuntimeConfig();
    return this.delegate.uiConfig();
  }
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
  async updateSupabaseStorage(body: Record<string, unknown> = {}) {
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
    await this.persistRuntimeConfig(
      SUPABASE_STORAGE_RUNTIME_CONFIG_KEY,
      this.config.config.supabaseStorage,
    );
    return {
      ok: true,
      config: (await this.status()).supabaseStorage,
    };
  }
  async testSupabaseStorage() {
    await this.hydrateRuntimeConfig();
    return createSupabaseStorageProvider({
      config: this.config.config.supabaseStorage,
      fetch: this.storageFetch,
    }).testConnection();
  }
  postgresReadiness() { return this.delegate.postgresReadiness(); }
  claudeReadiness() { return this.delegate.claudeReadiness(); }
  pgVectorReadiness() { return this.delegate.pgVectorReadiness(); }
  initializeSchema() { return this.delegate.initializeSchema(); }

  private async hydrateRuntimeConfig() {
    if (this.runtimeConfigHydrated) return;
    if (!this.runtimeConfigHydration) {
      this.runtimeConfigHydration = this.loadRuntimeConfigFromDb();
    }
    await this.runtimeConfigHydration;
  }

  private async loadRuntimeConfigFromDb() {
    try {
      const rows = await this.prisma.runtimeConfig.findMany({
        where: {
          key: {
            in: [
              SUPABASE_STORAGE_RUNTIME_CONFIG_KEY,
            ],
          },
        },
      });
      for (const row of rows) {
        if (row.key === SUPABASE_STORAGE_RUNTIME_CONFIG_KEY) {
          this.config.updateSupabaseStorageConfig(
            asRuntimeConfigObject(row.value) as SupabaseStorageUpdateConfig,
          );
        }
      }
      this.runtimeConfigHydrated = true;
    } catch {
      this.runtimeConfigHydration = undefined;
    }
  }

  private async persistRuntimeConfig(key: string, value: unknown) {
    try {
      await this.prisma.runtimeConfig.upsert({
        where: { key },
        create: { key, value: value as Prisma.InputJsonValue },
        update: { value: value as Prisma.InputJsonValue },
      });
    } catch {
      // Configuration still updates in memory when the database is not ready.
    }
  }
}

function asRuntimeConfigObject(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {};
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
