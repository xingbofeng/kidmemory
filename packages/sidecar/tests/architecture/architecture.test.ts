import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");

function listTsFiles(dir: string): string[] {
  const result: string[] = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      result.push(...listTsFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith(".ts")) {
      result.push(fullPath);
    }
  }
  return result;
}

test("prisma migrations are present for deploy-time schema management", () => {
  const migrationsDir = path.join(root, "prisma", "migrations");
  const migrationFile = path.join(migrationsDir, "init", "migration.sql");
  const lockFile = path.join(migrationsDir, "migration_lock.toml");
  const migration = fs.readFileSync(migrationFile, "utf8");
  const lock = fs.readFileSync(lockFile, "utf8");

  assert.match(lock, /provider = "postgresql"/);
  assert.match(migration, /CREATE EXTENSION IF NOT EXISTS vector/);
  assert.match(migration, /CREATE TABLE "children"/);
  assert.match(migration, /CREATE TABLE "assets"/);
  assert.match(migration, /CREATE TABLE "agent_configs"/);
});

test("legacy hand-written schema files are not runtime schema sources", () => {
  for (const relativePath of [
    "sql",
    "migrations",
    "src/infrastructure/database/migration.service.ts",
    "src/infrastructure/database/schema.ts",
  ]) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), false, `${relativePath} should not remain as a runtime schema source`);
  }
});

test("persistent dataset state uses the Prisma ORM adapter", () => {
  const datasetState = fs.readFileSync(
    path.join(root, "src", "infrastructure", "dataset-state", "dataset-state.service.ts"),
    "utf8",
  );
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "dataset-state", "prisma-dataset-db.service.ts"),
    "utf8",
  );

  assert.match(datasetState, /PrismaDatasetDbService/);
  assert.match(source, /implements SampleDb/);
  assert.match(source, /this\.prisma\.asset\.upsert/);
  assert.match(source, /this\.prisma\.embeddingJob\.create/);
  assert.match(source, /this\.prisma\.storageSyncJob\.create/);
  assert.doesNotMatch(source, /\.\s*(?:query|executeRaw|queryRaw|queryRawUnsafe)\s*\(/);
  assert.doesNotMatch(source, /`[^`]*(?:select|insert|update|delete)\s+/i);
});

test("prisma dataset semantic search stores and scores ORM-managed embeddings", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "dataset-state", "prisma-dataset-db.service.ts"),
    "utf8",
  );
  const schema = fs.readFileSync(path.join(root, "prisma", "schema.prisma"), "utf8");

  assert.match(schema, /embeddingData\s+Json\?\s+@map\("embedding_data"\)/);
  assert.match(source, /this\.prisma\.\$transaction/);
  assert.match(source, /tx\.assetEmbedding\.upsert/);
  assert.match(source, /embeddingData:\s*jsonArray\(input\.embedding\)/);
  assert.match(source, /cosineSimilarity\(input\.vector,\s*embedding\)/);
  assert.doesNotMatch(source, /semanticScore:\s*0\.5/);
});

test("agent execution is isolated to the agent-runtime adapter", () => {
  for (const relativePath of [
    "src/modules/books/providers/agent.ts",
    "src/modules/books/providers/agent-runner-manager.ts",
    "src/modules/books/providers/agent-runner.interface.ts",
    "src/modules/books/providers/claude-agent-runner.ts",
    "src/modules/books/providers/local-agent-runner.ts",
    "src/modules/books/providers/publication-flow.ts",
    "src/modules/books/providers/openai-sdk-agent-runner.ts",
    "src/modules/skills/skill-runtime.service.ts",
    "src/modules/media/hyperframes-render.service.ts",
  ]) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), false, `${relativePath} should not remain in production source`);
  }

  for (const file of listTsFiles(path.join(root, "src"))) {
    const relative = path.relative(root, file);
    if (relative.startsWith("src/modules/agent-runtime/")) continue;
    const source = fs.readFileSync(file, "utf8");
    assert.doesNotMatch(source, /@openai\/agents|OpenAISDKAgentRunner|SkillRuntimeService|HyperframesRenderService/);
  }
});

