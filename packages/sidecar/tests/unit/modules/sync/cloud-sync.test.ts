import assert from 'node:assert/strict';
import { afterEach, beforeEach, describe, test } from 'node:test';

import { SyncService } from '../../../../src/modules/sync/sync.service.ts';

function createService(options?: {
  registerDevice?: () => Promise<{ id: string }>;
  machineIdService?: { getMachineId?: () => string };
  heartbeat?: (deviceId: string) => Promise<void>;
  syncIntervalMs?: number;
}) {
  const cloudApiClient = {
    registerDevice: options?.registerDevice ?? (async () => ({ id: 'device-1' })),
    heartbeat: options?.heartbeat ?? (async () => undefined),
    getPendingUploadItems: async () => [],
    updateUploadItemSyncStatus: async () => ({}),
    getPendingJobs: async () => [],
    updateJobStatus: async () => ({}),
  };

  const machineIdService = options?.machineIdService ?? {
    getMachineId: () => 'machine-123',
  };

  const configService = {
    config: {
      supabaseStorage: {
        url: 'http://localhost',
        bucket: 'bucket',
        anonKey: 'anon',
      },
    },
  };

  const prisma = {
    asset: {
      findFirst: async () => null,
      findUnique: async () => ({ metadata: {} }),
      update: async () => ({}),
    },
  };

  const datasetService = {
    importAssets: async () => ({ ok: true, imported: [{ id: 'asset-1' }] }),
  };

  const booksService = {};

  if (options?.syncIntervalMs != null) {
    process.env.SYNC_INTERVAL_MS = String(options.syncIntervalMs);
  } else {
    delete process.env.SYNC_INTERVAL_MS;
  }

  return new SyncService(
    cloudApiClient as any,
    machineIdService as any,
    configService as any,
    prisma as any,
    datasetService as any,
    booksService as any,
  );
}

describe('SyncService', () => {
  const originalSyncInterval = process.env.SYNC_INTERVAL_MS;

  beforeEach(() => {
    delete process.env.SYNC_INTERVAL_MS;
  });

  afterEach(() => {
    if (originalSyncInterval == null) {
      delete process.env.SYNC_INTERVAL_MS;
    } else {
      process.env.SYNC_INTERVAL_MS = originalSyncInterval;
    }
  });

  test('onModuleInit should not block startup while registration runs in background', async () => {
    let resolveRegistration: ((value: { id: string }) => void) | null = null;
    const service = createService({
      registerDevice: () =>
        new Promise((resolve) => {
          resolveRegistration = resolve;
        }),
      syncIntervalMs: 10,
    });

    const startedAt = Date.now();
    service.onModuleInit();
    const elapsed = Date.now() - startedAt;
    assert.ok(elapsed < 50, `onModuleInit should return quickly, elapsed=${elapsed}ms`);

    assert.equal(service.getDeviceId(), null);
    resolveRegistration?.({ id: 'device-bg' });

    await new Promise((resolve) => setTimeout(resolve, 20));
    assert.equal(service.getDeviceId(), 'device-bg');

    service.onModuleDestroy();
  });

  test('registration failure should not crash service and should keep deviceId null', async () => {
    const service = createService({
      registerDevice: async () => {
        throw new Error('cloud unavailable');
      },
      syncIntervalMs: 10,
    });

    // Speed up retry loop for test determinism.
    (service as any).sleep = async () => undefined;

    await (service as any).initializeSync();

    assert.equal(service.getDeviceId(), null);
    service.onModuleDestroy();
  });

  test('missing machine id service should fall back to offline mode', async () => {
    const service = createService({
      machineIdService: {},
      syncIntervalMs: 10,
    });

    await (service as any).initializeSync();
    assert.equal(service.getDeviceId(), null);

    service.onModuleDestroy();
  });

  test('successful registration should start heartbeat and stop it on destroy', async () => {
    let heartbeatCalls = 0;
    const service = createService({
      registerDevice: async () => ({ id: 'device-heartbeat' }),
      heartbeat: async (deviceId: string) => {
        heartbeatCalls += 1;
        assert.equal(deviceId, 'device-heartbeat');
      },
      syncIntervalMs: 15,
    });

    service.onModuleInit();

    await new Promise((resolve) => setTimeout(resolve, 70));
    assert.ok(heartbeatCalls > 0, 'heartbeat should run after registration');

    const callsBeforeDestroy = heartbeatCalls;
    service.onModuleDestroy();

    await new Promise((resolve) => setTimeout(resolve, 60));
    assert.equal(
      heartbeatCalls,
      callsBeforeDestroy,
      'heartbeat should stop after onModuleDestroy',
    );
  });
});
