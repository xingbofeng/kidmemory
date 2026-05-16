/**
 * Upload Commit 幂等性测试
 * 
 * 验证：
 * - 重复 commit 同一个 uploadItem 返回幂等结果
 * - 幂等响应包含 idempotent: true 标记
 * - 不会重复触发 pullback
 */

import { describe, it, mock } from 'node:test';
import assert from 'node:assert';
import crypto from 'node:crypto';
import { WebCompanionService } from '../../../src/modules/web-companion/web-companion.service';
import { UploadItemStatus } from '../../../src/modules/web-companion/constants';
import type {
  CommitUploadItemRequest,
  UploadItem,
  UploadSession,
} from '../../../src/modules/web-companion/types';

// Helper to hash token (same as service)
function hashToken(token: string): string {
  return crypto.createHash('sha256').update(token).digest('hex');
}

describe('Upload Commit Idempotency', () => {
  it('should return idempotent result when committing already committed item', async () => {
    const mockSessionId = 'session_123';
    const mockToken = 'token_abc';
    const mockTokenHash = hashToken(mockToken);
    const mockUploadItemId = 'item_456';
    const mockObjectKey = 'uploads/test.jpg';

    // Mock session with valid token
    const mockSession: UploadSession = {
      id: mockSessionId,
      sessionId: mockSessionId,
      childId: 'child_1',
      token: mockToken,
      tokenHash: mockTokenHash,
      status: 'active',
      maxItems: 10,
      usedItems: 1,
      expiresAt: new Date(Date.now() + 3600000),
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // Mock upload item that is already committed
    const mockItem: UploadItem = {
      id: mockUploadItemId,
      uploadItemId: mockUploadItemId,
      sessionId: mockSessionId,
      objectKey: mockObjectKey,
      status: UploadItemStatus.UPLOADED_REMOTE,
      sizeBytes: 1024,
      contentType: 'image/jpeg',
      committedAt: new Date(Date.now() - 60000), // Committed 1 minute ago
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const mockRepository = {
      getSessionById: mock.fn(() => Promise.resolve(mockSession)),
      getUploadItemById: mock.fn(() => Promise.resolve(mockItem)),
      updateUploadItemStatus: mock.fn(() => Promise.resolve(mockItem)),
    };

    const mockAppConfig = {} as any;
    const mockDatasetService = {} as any;

    const service = new WebCompanionService(mockAppConfig, mockRepository as any, mockDatasetService);

    const request: CommitUploadItemRequest = {
      token: mockToken,
      objectKey: mockObjectKey,
      sizeBytes: 1024,
      contentType: 'image/jpeg',
    };

    // First commit (should be idempotent since already committed)
    const response1 = await service.commitUploadItem(mockSessionId, mockUploadItemId, request);

    assert.strictEqual(response1.uploadItemId, mockUploadItemId);
    assert.strictEqual(response1.status, UploadItemStatus.UPLOADED_REMOTE);
    assert.strictEqual(response1.idempotent, true, 'Should return idempotent: true');

    // Verify updateUploadItemStatus was NOT called (idempotent path)
    assert.strictEqual(mockRepository.updateUploadItemStatus.mock.callCount(), 0, 'Should not update status for idempotent commit');

    // Second commit (should also be idempotent)
    const response2 = await service.commitUploadItem(mockSessionId, mockUploadItemId, request);

    assert.strictEqual(response2.uploadItemId, mockUploadItemId);
    assert.strictEqual(response2.idempotent, true, 'Second commit should also be idempotent');
    assert.strictEqual(mockRepository.updateUploadItemStatus.mock.callCount(), 0, 'Should still not update status');
  });

  it('should perform normal commit for non-committed item', async () => {
    const mockSessionId = 'session_123';
    const mockToken = 'token_abc';
    const mockTokenHash = hashToken(mockToken);
    const mockUploadItemId = 'item_456';
    const mockObjectKey = 'uploads/test.jpg';

    const mockSession: UploadSession = {
      id: mockSessionId,
      sessionId: mockSessionId,
      childId: 'child_1',
      token: mockToken,
      tokenHash: mockTokenHash,
      status: 'active',
      maxItems: 10,
      usedItems: 1,
      expiresAt: new Date(Date.now() + 3600000),
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // Mock upload item that is NOT yet committed
    const mockItem: UploadItem = {
      id: mockUploadItemId,
      uploadItemId: mockUploadItemId,
      sessionId: mockSessionId,
      objectKey: mockObjectKey,
      status: UploadItemStatus.UPLOADING, // Valid status for commit transition
      sizeBytes: null,
      contentType: null,
      committedAt: null, // Not committed yet
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const mockUpdatedItem: UploadItem = {
      ...mockItem,
      status: UploadItemStatus.UPLOADED_REMOTE,
      sizeBytes: 1024,
      contentType: 'image/jpeg',
      committedAt: new Date(),
    };

    const mockRepository = {
      getSessionById: mock.fn(() => Promise.resolve(mockSession)),
      getUploadItemById: mock.fn(() => Promise.resolve(mockItem)),
      updateUploadItemStatus: mock.fn(() => Promise.resolve(mockUpdatedItem)),
    };

    const mockAppConfig = {} as any;
    const mockDatasetService = {} as any;

    const service = new WebCompanionService(mockAppConfig, mockRepository as any, mockDatasetService);

    const request: CommitUploadItemRequest = {
      token: mockToken,
      objectKey: mockObjectKey,
      sizeBytes: 1024,
      contentType: 'image/jpeg',
    };

    const response = await service.commitUploadItem(mockSessionId, mockUploadItemId, request);

    assert.strictEqual(response.uploadItemId, mockUploadItemId);
    assert.strictEqual(response.status, UploadItemStatus.UPLOADED_REMOTE);
    assert.strictEqual(response.idempotent, false, 'Should return idempotent: false for first commit');

    // Verify updateUploadItemStatus WAS called at least once (for the commit)
    assert.ok(mockRepository.updateUploadItemStatus.mock.callCount() >= 1, 'Should update status for first commit');
  });

  it('should handle concurrent commits gracefully', async () => {
    const mockSessionId = 'session_123';
    const mockToken = 'token_abc';
    const mockTokenHash = hashToken(mockToken);
    const mockUploadItemId = 'item_456';
    const mockObjectKey = 'uploads/test.jpg';

    const mockSession: UploadSession = {
      id: mockSessionId,
      sessionId: mockSessionId,
      childId: 'child_1',
      token: mockToken,
      tokenHash: mockTokenHash,
      status: 'active',
      maxItems: 10,
      usedItems: 1,
      expiresAt: new Date(Date.now() + 3600000),
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    let getItemCallCount = 0;
    const mockItem: UploadItem = {
      id: mockUploadItemId,
      uploadItemId: mockUploadItemId,
      sessionId: mockSessionId,
      objectKey: mockObjectKey,
      status: UploadItemStatus.UPLOADING, // Valid status for commit transition
      sizeBytes: null,
      contentType: null,
      committedAt: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const mockRepository = {
      getSessionById: mock.fn(() => Promise.resolve(mockSession)),
      getUploadItemById: mock.fn(() => {
        getItemCallCount++;
        // First call returns uncommitted item, subsequent calls return committed item
        // This simulates the race condition where the second commit sees the result of the first
        if (getItemCallCount === 1) {
          return Promise.resolve(mockItem);
        }
        return Promise.resolve({
          ...mockItem,
          status: UploadItemStatus.UPLOADED_REMOTE,
          committedAt: new Date(),
        });
      }),
      updateUploadItemStatus: mock.fn(() => {
        return Promise.resolve({
          ...mockItem,
          status: UploadItemStatus.UPLOADED_REMOTE,
          committedAt: new Date(),
        });
      }),
    };

    const mockAppConfig = {} as any;
    const mockDatasetService = {} as any;

    const service = new WebCompanionService(mockAppConfig, mockRepository as any, mockDatasetService);

    const request: CommitUploadItemRequest = {
      token: mockToken,
      objectKey: mockObjectKey,
      sizeBytes: 1024,
      contentType: 'image/jpeg',
    };

    // Simulate concurrent commits
    const [response1, response2] = await Promise.all([
      service.commitUploadItem(mockSessionId, mockUploadItemId, request),
      service.commitUploadItem(mockSessionId, mockUploadItemId, request),
    ]);

    // Both should succeed
    assert.ok(response1.uploadItemId === mockUploadItemId);
    assert.ok(response2.uploadItemId === mockUploadItemId);

    // At most one should be non-idempotent (the first one that got through)
    const nonIdempotentCount = [response1, response2].filter(r => !r.idempotent).length;
    const idempotentCount = [response1, response2].filter(r => r.idempotent).length;
    
    assert.ok(nonIdempotentCount >= 1, 'At least one commit should succeed as non-idempotent');
    assert.ok(idempotentCount >= 1, 'At least one commit should be detected as idempotent');
  });
});