test("sidecar uses nestjs as the production http runtime", () => {
  for (const relativePath of ["src/modules/config", "src/modules/dataset", "src/infrastructure/config", "src/infrastructure/database", "src/infrastructure/jobs", "src/infrastructure/dataset-state"]) {
    assert.equal(fs.statSync(path.join(root, relativePath)).isDirectory(), true);
  }

  const packageJson = JSON.parse(fs.readFileSync(path.join(root, "package.json"), "utf8"));
  assert.match(packageJson.scripts.build, /node --run lint/);
  assert.match(packageJson.scripts.build, /node --run check:tests/);
  assert.match(packageJson.scripts["check:tests"], /tsx --test/);
  assert.match(packageJson.scripts["check:tests"], /tests/);

  const main = fs.readFileSync(path.join(root, "src", "main.ts"), "utf8");
  assert.match(main, /NestFactory\.create\(AppModule/);
  assert.doesNotMatch(main, /createServer|createSidecarRequestHandler/);
});

test("dataset asset delete API uses only the canonical DELETE route", () => {
  const datasetController = fs.readFileSync(path.join(root, "src", "modules", "dataset", "dataset.controller.ts"), "utf8");

  assert.match(datasetController, /Delete\("assets\/:id"\)/);
  assert.doesNotMatch(datasetController, /Post\("assets\/:id\/delete"\)/);
  assert.doesNotMatch(datasetController, /deleteAssetPost/);
});

test("nestjs services use @Injectable decorator for standard NestJS DI", () => {
  const expected = new Map([
    ["dataset", /@Injectable\(\)\s+export class DatasetService/],
    ["config", /@Injectable\(\)\s+export class ConfigService/],
  ]);

  for (const [feature, decoratorPattern] of expected) {
    const serviceName = `${feature[0].toUpperCase()}${feature.slice(1)}Service`;
    const service = fs.readFileSync(path.join(root, "src", "modules", feature, `${feature}.service.ts`), "utf8");
    assert.match(service, decoratorPattern);
    assert.doesNotMatch(service, /registerInjectable/);
  }
});

test("sidecar follows standard nestjs package and module layout", () => {
  const packageJson = JSON.parse(fs.readFileSync(path.join(root, "package.json"), "utf8"));
  for (const dependency of ["@nestjs/common", "@nestjs/core", "@nestjs/platform-express", "reflect-metadata", "rxjs"]) {
    assert.ok(packageJson.dependencies[dependency], `${dependency} should be declared`);
  }

  for (const relativePath of [
    "src/main.ts",
    "src/app.module.ts",
    "src/infrastructure/infrastructure.module.ts",
    "src/infrastructure/config/app-config.service.ts",
    "src/infrastructure/dataset-state/prisma-dataset-db.service.ts",
    "src/infrastructure/database/prisma-migration.service.ts",
    "src/infrastructure/jobs/file-job-store.service.ts",
    "src/infrastructure/dataset-state/dataset-state.service.ts",
    "src/infrastructure/dataset-state/memory-dataset-db.ts",
    "src/modules/config/config.module.ts",
    "src/modules/config/config.controller.ts",
    "src/modules/config/config.service.ts",
    "src/modules/config/providers/config.domain.ts",
    "src/modules/dataset/dataset.module.ts",
    "src/modules/dataset/dataset.controller.ts",
    "src/modules/dataset/dataset.service.ts",
    "src/modules/dataset/providers/dataset.domain.ts",
  ]) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), true, `${relativePath} should exist`);
  }

  const forbiddenProductionPaths = [
    "src/server.ts",
    "src/main.nest.ts",
    "src/app/router.ts",
    "src/app/api/route-map.ts",
    "src/infrastructure/context",
    "src/infrastructure/context/sidecar-context.service.ts",
    "src/infrastructure/persistence",
    "src/modules/sidecar",
    "src/modules/sidecar/controllers/route-dispatcher.ts",
    "src/modules/sidecar/controllers/config.route.ts",
    "src/modules/sidecar/controllers/dataset.route.ts",
    "src/modules/sidecar/controllers/books.route.ts",
  ];
  for (const relativePath of forbiddenProductionPaths) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), false, `${relativePath} should not remain in production source`);
  }

  const allowedRootProductionFiles = new Set(["app.module.ts", "main.ts"]);
  const rootProductionFiles = fs.readdirSync(path.join(root, "src"))
    .filter((file) => file.endsWith(".ts") && !file.endsWith(".test.ts"));
  assert.deepEqual(rootProductionFiles.sort(), [...allowedRootProductionFiles].sort());
});

