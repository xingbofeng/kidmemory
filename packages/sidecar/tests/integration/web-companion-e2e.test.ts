/**
 * Web Companion 端到端集成测试
 * 测试完整的上传流程：创建会话 → 创建上传项 → 提交 → 关闭会话
 */

import assert from "node:assert/strict";
import { describe, test, beforeEach, afterEach } from "node:test";
import crypto from "node:crypto";

import { WebCompanionService } from "../../src/modules/web-companion/web-companion.service.ts";
import { AppConfigService } from "../../src/infrastructure/config/app-config.service.ts";
import { PrismaMigrationService } from "../../src/infrastructure/database/prisma-migration.service.ts";
import { PrismaService } from "../../src/infrastructure/database/prisma.service.ts";
import { PrismaDatasetDbService } from "../../src/infrastructure/dataset-state/prisma-dataset-db.service.ts";
import { DatasetStateService } from "../../src/infrastructure/dataset-state/dataset-state.service.ts";
import { DatasetService } from "../../src/modules/dataset/dataset.service.ts";
import { PrismaWebCompanionRepository } from "../../src/modules/web-companion/prisma-web-companion.repository.ts";

import {
  UploadSessionStatus,
  UploadItemStatus,
  StorageProvider,
  type UploadItemStatusType,
} from "../../src/modules/web-companion/constants.ts";

function assertErrorMessageIncludes(error: unknown, expected: string) {
  assert.ok(error instanceof Error, "expected rejection to be an Error");
  assert.ok(error.message.includes(expected), `expected "${error.message}" to include "${expected}"`);
  return true;
}

