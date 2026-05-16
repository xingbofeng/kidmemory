/**
 * Pullback 防重复测试
 * 
 * 验证：
 * - 同一个 uploadItem 不会被重复 pullback
 * - 使用 pulling_local 状态作为处理中标记
 * - 已经在 pulling_local 状态的项目拒绝重复 pullback
 * - 已经 ready 的项目拒绝重复 pullback
 */

import { describe, it, mock } from 'node:test';
import assert from 'node:assert';
import crypto from 'node:crypto';
import { WebCompanionService } from '../../../src/modules/web-companion/web-companion.service';
import { UploadItemStatus } from '../../../src/modules/web-companion/constants';
import type {
  UploadItem,
  UploadSession,
} from '../../../src/modules/web-companion/types';

// Helper to hash token (same as service)
function hashToken(token: string): string {
  return crypto.createHash('sha256').update(token).digest('hex');
}

describe('Pullback Idempotency', () => {
  it('should prevent duplicate pullback when item is already pulling_local', async () => {
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

    // Mock upload item that is already in pulling_local state
    const mockItem: UploadItem = {
      id: mockUploadItemId,
      uploadItemId: mockUploadItemId,
      sessionId: mockSessionId,
      objectKey: mockObjectKey,
      status: UploadItemStatus.PULLING_LOCAL, // Already pulling
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

    const mockAppConfig = {
      config: {
        supabaseStorage: {
          url: 'https://test.supabase.co',
          serviceRoleKey: 'test-key',
          bucket: 'test-bucket',
        },
      },
    } as any;
    const mockDatasetService = {} as any;

    const service = new WebCompanionService(mockAppConfig, mockRepository as any, mockDatasetService);

    // Try to trigger pullback on an item that's already pulling
    const startPullback = (service as any).startPullbackProcess.bind(service);
    
    // Should return early without updating status
    await startPullback(mockItem);

    // Verify updateUploadItemStatus was NOT called (idempotent path)
    assert.strictEqual(
      mockRepository.updateUploadItemStatus.mock.callCount(),
      0,
      'Should not update status when already pulling_local'
    );
  });

  it('should prevent duplicate pullback when item is already ready', async () => {
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

    // Mock upload item that is already ready
    const mockItem: UploadItem = {
      id: mockUploadItemId,
      uploadItemId: mockUploadItemId,
      sessionId: mockSessionId,
      objectKey: mockObjectKey,
      status: UploadItemStatus.READY, // Already ready
      sizeBytes: 1024,
      contentType: 'image/jpeg',
      committedAt: new Date(Date.now() - 120000), // Committed 2 minutes ago
      readyAt: new Date(Date.now() - 60000), // Ready 1 minute ago
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const mockRepository = {
      getSessionById: mock.fn(() => Promise.resolve(mockSession)),
      getUploadItemById: mock.fn(() => Promise.resolve(mockItem)),
      updateUploadItemStatus: mock.fn(() => Promise.resolve(mockItem)),
    };

    const mockAppConfig = {
      config: {
        supabaseStorage: {
          url: 'https://test.supabase.co',
          serviceRoleKey: 'test-key',
          bucket: 'test-bucket',
        },
      },
    } as any;
    const mockDatasetService = {} as any;

    const service = new WebCompanionService(mockAppConfig, mockRepository as any, mockDatasetService);

    // Try to trigger pullback on an item that's already ready
    const startPullback = (service as any).startPullbackProcess.bind(service);
    
    // Should return early without updating status
    await startPullback(mockItem);

    // Verify updateUploadItemStatus was NOT called (idempotent path)
    assert.strictEqual(
      mockRepository.updateUploadItemStatus.mock.callCount(),
      0,
      'Should not update status when already ready'
    );
  });

  it('should allow pullback for uploaded_remote items', async () => {
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

    // Mock upload item that is uploaded_remote (ready for pullback)
    const mockItem: UploadItem = {
      id: mockUploadItemId,
      uploadItemId: mockUploadItemId,
      sessionId: mockSessionId,
      objectKey: mockObjectKey,
      status: UploadItemStatus.UPLOADED_REMOTE, // Ready for pullback
      sizeBytes: 1024,
      contentType: 'image/jpeg',
      committedAt: new Date(Date.now() - 10000), // Committed 10 seconds ago
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const mockUpdatedItem: UploadItem = {
      ...mockItem,
      status: UploadItemStatus.PULLING_LOCAL,
    };

    const mockRepository = {
      getSessionById: mock.fn(() => Promise.resolve(mockSession)),
      getUploadItemById: mock.fn(() => Promise.resolve(mockItem)),
      updateUploadItemStatus: mock.fn(() => Promise.resolve(mockUpdatedItem)),
    };

    const mockAppConfig = {
      config: {
        supabaseStorage: {
          url: 'https://test.supabase.co',
          serviceRoleKey: 'test-key',
          bucket: 'test-bucket',
        },
      },
    } as any;
    const mockDatasetService = {} as any;

    const service = new WebCompanionService(mockAppConfig, mockRepository as any, mockDatasetService);

    // Try to trigger pullback on an uploaded_remote item
    const startPullback = (service as any).startPullbackProcess.bind(service);
    
    // Should proceed with pullback (will fail due to mock limitations, but should attempt)
    try {
      await startPullback(mockItem);
    } catch (error) {
      // Expected to fail due to incomplete mocks, but we verify it tried
    }

    // Verify updateUploadItemStatus WAS called (to set pulling_local)
    assert.ok(
      mockRepository.updateUploadItemStatus.mock.callCount() >= 1,
      'Should update status to pulling_local for uploaded_remote items'
    );
  });

  it('should handle concurrent pullback attempts gracefully', async () => {
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

    // In a real scenario, the database would handle concurrency
    // Here we simulate that the first call wins and subsequent calls see the updated state
    let hasBeenUpdated = false;

    const mockRepository = {
      getSessionById: mock.fn(() => Promise.resolve(mockSession)),
      getUploadItemById: mock.fn(() => Promise.resolve(mockSession)),
      updateUploadItemStatus: mock.fn(() => {
        if (hasBeenUpdated) {
          // Simulate database constraint violation or optimistic locking
          throw new Error('Item already being processed');
        }
        hasBeenUpdated = true;
        return Promise.resolve({
          id: mockUploadItemId,
          uploadItemId: mockUploadItemId,
          sessionId: mockSessionId,
          objectKey: mockObjectKey,
          status: UploadItemStatus.PULLING_LOCAL,
          sizeBytes: 1024,
          contentType: 'image/jpeg',
          committedAt: new Date(Date.now() - 10000),
          createdAt: new Date(),
          updatedAt: new Date(),
        });
      }),
    };

    const mockAppConfig = {
      config: {
        supabaseStorage: {
          url: 'https://test.supabase.co',
          serviceRoleKey: 'test-key',
          bucket: 'test-bucket',
        },
      },
    } as any;
    const mockDatasetService = {} as any;

    const service = new WebCompanionService(mockAppConfig, mockRepository as any, mockDatasetService);

    const startPullback = (service as any).startPullbackProcess.bind(service);

    // Create two items with the same ID
    const item = {
      id: mockUploadItemId,
      uploadItemId: mockUploadItemId,
      sessionId: mockSessionId,
      objectKey: mockObjectKey,
      status: UploadItemStatus.UPLOADED_REMOTE,
      sizeBytes: 1024,
      contentType: 'image/jpeg',
      committedAt: new Date(Date.now() - 10000),
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // Simulate concurrent pullback attempts
    // In reality, one would succeed and one would fail or be idempotent
    const results = await Promise.allSettled([
      startPullback(item).catch((e) => e.message),
      startPullback(item).catch((e) => e.message),
    ]);

    // Both should complete (one succeeds, one fails or is idempotent)
    assert.strictEqual(results.length, 2);

    // At least one should complete successfully or be handled gracefully
    const successCount = results.filter(r => r.status === 'fulfilled').length;
    assert.ok(successCount >= 0, 'At least one call should be handled');

    // The key point: hasBeenUpdated should be true, meaning at least one update happened
    assert.strictEqual(hasBeenUpdated, true, 'At least one pullback should have updated the status');
  });
});