test("nestjs feature modules register their own controllers and providers", () => {
  for (const feature of ["config", "dataset", "books"]) {
    const modulePath = path.join(root, "src", "modules", feature, `${feature}.module.ts`);
    const moduleSource = fs.readFileSync(modulePath, "utf8");
    const classPrefix = feature[0].toUpperCase() + feature.slice(1);
    assert.match(moduleSource, new RegExp(`${classPrefix}Controller`));
    assert.match(moduleSource, new RegExp(`${classPrefix}Service`));
    assert.match(moduleSource, /Module\(\{/);
    assert.match(moduleSource, /imports:\s*\[[^\]]*InfrastructureModule/);
    assert.match(moduleSource, /controllers:/);
    assert.match(moduleSource, /providers:/);
    assert.doesNotMatch(moduleSource, /SidecarContextService/);
  }
});

test("feature module roots keep the standard nestjs shape", () => {
  for (const feature of ["config", "dataset", "books"]) {
    const featureDir = path.join(root, "src", "modules", feature);
    const entries = fs.readdirSync(featureDir).sort();
    const allowedEntries = new Set([
      `${feature}.controller.ts`,
      `${feature}.module.ts`,
      `${feature}.service.ts`,
      "dto",
      "providers",
    ]);
    const expected = [...allowedEntries].filter((entry) => fs.existsSync(path.join(featureDir, entry))).sort();
    assert.deepEqual(entries, expected, `${feature} module root should only contain standard Nest files and subdirectories`);
  }
});

test("infrastructure module owns shared runtime providers once", () => {
  const moduleSource = fs.readFileSync(path.join(root, "src", "infrastructure", "infrastructure.module.ts"), "utf8");
  for (const provider of ["AppConfigService", "PrismaService", "PrismaMigrationService", "PrismaDatasetDbService", "FileJobStoreService", "DatasetStateService"]) {
    assert.match(moduleSource, new RegExp(provider));
  }
  assert.doesNotMatch(moduleSource, /SidecarContextService|createRequestHandler|createRouteDispatcher|createSidecarServices/);
});

test("infrastructure does not depend on feature modules", () => {
  const infrastructureRoot = path.join(root, "src", "infrastructure");
  const offenders: string[] = [];
  const visit = (dir: string) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) visit(fullPath);
      if (entry.isFile() && entry.name.endsWith(".ts")) {
        const source = fs.readFileSync(fullPath, "utf8");
        if (source.includes("../../modules/") || source.includes("../modules/")) {
          offenders.push(path.relative(root, fullPath));
        }
      }
    }
  };
  visit(infrastructureRoot);
  assert.deepEqual(offenders, [], `infrastructure must not import feature modules:\n${offenders.join("\n")}`);
});

test("feature modules do not embed database SQL", () => {
  const modulesRoot = path.join(root, "src", "modules");
  const queryPattern = /\b(?:dbService|database|client|pool)\.query\s*\(|\.\$query(?:Raw|RawUnsafe|runCommandRaw)\s*\(/;
  const allowed = new Set([
    path.join(root, "src", "modules", "config", "providers", "readiness.ts"),
  ]);
  const offenders: string[] = [];

  const visit = (dir: string) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) visit(fullPath);
      if (entry.isFile() && entry.name.endsWith(".ts")) {
        if (allowed.has(fullPath)) continue;
        const source = fs.readFileSync(fullPath, "utf8");
        const sourceWithoutComments = source
          .replace(/\/\*[\s\S]*?\*\//g, "")
          .replace(/^\s*\/\/.*$/gm, "");
        if (queryPattern.test(sourceWithoutComments)) {
          offenders.push(path.relative(root, fullPath));
        }
      }
    }
  };

  visit(modulesRoot);
  assert.deepEqual(offenders, [], `feature modules should use repositories/ORM instead of SQL:\n${offenders.join("\n")}`);
});