describe("Web Companion E2E", { skip: process.env.DATABASE_URL ? false : "DATABASE_URL is not configured" }, () => {
  let service: WebCompanionService;
  let prisma: PrismaService;
  let appConfig: AppConfigService;
  let dataset: DatasetService;

  const testChildId = "test-child-e2e";
  let createdSessionIds: string[] = [];

  beforeEach(async () => {
    appConfig = new AppConfigService();
    await new PrismaMigrationService(appConfig).deploy();
    prisma = new PrismaService();
    await prisma.$connect();
    dataset = new DatasetService(new DatasetStateService(new PrismaDatasetDbService(prisma)), appConfig);
    service = new WebCompanionService(appConfig, new PrismaWebCompanionRepository(prisma), dataset);

    await prisma.child.upsert({
      where: { id: testChildId },
      create: { id: testChildId, name: "Test Child" },
      update: { name: "Test Child" },
    });
  });

  afterEach(async () => {
    if (prisma && createdSessionIds.length > 0) {
      for (const sessionId of createdSessionIds) {
        await prisma.uploadSession.deleteMany({ where: { id: sessionId } });
      }
      createdSessionIds = [];
    }
    if (prisma) {
      await prisma.$disconnect();
    }
  });

  test("complete upload flow: create session → create items → commit → close", async () => {
    const sessionResponse = await service.createSession({
      childId: testChildId,
      expiresInMinutes: 60,
      maxItems: 10,
    });

    createdSessionIds.push(sessionResponse.sessionId);

    assert.ok(sessionResponse.sessionId);
    assert.ok(sessionResponse.token);
    assert.equal(sessionResponse.token.length, 64);
    assert.ok(sessionResponse.webUrl.includes(sessionResponse.sessionId));

    const summary = await service.getSessionSummary(sessionResponse.sessionId, sessionResponse.token);
    assert.equal(summary.status, UploadSessionStatus.ACTIVE);
    assert.equal(summary.child.id, testChildId);
    assert.equal(summary.usedItems, 0);

    const itemsResponse = await service.createUploadItems(sessionResponse.sessionId, {
      token: sessionResponse.token,
      files: [
        {
          clientFileId: "file-1",
          filename: "test-photo.jpg",
          contentType: "image/jpeg",
          sizeBytes: 1024000,
        },
      ],
      provider: StorageProvider.LAN,
    });

    assert.equal(itemsResponse.items.length, 1);
    const uploadItem = itemsResponse.items[0];
    assert.ok(uploadItem.uploadItemId);
    assert.ok(uploadItem.assetId);
    assert.ok(uploadItem.objectKey);
    assert.equal(uploadItem.status, UploadItemStatus.PENDING);

    await prisma.uploadItem.update({
      where: { id: uploadItem.uploadItemId },
      data: { status: UploadItemStatus.UPLOADING },
    });

    // 4. 提交上传项
    const commitResponse = await service.commitUploadItem(
      sessionResponse.sessionId,
      uploadItem.uploadItemId,
      {
        token: sessionResponse.token,
        objectKey: uploadItem.objectKey,
        sizeBytes: 1024000,
        contentType: "image/jpeg",
        remoteEtag: "test-etag",
      }
    );

    assert.equal(commitResponse.uploadItemId, uploadItem.uploadItemId);
    assert.equal(commitResponse.status, UploadItemStatus.UPLOADED_REMOTE);

    // 5. 获取会话详情
    const detail = await service.getSessionDetail(sessionResponse.sessionId, sessionResponse.token);
    assert.equal(detail.items.length, 1);
    assert.ok(
      ([
        UploadItemStatus.UPLOADED_REMOTE,
        UploadItemStatus.PULLING_LOCAL,
        UploadItemStatus.READY,
        UploadItemStatus.FAILED,
      ] as UploadItemStatusType[]).includes(detail.items[0].status),
    );

    // 6. 关闭会话
    await service.closeSession(sessionResponse.sessionId, {
      token: sessionResponse.token,
    });

    // 7. 验证会话已关闭
    const finalSummary = await service.getSessionSummary(sessionResponse.sessionId, sessionResponse.token);
    assert.equal(finalSummary.status, UploadSessionStatus.CLOSED);
  });

  test("should enforce max items limit", async () => {
    const sessionResponse = await service.createSession({
      childId: testChildId,
      maxItems: 2,
    });

    createdSessionIds.push(sessionResponse.sessionId);

    // 创建2个上传项应该成功
    await service.createUploadItems(sessionResponse.sessionId, {
      token: sessionResponse.token,
      files: [
        { clientFileId: "f1", filename: "a.jpg", contentType: "image/jpeg", sizeBytes: 1000 },
        { clientFileId: "f2", filename: "b.jpg", contentType: "image/jpeg", sizeBytes: 1000 },
      ],
      provider: StorageProvider.LAN,
    });

    // 尝试创建第3个应该失败
    await assert.rejects(
      async () => service.createUploadItems(sessionResponse.sessionId, {
        token: sessionResponse.token,
        files: [
          { clientFileId: "f3", filename: "c.jpg", contentType: "image/jpeg", sizeBytes: 1000 },
        ],
        provider: StorageProvider.LAN,
      }),
      (error: unknown) => assertErrorMessageIncludes(error, "limit")
    );
  });

  test("should reject operations on closed session", async () => {
    const sessionResponse = await service.createSession({
      childId: testChildId,
    });

    createdSessionIds.push(sessionResponse.sessionId);

    // 关闭会话
    await service.closeSession(sessionResponse.sessionId, {
      token: sessionResponse.token,
    });

    // 尝试创建上传项应该失败
    await assert.rejects(
      async () => service.createUploadItems(sessionResponse.sessionId, {
        token: sessionResponse.token,
        files: [
          { clientFileId: "f1", filename: "a.jpg", contentType: "image/jpeg", sizeBytes: 1000 },
        ],
        provider: StorageProvider.LAN,
      }),
      (error: unknown) => assertErrorMessageIncludes(error, "closed")
    );
  });

  test("should reject invalid token", async () => {
    const sessionResponse = await service.createSession({
      childId: testChildId,
    });

    createdSessionIds.push(sessionResponse.sessionId);

    // 使用错误的 token
    await assert.rejects(
      async () => service.createUploadItems(sessionResponse.sessionId, {
        token: "invalid-token-" + "a".repeat(50),
        files: [
          { clientFileId: "f1", filename: "a.jpg", contentType: "image/jpeg", sizeBytes: 1000 },
        ],
        provider: StorageProvider.LAN,
      }),
      (error: unknown) => assertErrorMessageIncludes(error, "Invalid token")
    );
  });
});
