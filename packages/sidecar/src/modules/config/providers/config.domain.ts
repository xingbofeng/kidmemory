import type { AppConfig } from "../../../infrastructure/config/app-config.service.ts";
import type { PrismaMigrationService } from "../../../infrastructure/database/prisma-migration.service.ts";
import type { PrismaService } from "../../../infrastructure/database/prisma.service.ts";
import { redactConfig } from "../../../infrastructure/config/app-config.service.ts";
import {
  checkClaudeReadiness,
  checkPgVector,
  checkPostgres,
} from "./readiness.ts";

type ConfigReadinessDependencies = {
  config: AppConfig;
  prisma: PrismaService;
  migrations: PrismaMigrationService;
};

export function createConfigReadinessService(
  dependencies: ConfigReadinessDependencies,
) {
  const setupChecks = [
    {
      index: "1",
      title: "PostgreSQL 配置",
      purpose: "为 KidMemory 提供核心数据库连接，保存孩子资料、素材和生成历史。",
      body:
        "为 KidMemory 提供核心数据库连接，保存孩子资料、素材和生成历史。",
      action: "配置",
      state: "待检测",
    },
    {
      index: "2",
      title: "pgvector 检测",
      purpose: "pgvector 是 PostgreSQL 的独立扩展，用于语义检索与相似素材匹配。",
      body:
        "pgvector 是 PostgreSQL 的独立扩展，需单独安装并在数据库中启用。",
      action: "检测 pgvector",
      state: "待检测",
    },
    {
      index: "3",
      title: "大模型接口配置",
      purpose: "提供文本生成、讲故事和提示词能力。",
      body:
        `提供文本生成、讲故事和提示词能力。`,
      action: "配置",
      state: dependencies.config.openai.apiKey ? "待检测" : "需配置",
    },
    {
      index: "4",
      title: "本地数据目录",
      purpose: "统一管理向量索引、元数据缓存和导出文件。",
      body: localDataDirectoryBody(dependencies.config),
      action: "配置目录",
      state: "已配置",
      ok: true,
    },
  ];

  const typeOptions = [
    { value: "all", label: "全部" },
    { value: "artwork", label: "绘画" },
    { value: "photo", label: "照片" },
    { value: "craft", label: "手工" },
  ];

  const generationSettings = {
    templates: ["温暖童趣", "童话式成长记忆", "简约纪实"],
    pageSizes: [
      "A4 竖版  210 × 297 mm",
      "A4 横版  297 × 210 mm",
      "A3 竖版  297 × 420 mm",
    ],
    styles: [
      "温暖童趣  亲切温暖，适合儿童阅读",
      "童话叙事  文字更具故事感",
      "纪实风  中性偏学术表达",
    ],
    exportTargets: [
      "PDF 文件  高质量 PDF（打印级别）",
      "长图 PNG  适合移动分享",
      "长图 JPG  体积更小",
    ],
    defaults: {
      template: "温暖童趣",
      pageSize: "A4 竖版  210 × 297 mm",
      style: "温暖童趣  亲切温暖，适合儿童阅读",
      exportTarget: "PDF 文件  高质量 PDF（打印级别）",
    },
  };

  return {
    health() {
      return { ok: true, service: "kidmemory-sidecar" };
    },
    status() {
      return redactConfig(dependencies.config);
    },
    uiConfig() {
      return {
        setup: { checks: setupChecks },
        search: { typeOptions },
        assetLibrary: { typeOptions },
        generate: generationSettings,
      };
    },
    postgresReadiness() {
      return checkPostgres(dependencies.config.postgres);
    },
    claudeReadiness() {
      return checkClaudeReadiness(dependencies.config.claude);
    },
    pgVectorReadiness() {
      return checkPgVector(dependencies.config.postgres);
    },
    async initializeSchema() {
      try {
        return await dependencies.migrations.deployWithRepair();
      } catch (error) {
        return {
          ok: false,
          service: "prisma-migrate",
          message: `Schema initialization failed: ${sanitizeSchemaError(error)}`,
          action: "Check local PostgreSQL configuration, then retry Prisma migrations.",
        };
      }
    },
  };
}

function localDataDirectoryBody(config: AppConfig) {
  return [
    "统一管理向量索引、元数据缓存和导出文件。",
    `数据目录：${config.paths.dataDir}`,
    `Workspace：${config.paths.workspaceDir}`,
    `导出目录：${config.paths.exportDir}`,
  ].join("\n");
}

function sanitizeSchemaError(error: unknown) {
  return error instanceof Error
    ? error.message
        .replace(/sk-[A-Za-z0-9_-]+/g, "[redacted]")
        .replace(/password=[^ ]+/gi, "password=[redacted]")
    : "unknown error";
}
