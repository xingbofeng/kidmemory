import assert from 'node:assert/strict';
import { describe, test, type TestContext } from 'node:test';

import { SyncService } from '../../../../src/modules/sync/sync.service.ts';
import { useTestEnv } from '../../../test-env.ts';

type SyncServiceArgs = ConstructorParameters<typeof SyncService>;
type SyncServiceTestSurface = SyncService & {
  initializeSync(): Promise<void>;
};
type DeviceRegistration = { id: string };

function syncTestSurface(service: SyncService): SyncServiceTestSurface {
  return service as unknown as SyncServiceTestSurface;
}

async function advanceRetryBackoff(t: Pick<TestContext, 'mock'>) {
  for (const delayMs of [1000, 2000, 4000]) {
    await flushPromises();
    t.mock.timers.tick(delayMs);
  }
  await flushPromises();
}

async function flushPromises() {
  await Promise.resolve();
  await Promise.resolve();
}

function createService(options?: {
  registerDevice?: () => Promise<DeviceRegistration>;
  machineIdService?: { getMachineId?: () => string };
  heartbeat?: (deviceId: string) => Promise<void>;
}) {
  const cloudApiClient: SyncServiceArgs[0] = {
    registerDevice: options?.registerDevice ?? (async () => ({ id: 'device-1' })),
    heartbeat: options?.heartbeat ?? (async () => undefined),
    getPendingUploadItems: async () => [],
    updateUploadItemSyncStatus: async () => undefined,
  } as unknown as SyncServiceArgs[0];

  const machineIdService = (options?.machineIdService ?? {
    getMachineId: () => 'machine-123',
  }) as unknown as SyncServiceArgs[1];

  const configService = {
    config: {
      supabaseStorage: {
        url: 'http://localhost',
        bucket: 'bucket',
        anonKey: 'anon',
        serviceRoleKey: '',
      },
    },
  } as unknown as SyncServiceArgs[2];

  const prisma = {
    asset: {
      findFirst: async () => null,
      findUnique: async () => ({ metadata: {} }),
      update: async () => ({}),
    },
  } as unknown as SyncServiceArgs[3];

  const datasetService = {
    importAssets: async () => ({ ok: true, imported: [{ id: 'asset-1' }] }),
  } as unknown as SyncServiceArgs[4];

  return new SyncService(
    cloudApiClient,
    machineIdService,
    configService,
    prisma,
    datasetService,
  );
}

describe('SyncService', () => {
  test('onModuleInit should not block startup while registration runs in background', async (t) => {
    useTestEnv(t, { SYNC_INTERVAL_MS: '10' });

    let resolveRegistration: ((value: { id: string }) => void) | null = null;
    const service = createService({
      registerDevice: () =>
        new Promise((resolve) => {
          resolveRegistration = resolve;
        }),
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

  test('registration failure should not crash service and should keep deviceId null', async (t) => {
    useTestEnv(t, { SYNC_INTERVAL_MS: '10' });
    t.mock.timers.enable({ apis: ['setTimeout'] });

    const service = createService({
      registerDevice: async () => {
        throw new Error('cloud unavailable');
      },
    });

    const init = syncTestSurface(service).initializeSync();
    await advanceRetryBackoff(t);
    await init;

    assert.equal(service.getDeviceId(), null);
    service.onModuleDestroy();
  });

  test('missing machine id service should fall back to offline mode', async (t) => {
    useTestEnv(t, { SYNC_INTERVAL_MS: '10' });

    const service = createService({
      machineIdService: {},
    });

    await syncTestSurface(service).initializeSync();
    assert.equal(service.getDeviceId(), null);

    service.onModuleDestroy();
  });

  test('cloud sync disabled should skip registration entirely', async (t) => {
    useTestEnv(t, {
      KIDMEMORY_DISABLE_CLOUD_SYNC: '1',
      SYNC_INTERVAL_MS: '10',
    });

    let registerCalls = 0;
    const service = createService({
      registerDevice: async () => {
        registerCalls += 1;
        return { id: 'device-disabled' };
      },
    });

    await syncTestSurface(service).initializeSync();
    assert.equal(registerCalls, 0);
    assert.equal(service.getDeviceId(), null);

    service.onModuleDestroy();
  });

  test('successful registration should start heartbeat and stop it on destroy', async (t) => {
    useTestEnv(t, { SYNC_INTERVAL_MS: '15' });

    let heartbeatCalls = 0;
    const service = createService({
      registerDevice: async () => ({ id: 'device-heartbeat' }),
      heartbeat: async (deviceId: string) => {
        heartbeatCalls += 1;
        assert.equal(deviceId, 'device-heartbeat');
      },
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
