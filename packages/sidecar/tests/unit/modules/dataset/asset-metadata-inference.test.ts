import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { AppConfigService, loadConfigFromEnv } from "../../../../src/infrastructure/config/app-config.service.ts";
import { createOpenAIAssetMetadataInferer } from "../../../../src/modules/dataset/providers/asset-metadata-inference.ts";

async function createTempImage() {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-infer-test-"));
  const file = path.join(dir, "image.png");
  await fs.writeFile(file, "fake-image");
  return file;
}

function createConfiguredAppConfig() {
  const config = new AppConfigService(loadConfigFromEnv({}));
  config.updateOpenAIConfig({
    baseUrl: "https://openai-compatible.example.test/v1",
    apiKey: "sk-test",
    model: "gpt-4.1-mini",
  });
  return config;
}

test("asset metadata inferer parses JSON content wrapped in markdown code fences", async () => {
  const config = createConfiguredAppConfig();
  const infer = createOpenAIAssetMetadataInferer(config, (async () => ({
    ok: true,
    json: async () => ({
      choices: [
        {
          message: {
            content: "```json\n{\"title\":\"小猫\",\"description\":\"一只猫\",\"tags\":[\"猫\",\"宠物\"]}\n```",
          },
        },
      ],
    }),
  })) as typeof fetch);
  const imagePath = await createTempImage();
  const result = await infer?.({ assetId: "a1", childId: "c1", imagePath });
  assert.equal(result?.title, "小猫");
  assert.equal(result?.description, "一只猫");
  assert.deepEqual(result?.tags, ["猫", "宠物"]);
});

test("asset metadata inferer parses JSON object embedded in plain text", async () => {
  const config = createConfiguredAppConfig();
  const infer = createOpenAIAssetMetadataInferer(config, (async () => ({
    ok: true,
    json: async () => ({
      choices: [
        {
          message: {
            content: "识别结果如下：{\"title\":\"草地上的猫\",\"description\":\"在草地休息\",\"tags\":[\"猫\",\"草地\"]} 请保存",
          },
        },
      ],
    }),
  })) as typeof fetch);
  const imagePath = await createTempImage();
  const result = await infer?.({ assetId: "a2", childId: "c1", imagePath });
  assert.equal(result?.title, "草地上的猫");
  assert.equal(result?.description, "在草地休息");
  assert.deepEqual(result?.tags, ["猫", "草地"]);
});
