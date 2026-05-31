/**
 * Upload Commit Integration Tests
 * 
 * Tests concurrent upload commit operations with real database to verify:
 * - Commit idempotency (multiple commits of same item)
 * - No race conditions in status updates
 * - Proper error handling under concurrent load
 */

import assert from "node:assert/strict";
import { describe, test, beforeEach, afterEach } from "node:test";

import { WebCompanionService } from "../../src/modules/web-companion/web-companion.service.ts";
import { AppConfigService } from "../../src/infrastructure/config/app-config.service.ts";
import { PrismaMigrationService } from "../../src/infrastructure/database/prisma-migration.service.ts";
import { PrismaService } from "../../src/infrastructure/database/prisma.service.ts";
import { PrismaDatasetDbService } from "../../src/infrastructure/dataset-state/prisma-dataset-db.service.ts";
import { DatasetStateService } from "../../src/infrastructure/dataset-state/dataset-state.service.ts";
import { DatasetService } from "../../src/modules/dataset/dataset.service.ts";
import { PrismaWebCompanionRepository } from "../../src/modules/web-companion/prisma-web-companion.repository.ts";

import {
  UploadItemStatus,
  StorageProvider,
  type UploadItemStatusType,
} from "../../src/modules/web-companion/constants.ts";

function assertErrorMessageIncludes(error: unknown, expected: string) {
  assert.ok(error instanceof Error, "expected rejection to be an Error");
  assert.ok(error.message.includes(expected), `expected "${error.message}" to include "${expected}"`);
  return true;
}

