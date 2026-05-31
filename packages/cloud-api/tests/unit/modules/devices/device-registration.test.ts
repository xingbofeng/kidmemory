import { describe, it, mock } from 'node:test';
import assert from 'node:assert/strict';
import { NotFoundException } from '@nestjs/common';

import {
  DevicesService,
  type DevicesPrismaClient,
} from '../../../../src/modules/devices/devices.service.ts';

function deviceRecord(overrides: Partial<{
  id: string;
  machineId: string;
  deviceName: string | null;
  platform: string | null;
  lastHeartbeat: Date;
  createdAt: Date;
  updatedAt: Date;
}> = {}) {
  const now = new Date('2026-05-31T00:00:00.000Z');
  return {
    id: 'device-1',
    machineId: 'machine-1',
    deviceName: 'MacBook',
    platform: 'macos',
    lastHeartbeat: now,
    createdAt: now,
    updatedAt: now,
    ...overrides,
  };
}

function makeDevicesPrisma(
  overrides: Partial<DevicesPrismaClient['device']> = {},
): DevicesPrismaClient {
  return {
    device: {
      upsert: async () => deviceRecord(),
      update: async () => deviceRecord(),
      findUnique: async () => null,
      ...overrides,
    },
  };
}

describe('DevicesService', () => {
  it('registers devices idempotently by machine id through Prisma upsert', async () => {
    const upsert = mock.fn(async () => deviceRecord({ deviceName: 'MacBook Pro' }));
    const service = new DevicesService(makeDevicesPrisma({ upsert }));

    const response = await service.register({
      machineId: 'machine-1',
      deviceName: 'MacBook Pro',
      platform: 'macos',
    });

    assert.equal(response.id, 'device-1');
    assert.equal(response.machineId, 'machine-1');
    assert.equal(response.deviceName, 'MacBook Pro');
    assert.equal(upsert.mock.calls[0].arguments[0].where.machineId, 'machine-1');
    assert.equal(upsert.mock.calls[0].arguments[0].update.deviceName, 'MacBook Pro');
  });

  it('rejects blank machine ids before writing to Prisma', async () => {
    const upsert = mock.fn();
    const service = new DevicesService(makeDevicesPrisma({ upsert }));

    await assert.rejects(
      service.register({ machineId: '   ' }),
      /machineId is required/,
    );
    assert.equal(upsert.mock.callCount(), 0);
  });

  it('updates heartbeat and maps missing devices to NotFoundException', async () => {
    const update = mock.fn(async () => deviceRecord({ id: 'device-2' }));
    const service = new DevicesService(makeDevicesPrisma({ update }));

    const response = await service.heartbeat('device-2');

    assert.equal(response.id, 'device-2');
    assert.equal(update.mock.calls[0].arguments[0].where.id, 'device-2');
    assert.ok(update.mock.calls[0].arguments[0].data.lastHeartbeat instanceof Date);

    const missing = new DevicesService({
      device: {
        upsert: async () => deviceRecord(),
        update: mock.fn(async () => { throw new Error('missing'); }),
        findUnique: async () => null,
      },
    });

    await assert.rejects(missing.heartbeat('missing'), NotFoundException);
  });

  it('reports online status from the last heartbeat time', () => {
    const service = new DevicesService(makeDevicesPrisma());

    assert.equal(service.isDeviceOnline({
      id: 'recent',
      machineId: 'machine-1',
      lastHeartbeat: new Date().toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }), true);

    assert.equal(service.isDeviceOnline({
      id: 'stale',
      machineId: 'machine-1',
      lastHeartbeat: new Date(Date.now() - 120_000).toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }), false);
  });
});
