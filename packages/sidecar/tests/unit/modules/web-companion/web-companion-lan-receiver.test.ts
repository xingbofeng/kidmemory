import assert from "node:assert/strict";
import { afterEach, describe, test } from "node:test";
import { LanReceiverService, type LanReceiverRepository } from "../../../../src/modules/web-companion/lan-receiver.service.ts";
import { LanReceiverErrorCode, type LanSession, type LanUploadFile } from "../../../../src/modules/web-companion/lan-receiver.types.ts";
import type { AppConfigService } from "../../../../src/infrastructure/config/app-config.service.ts";
import type { DatasetService } from "../../../../src/modules/dataset/dataset.service.ts";

let currentService: LanReceiverService | undefined;

afterEach(() => {
  currentService?.onModuleDestroy();
  currentService = undefined;
});

function createService() {
  const sessions = new Map<string, LanSession>();
  const importedPaths: Array<{ childId: string; paths: string[] }> = [];

  const repository: LanReceiverRepository = {
    async saveLanSession(session) {
      sessions.set(session.id, { ...session });
    },
    async getLanSessionById(sessionId) {
      return sessions.get(sessionId) ?? null;
    },
    async countReadyUploadsBySession() {
      return importedPaths.length;
    },
    async deleteExpiredSessions(now) {
      for (const [id, session] of sessions.entries()) {
        if (session.expiresAt < now) sessions.delete(id);
      }
    },
  };

  const appConfigService = {
    config: {
      lanReceiver: {
        enabled: true,
        port: 4317,
        maxConcurrentUploads: 2,
        sessionTtlMinutes: 30,
        allowedFileTypes: ["image/jpeg", "image/png"],
        maxFileSizeBytes: 1024 * 1024,
        discoveryService: "_kidmemory._tcp",
        deviceName: "KidMemory Desktop",
        version: "test",
      },
    },
  } as AppConfigService;

  const datasetService = {
    async importAssets(input: { childId: string; paths: string[] }) {
      importedPaths.push(input);
      return {
        ok: true,
        imported: [{ id: "asset-imported", path: input.paths[0] }],
        duplicates: [],
        failed: [],
        skipped: [],
      };
    },
  } as unknown as DatasetService;

  currentService = new LanReceiverService(appConfigService, repository, datasetService);
  return { service: currentService, sessions, importedPaths };
}

function uploadFile(overrides: Partial<LanUploadFile> = {}): LanUploadFile {
  return {
    originalname: "photo.jpg",
    mimetype: "image/jpeg",
    size: 64,
    buffer: Buffer.from("image"),
    ...overrides,
  };
}

describe("LanReceiverService", () => {
  test("creates a paired session and validates only the issued token", async () => {
    const { service, sessions } = createService();

    const pair = await service.handlePairRequest({
      deviceId: "mobile-1",
      childId: "child-1",
      pairingCode: "123456",
    });

    assert.equal(pair.success, true);
    assert.match(pair.sessionId, /^lan-session-/);
    assert.equal(pair.endpoints.upload, `/api/web-companion/lan/sessions/${pair.sessionId}/upload`);
    assert.equal(sessions.get(pair.sessionId)?.childId, "child-1");
    assert.notEqual(sessions.get(pair.sessionId)?.tokenHash, pair.token);

    const valid = await service.validateLanToken(pair.sessionId, pair.token);
    assert.equal(valid.valid, true);
    assert.equal(valid.session?.childId, "child-1");

    const invalid = await service.validateLanToken(pair.sessionId, "wrong-token");
    assert.equal(invalid.valid, false);
    assert.equal(invalid.errorCode, LanReceiverErrorCode.TOKEN_INVALID);
  });

  test("rejects pairing requests without a child id", async () => {
    const { service } = createService();

    await assert.rejects(
      service.handlePairRequest({ deviceId: "mobile-1", pairingCode: "123456" }),
      (error: unknown) => error instanceof Error && (error as Error & { code?: string }).code === LanReceiverErrorCode.PAIRING_FAILED,
    );
  });

  test("imports allowed LAN upload files through DatasetService", async () => {
    const { service, importedPaths } = createService();
    const pair = await service.handlePairRequest({
      deviceId: "mobile-1",
      childId: "child-1",
      pairingCode: "123456",
    });

    const result = await service.handleDirectUpload(pair.sessionId, pair.token, [uploadFile()]);

    assert.equal(result.success, true);
    assert.equal(result.errors.length, 0);
    assert.equal(result.uploadedFiles.length, 1);
    assert.equal(result.uploadedFiles[0].filename, "photo.jpg");
    assert.match(result.uploadedFiles[0].assetId, /^asset_/);
    assert.equal(importedPaths.length, 1);
    assert.equal(importedPaths[0].childId, "child-1");

    const status = await service.getLanSessionStatus(pair.sessionId, pair.token);
    assert.equal(status.currentUploads, 0);
    assert.equal(status.totalUploaded, 1);
  });

  test("rejects unsupported upload file types before import", async () => {
    const { service, importedPaths } = createService();
    const pair = await service.handlePairRequest({
      deviceId: "mobile-1",
      childId: "child-1",
      pairingCode: "123456",
    });

    await assert.rejects(
      service.handleDirectUpload(pair.sessionId, pair.token, [
        uploadFile({ originalname: "script.exe", mimetype: "application/x-executable" }),
      ]),
      (error: unknown) =>
        error instanceof Error &&
        (error as Error & { code?: string }).code === LanReceiverErrorCode.FILE_TYPE_NOT_SUPPORTED,
    );
    assert.equal(importedPaths.length, 0);
  });
});
