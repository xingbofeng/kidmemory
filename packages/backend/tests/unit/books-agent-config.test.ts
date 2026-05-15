import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { DatasetState } from "../../src/infrastructure/dataset-state/dataset-state.service.ts";
import { MemoryDatasetDb } from "../../src/infrastructure/dataset-state/memory-dataset-db.ts";
import { FileJobStoreService } from "../../src/infrastructure/jobs/file-job-store.service.ts";
import { AgentConfig } from "../../src/modules/agent-config/domain/agent-config.entity.ts";
import { createBooksService } from "../../src/modules/books/providers/books.domain.ts";

async function createService(options: {
  defaultConfig?: AgentConfig | null;
  apiKey?: string | null;
  provider?: "openai" | "anthropic" | "custom";
}) {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-books-agent-config-"));
  const workspaceDir = path.join(root, "workspace");
  const exportDir = path.join(root, "export");
  const dataDir = path.join(root, "data");
  const assetPath = path.join(root, "asset.jpg");
  await fs.mkdir(workspaceDir, { recursive: true });
  await fs.mkdir(exportDir, { recursive: true });
  await fs.mkdir(dataDir, { recursive: true });
  await fs.writeFile(assetPath, "asset");

  const db = new MemoryDatasetDb();
  await db.upsertChild({ id: "child-1", name: "Kid" });
  await db.upsertAsset({
    id: "asset-1",
    childId: "child-1",
    type: "artwork",
    title: "Asset",
    tags: [],
    description: "",
    imagePath: assetPath,
    thumbnailPath: assetPath,
    sourceUrl: "",
    license: "local",
  });

  const capturedConfigs: unknown[] = [];
  const defaultConfig = options.defaultConfig === undefined
    ? AgentConfig.create({
        name: "Default OpenAI",
        provider: options.provider || "openai",
        model: "gpt-4.1-mini",
        baseUrl: "https://api.openai.com/v1",
        apiKey: "stored-secret",
        temperature: 0.2,
        maxTokens: 1234,
        systemPrompt: "Write gently.",
        toolsEnabled: ["asset_reader"],
        isDefault: true,
      })
    : options.defaultConfig;

  const service = createBooksService({
    config: {
      paths: { workspaceDir, exportDir, dataDir },
      claude: { apiKey: "", model: "claude-3-5-sonnet-20241022", baseUrl: "https://api.anthropic.com" },
    } as any,
    datasetState: new DatasetState(db, async () => db) as any,
    jobStore: new FileJobStoreService(dataDir),
    agentConfigService: {
      getDefaultConfig: async () => defaultConfig,
      getDecryptedApiKey: async () => options.apiKey === undefined ? "decrypted-secret" : options.apiKey,
    },
    agentRunner: {
      generateBook: async (_input: unknown, config: unknown) => {
        capturedConfigs.push(config);
        return { ok: true, runner: "openai-agents", bookPath: "book.json", htmlPath: "book.html" };
      },
    } as any,
  });

  return { service, capturedConfigs };
}

test("books generation uses the persisted default agent config instead of request raw config", async () => {
  const { service, capturedConfigs } = await createService({});

  const result = await service.createJob({
    childId: "child-1",
    assetIds: ["asset-1"],
    agentConfig: {
      baseUrl: "https://evil.invalid/v1",
      apiKey: "request-secret",
      model: "wrong-model",
    },
  });

  assert.equal(result.status, 200);
  assert.equal(capturedConfigs.length, 1);
  assert.deepEqual(capturedConfigs[0], {
    baseUrl: "https://api.openai.com/v1",
    apiKey: "decrypted-secret",
    model: "gpt-4.1-mini",
    temperature: 0.2,
    maxTokens: 1234,
    systemPrompt: "Write gently.",
    toolsEnabled: ["asset_reader"],
  });
});

test("books generation requires a default persisted agent config for OpenAI Agents runner", async () => {
  const { service, capturedConfigs } = await createService({ defaultConfig: null });

  const result = await service.createJob({ childId: "child-1", assetIds: ["asset-1"] });

  assert.equal(result.status, 400);
  assert.match((result.data as { message: string }).message, /No default agent configuration/);
  assert.equal(capturedConfigs.length, 0);
});

test("books generation rejects unsupported default provider for OpenAI Agents runner", async () => {
  const { service, capturedConfigs } = await createService({ provider: "anthropic" });

  const result = await service.createJob({ childId: "child-1", assetIds: ["asset-1"] });

  assert.equal(result.status, 400);
  assert.match((result.data as { message: string }).message, /not supported/);
  assert.equal(capturedConfigs.length, 0);
});