test("nestjs services inject explicit infrastructure providers instead of a sidecar context", () => {
  for (const feature of ["config", "dataset"]) {
    const servicePath = path.join(root, "src", "modules", feature, `${feature}.service.ts`);
    const serviceSource = fs.readFileSync(servicePath, "utf8");
    assert.doesNotMatch(serviceSource, /SidecarContextService|SidecarContext\b/);
  }
});

test("nestjs feature modules use dto files for request contracts", () => {
  for (const relativePath of [
    "src/modules/dataset/dto/import-sample.dto.ts",
  ]) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), true, `${relativePath} should exist`);
  }

  const datasetController = fs.readFileSync(path.join(root, "src", "modules", "dataset", "dataset.controller.ts"), "utf8");
  assert.match(datasetController, /ImportSampleDto/);
});

test("nestjs controllers stay thin and delegate business work to feature services", () => {
  const controllerFiles = ["config", "dataset"].map((feature) => path.join(root, "src", "modules", feature, `${feature}.controller.ts`));
  const domainFiles = ["config", "dataset"].map((feature) => path.join(root, "src", "modules", feature, "providers", `${feature}.domain.ts`));
  const controllers = controllerFiles.map((file) => fs.readFileSync(file, "utf8")).join("\n");
  const domain = domainFiles.map((file) => fs.readFileSync(file, "utf8")).join("\n");

  assert.ok(domainFiles.length >= 2, "sidecar should be split across multiple domain services");

  for (const forbidden of ["checkPostgres", "importSampleDataset"]) {
    assert.equal(controllers.includes(forbidden), false, `controller should not orchestrate ${forbidden}`);
    assert.equal(domain.includes(forbidden), true, `domain should own ${forbidden}`);
  }
  assert.match(controllers, /Service/);
});

test("legacy book job module is removed from sidecar runtime", () => {
  for (const relativePath of [
    "src/modules/books/books.module.ts",
    "src/modules/books/books.controller.ts",
    "src/modules/books/books.service.ts",
    "src/modules/books/providers/books.domain.ts",
  ]) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), false, `${relativePath} should not remain in production source`);
  }
});

test("sidecar module internals avoid duplicated feature filenames", () => {
  const modulesRoot = path.join(root, "src");
  const collected = new Map<string, string[]>();

  const visit = (dir: string) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) visit(fullPath);
      if (entry.isFile() && entry.name.endsWith(".ts")) {
        const list = collected.get(entry.name) || [];
        list.push(path.relative(modulesRoot, fullPath));
        collected.set(entry.name, list);
      }
    }
  };

  visit(modulesRoot);

  const duplicates = [...collected.entries()]
    .filter(([, files]) => files.length > 1)
    .map(([name, files]) => `${name}: ${files.join(", ")}`);

  assert.deepEqual(duplicates, [], `duplicate module filenames found:\n${duplicates.join("\n")}`);
});

test("nestjs services use standard constructor injection with private readonly", () => {
  const roots = [
    path.join(root, "src", "modules", "config"),
    path.join(root, "src", "modules", "dataset"),
  ];

  const servicesWithStandardInjection: string[] = [];
  for (const dir of roots) {
    for (const file of fs.readdirSync(dir)) {
      if (!file.endsWith(".service.ts")) continue;
      const filePath = path.join(dir, file);
      const source = fs.readFileSync(filePath, "utf8");
      if (source.includes("constructor(") && source.includes("@Injectable()")) {
        servicesWithStandardInjection.push(path.relative(root, filePath));
      }
    }
  }

  assert.ok(servicesWithStandardInjection.length >= 2, `services should use standard NestJS constructor injection:\n${servicesWithStandardInjection.join("\n")}`);
});