describe("Upload Commit Integration", { skip: process.env.DATABASE_URL ? false : "DATABASE_URL is not configured" }, () => {
  let service: WebCompanionService;
  let prisma: PrismaService;
  let appConfig: AppConfigService;
  let dataset: DatasetService;

  const testChildId = "test-child-commit";
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
      create: { id: testChildId, name: "Test Child Commit" },
      update: { name: "Test Child Commit" },
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

  test("Task 2.33: concurrent commit idempotency", async () => {
    const sessionResponse = await service.createSession({
      childId: testChildId,
      expiresInMinutes: 60,
      maxItems: 10,
    });

    createdSessionIds.push(sessionResponse.sessionId);

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

    const uploadItem = itemsResponse.items[0];

    await prisma.uploadItem.update({
      where: { id: uploadItem.uploadItemId },
      data: { status: UploadItemStatus.UPLOADING },
    });

    const concurrentCommits = 10;
    const commitRequests = Array.from({ length: concurrentCommits }, () =>
      service.commitUploadItem(
        sessionResponse.sessionId,
        uploadItem.uploadItemId,
        {
          token: sessionResponse.token,
          objectKey: uploadItem.objectKey,
          sizeBytes: 1024000,
          contentType: "image/jpeg",
          remoteEtag: "test-etag",
        }
      ).catch(error => ({ error: error.message }))
    );

    const results = await Promise.all(commitRequests);

    // 3. Verify results
    const successResults = results.filter(r => !('error' in r));
    const errorResults = results.filter(r => 'error' in r);

    // At least one should succeed
    assert.ok(successResults.length >= 1, `At least one commit should succeed, got ${successResults.length}`);

    // Check for idempotent responses
    const idempotentResults = successResults.filter(r => 'idempotent' in r && r.idempotent === true);
    
    // Most should be idempotent (except the first one)
    assert.ok(
      idempotentResults.length >= concurrentCommits - 2,
      `Most commits should be idempotent, got ${idempotentResults.length} out of ${successResults.length}`
    );

    // 4. Verify database state
    const finalItem = await prisma.uploadItem.findUnique({
      where: { id: uploadItem.uploadItemId },
    });

    assert.ok(finalItem);
    assert.ok(finalItem.committedAt, "Item should have committedAt timestamp");
    assert.strictEqual(finalItem.status, UploadItemStatus.UPLOADED_REMOTE);
  });

  test("Task 2.33: commit idempotency returns consistent data", async () => {
    // 1. Create session and upload item
    const sessionResponse = await service.createSession({
      childId: testChildId,
      expiresInMinutes: 60,
      maxItems: 10,
    });

    createdSessionIds.push(sessionResponse.sessionId);

    const itemsResponse = await service.createUploadItems(sessionResponse.sessionId, {
      token: sessionResponse.token,
      files: [
        {
          clientFileId: "file-2",
          filename: "test-photo-2.jpg",
          contentType: "image/jpeg",
          sizeBytes: 2048000,
        },
      ],
      provider: StorageProvider.LAN,
    });

    const uploadItem = itemsResponse.items[0];

    await prisma.uploadItem.update({
      where: { id: uploadItem.uploadItemId },
      data: { status: UploadItemStatus.UPLOADING },
    });

    // 2. First commit
    const firstCommit = await service.commitUploadItem(
      sessionResponse.sessionId,
      uploadItem.uploadItemId,
      {
        token: sessionResponse.token,
        objectKey: uploadItem.objectKey,
        sizeBytes: 2048000,
        contentType: "image/jpeg",
        remoteEtag: "test-etag-2",
      }
    );

    assert.strictEqual(firstCommit.idempotent, false);
    assert.strictEqual(firstCommit.status, UploadItemStatus.UPLOADED_REMOTE);

    // 3. Second commit (should be idempotent)
    const secondCommit = await service.commitUploadItem(
      sessionResponse.sessionId,
      uploadItem.uploadItemId,
      {
        token: sessionResponse.token,
        objectKey: uploadItem.objectKey,
        sizeBytes: 2048000,
        contentType: "image/jpeg",
        remoteEtag: "test-etag-2",
      }
    );

    assert.strictEqual(secondCommit.idempotent, true);
    assert.strictEqual(secondCommit.uploadItemId, firstCommit.uploadItemId);

    // 4. Third commit (should also be idempotent)
    const thirdCommit = await service.commitUploadItem(
      sessionResponse.sessionId,
      uploadItem.uploadItemId,
      {
        token: sessionResponse.token,
        objectKey: uploadItem.objectKey,
        sizeBytes: 2048000,
        contentType: "image/jpeg",
        remoteEtag: "test-etag-2",
      }
    );

    assert.strictEqual(thirdCommit.idempotent, true);
    assert.strictEqual(thirdCommit.uploadItemId, firstCommit.uploadItemId);
  });

  test("Task 2.33: concurrent commits with different object keys fail appropriately", async () => {
    // 1. Create session and upload item
    const sessionResponse = await service.createSession({
      childId: testChildId,
      expiresInMinutes: 60,
      maxItems: 10,
    });

    createdSessionIds.push(sessionResponse.sessionId);

    const itemsResponse = await service.createUploadItems(sessionResponse.sessionId, {
      token: sessionResponse.token,
      files: [
        {
          clientFileId: "file-3",
          filename: "test-photo-3.jpg",
          contentType: "image/jpeg",
          sizeBytes: 1024000,
        },
      ],
      provider: StorageProvider.LAN,
    });

    const uploadItem = itemsResponse.items[0];

    await prisma.uploadItem.update({
      where: { id: uploadItem.uploadItemId },
      data: { status: UploadItemStatus.UPLOADING },
    });

    // 2. Try to commit with wrong object key
    await assert.rejects(
      async () => service.commitUploadItem(
        sessionResponse.sessionId,
        uploadItem.uploadItemId,
        {
          token: sessionResponse.token,
          objectKey: "wrong-object-key",
          sizeBytes: 1024000,
          contentType: "image/jpeg",
          remoteEtag: "test-etag",
        }
      ),
      (error: unknown) => assertErrorMessageIncludes(error, "Object key mismatch")
    );
  });

  test("Task 2.35: complete upload flow integration", async () => {
    // 1. Create session
    const sessionResponse = await service.createSession({
      childId: testChildId,
      expiresInMinutes: 60,
      maxItems: 5,
    });

    createdSessionIds.push(sessionResponse.sessionId);

    assert.ok(sessionResponse.sessionId);
    assert.ok(sessionResponse.token);

    // 2. Create multiple upload items
    const itemsResponse = await service.createUploadItems(sessionResponse.sessionId, {
      token: sessionResponse.token,
      files: [
        {
          clientFileId: "file-a",
          filename: "photo-a.jpg",
          contentType: "image/jpeg",
          sizeBytes: 1024000,
        },
        {
          clientFileId: "file-b",
          filename: "photo-b.jpg",
          contentType: "image/jpeg",
          sizeBytes: 2048000,
        },
        {
          clientFileId: "file-c",
          filename: "photo-c.jpg",
          contentType: "image/jpeg",
          sizeBytes: 512000,
        },
      ],
      provider: StorageProvider.LAN,
    });

    assert.strictEqual(itemsResponse.items.length, 3);

    // 3. Simulate upload and commit for each item
    for (const item of itemsResponse.items) {
      // Update to UPLOADING
      await prisma.uploadItem.update({
        where: { id: item.uploadItemId },
        data: { status: UploadItemStatus.UPLOADING },
      });

      // Commit
      const commitResult = await service.commitUploadItem(
        sessionResponse.sessionId,
        item.uploadItemId,
        {
          token: sessionResponse.token,
          objectKey: item.objectKey,
          sizeBytes: 1024000,
          contentType: "image/jpeg",
          remoteEtag: `etag-${item.uploadItemId}`,
        }
      );

      assert.strictEqual(commitResult.status, UploadItemStatus.UPLOADED_REMOTE);
      assert.strictEqual(commitResult.idempotent, false);
    }

    // 4. Get session detail
    const detail = await service.getSessionDetail(sessionResponse.sessionId, sessionResponse.token);
    assert.strictEqual(detail.items.length, 3);

    // All items should be in UPLOADED_REMOTE or later status
    for (const item of detail.items) {
      assert.ok(
        ([
          UploadItemStatus.UPLOADED_REMOTE,
          UploadItemStatus.PULLING_LOCAL,
          UploadItemStatus.READY,
          UploadItemStatus.FAILED,
        ] as UploadItemStatusType[]).includes(item.status)
      );
    }

    // 5. Close session
    await service.closeSession(sessionResponse.sessionId, {
      token: sessionResponse.token,
    });

    // 6. Verify session is closed
    const summary = await service.getSessionSummary(sessionResponse.sessionId);
    assert.strictEqual(summary.status, "closed");
  });

  test("Task 2.35: upload flow with concurrent operations", async () => {
    // 1. Create session
    const sessionResponse = await service.createSession({
      childId: testChildId,
      expiresInMinutes: 60,
      maxItems: 10,
    });

    createdSessionIds.push(sessionResponse.sessionId);

    // 2. Create upload items concurrently
    const createRequests = Array.from({ length: 3 }, (_, i) =>
      service.createUploadItems(sessionResponse.sessionId, {
        token: sessionResponse.token,
        files: [
          {
            clientFileId: `concurrent-file-${i}`,
            filename: `concurrent-photo-${i}.jpg`,
            contentType: "image/jpeg",
            sizeBytes: 1024000,
          },
        ],
        provider: StorageProvider.LAN,
      })
    );

    const createResults = await Promise.all(createRequests);
    const allItems = createResults.flatMap(r => r.items);

    assert.strictEqual(allItems.length, 3);

    // 3. Update all to UPLOADING and commit concurrently
    await Promise.all(
      allItems.map(item =>
        prisma.uploadItem.update({
          where: { id: item.uploadItemId },
          data: { status: UploadItemStatus.UPLOADING },
        })
      )
    );

    const commitRequests = allItems.map(item =>
      service.commitUploadItem(
        sessionResponse.sessionId,
        item.uploadItemId,
        {
          token: sessionResponse.token,
          objectKey: item.objectKey,
          sizeBytes: 1024000,
          contentType: "image/jpeg",
          remoteEtag: `etag-${item.uploadItemId}`,
        }
      )
    );

    const commitResults = await Promise.all(commitRequests);

    // All commits should succeed
    assert.strictEqual(commitResults.length, 3);
    for (const result of commitResults) {
      assert.strictEqual(result.status, UploadItemStatus.UPLOADED_REMOTE);
    }

    // 4. Verify all items are committed
    const detail = await service.getSessionDetail(sessionResponse.sessionId, sessionResponse.token);
    assert.strictEqual(detail.items.length, 3);

    const committedItems = await prisma.uploadItem.findMany({
      where: {
        sessionId: sessionResponse.sessionId,
        committedAt: { not: null },
      },
    });

    assert.strictEqual(committedItems.length, 3);
  });

  test("Task 2.35: upload flow handles errors gracefully", async () => {
    // 1. Create session
    const sessionResponse = await service.createSession({
      childId: testChildId,
      expiresInMinutes: 60,
      maxItems: 2,
    });

    createdSessionIds.push(sessionResponse.sessionId);

    // 2. Create upload items
    const itemsResponse = await service.createUploadItems(sessionResponse.sessionId, {
      token: sessionResponse.token,
      files: [
        {
          clientFileId: "file-1",
          filename: "photo-1.jpg",
          contentType: "image/jpeg",
          sizeBytes: 1024000,
        },
      ],
      provider: StorageProvider.LAN,
    });

    const uploadItem = itemsResponse.items[0];

    // 3. Try to commit without uploading (should fail)
    await assert.rejects(
      async () => service.commitUploadItem(
        sessionResponse.sessionId,
        uploadItem.uploadItemId,
        {
          token: sessionResponse.token,
          objectKey: uploadItem.objectKey,
          sizeBytes: 1024000,
          contentType: "image/jpeg",
          remoteEtag: "test-etag",
        }
      ),
      (error: unknown) => assertErrorMessageIncludes(error, "Invalid status transition")
    );

    // 4. Update to UPLOADING
    await prisma.uploadItem.update({
      where: { id: uploadItem.uploadItemId },
      data: { status: UploadItemStatus.UPLOADING },
    });

    // 5. Commit successfully
    const commitResult = await service.commitUploadItem(
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

    assert.strictEqual(commitResult.status, UploadItemStatus.UPLOADED_REMOTE);

    // 6. Close session
    await service.closeSession(sessionResponse.sessionId, {
      token: sessionResponse.token,
    });

    // 7. Try to create more items (should fail)
    await assert.rejects(
      async () => service.createUploadItems(sessionResponse.sessionId, {
        token: sessionResponse.token,
        files: [
          {
            clientFileId: "file-2",
            filename: "photo-2.jpg",
            contentType: "image/jpeg",
            sizeBytes: 1024000,
          },
        ],
        provider: StorageProvider.LAN,
      }),
      (error: unknown) => assertErrorMessageIncludes(error, "closed")
    );
  });
});
