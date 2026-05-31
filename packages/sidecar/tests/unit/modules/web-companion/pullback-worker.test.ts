import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { WebCompanionService } from "../../../../src/modules/web-companion/web-companion.service.ts";
import { AppConfigService } from "../../../../src/infrastructure/config/app-config.service.ts";
import type { WebCompanionRepository } from "../../../../src/modules/web-companion/web-companion.service.ts";
import { DatasetService } from "../../../../src/modules/dataset/dataset.service.ts";

type PullbackWorkerSurface = {
  startPullbackProcess?: unknown;
};

describe("WebCompanionService - Pullback Worker", () => {
  const mockAppConfigService = {
    config: {
      supabaseStorage: {
        url: "https://test.supabase.co",
        serviceRoleKey: "test-service-role-key",
        bucket: "test-bucket",
        signedUrlTtlSeconds: 900,
      },
    },
  } as unknown as AppConfigService;

  const mockRepository = {} as WebCompanionRepository;
  const mockDatasetService = {} as DatasetService;

  function createService(): WebCompanionService {
    return new WebCompanionService(
      mockAppConfigService,
      mockRepository,
      mockDatasetService
    );
  }

  it("keeps startPullbackProcess as the private worker entrypoint", () => {
    const service = createService() as unknown as PullbackWorkerSurface;

    assert.equal(
      typeof service.startPullbackProcess,
      "function",
      "startPullbackProcess method should exist"
    );
  });
});
