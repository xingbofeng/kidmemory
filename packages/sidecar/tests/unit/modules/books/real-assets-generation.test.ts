import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { DatasetState } from "../../../../src/infrastructure/dataset-state/dataset-state.service.ts";
import { MemoryDatasetDb } from "../../../../src/infrastructure/dataset-state/memory-dataset-db.ts";
import { FileJobStoreService } from "../../../../src/infrastructure/jobs/file-job-store.service.ts";
import { createBooksService } from "../../../../src/modules/books/providers/books.domain.ts";

test("books generation uses latest persisted asset metadata and selected child", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-real-assets-"));
  const workspaceDir = path.join(root, "workspace");
  const exportDir = path.join(root, "export");
  const dataDir = path.join(root, "data");
  await fs.mkdir(workspaceDir, { recursive: true });
  await fs.mkdir(exportDir, { recursive: true });
  await fs.mkdir(dataDir, { recursive: true });

  const db = new MemoryDatasetDb();
  await db.upsertChild({ id: "child-a", name: "A" });
  await db.upsertChild({ id: "child-b", name: "B" });
  await db.upsertAsset({
    id: "asset-1",
    childId: "child-b",
    type: "artwork",
    title: "old-title",
    tags: ["x"],
    description: "old",
    imagePath: path.join(root, "asset-1.jpg"),
    thumbnailPath: path.join(root, "asset-1.jpg"),
    sourceUrl: "",
    license: "local",
  });
  await fs.writeFile(path.join(root, "asset-1.jpg"), "asset-1");
  await db.updateAssetMetadata?.("asset-1", { title: "new-title", description: "new-desc", tags: ["new"] });

  const datasetState = new DatasetState(db, async () => db);
  const booksService = createBooksService({
    config: {
      postgres: { host: "localhost", port: 5432, database: "kidmemory", user: "postgres", password: "" },
      openai: { provider: "openai", baseUrl: "https://api.openai.com/v1", apiKey: "", model: "gpt-4o-mini" },
      claude: { apiKey: "", model: "claude-3-5-sonnet-20241022", baseUrl: "https://api.anthropic.com" },
      paths: { workspaceDir, exportDir, dataDir },
      sidecar: { host: "127.0.0.1", port: 4317, webCompanionBaseUrl: "http://127.0.0.1:4317" },
      supabaseStorage: { 
        provider: "supabase" as const,
        url: "", 
        serviceRoleKey: "", 
        anonKey: "",
        bucket: "", 
        publicBaseUrl: "", 
        signedUrlTtlSeconds: 3600,
        s3: { endpoint: "", accessKeyId: "", secretAccessKey: "", region: "" } 
      },
      webCompanionDirectUpload: { 
        enabled: false, 
        bucket: "",
        publicUrl: "",
        recommendedClientLimit: 100, 
        expiresAtHintSeconds: 3600
      },
    },
    datasetState: datasetState as any,
    jobStore: new FileJobStoreService(dataDir),
    agentConfigService: {
      getDefaultConfig: async () => ({
        id: "agent-config-1",
        provider: "openai",
        model: "gpt-4.1-mini",
        baseUrl: "https://api.openai.com/v1",
        temperature: 0.2,
        maxTokens: 1000,
        systemPrompt: "",
        toolsEnabled: [],
      }),
      getDecryptedApiKey: async () => "test-api-key",
    } as any,
    agentRunner: {
      generateBook: async () => ({ ok: true, runner: "openai-agents", bookPath: "book.json", htmlPath: "book.html" }),
    } as any,
  });

  const response = await booksService.createJob({ assetIds: ["asset-1"], childId: "child-b" });
  assert.equal(response.status, 200);
  const job = response.data as any;
  assert.equal(Boolean(job.workspacePath), true);

  const assetsJson = JSON.parse(await fs.readFile(path.join(job.workspacePath, "input", "assets.json"), "utf8"));
  const childJson = JSON.parse(await fs.readFile(path.join(job.workspacePath, "input", "child.json"), "utf8"));
  assert.equal(childJson.id, "child-b");
  assert.equal(assetsJson.assets[0].title, "new-title");
  assert.equal(assetsJson.assets[0].description, "new-desc");
  assert.deepEqual(assetsJson.assets[0].tags, ["new"]);
});
