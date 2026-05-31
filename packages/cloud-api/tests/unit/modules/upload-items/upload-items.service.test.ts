import { describe, it, mock } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

import {
  UploadItemsService,
  type UploadItemsPrismaClient,
} from '../../../../src/modules/upload-items/upload-items.service.ts';

function makeUploadItemsPrisma(
  overrides: Partial<UploadItemsPrismaClient['uploadItem']> = {},
): UploadItemsPrismaClient {
  return {
    uploadItem: {
      findMany: async () => [],
      findUnique: async () => null,
      update: async () => ({}),
      ...overrides,
    },
  };
}

describe('UploadItemsService', () => {
  it('coerces string limit/offset query values before Prisma findMany', async () => {
    const findMany = mock.fn(async () => []);
    const service = new UploadItemsService(makeUploadItemsPrisma({ findMany }));

    await service.getPendingSync({
      deviceId: 'device-1',
      limit: '5',
      offset: '2',
    });

    const firstCallArgs = findMany.mock.calls[0]?.arguments[0] as {
      take: number;
      skip: number;
      where: { deviceId?: string; status: string };
    };

    assert.equal(typeof firstCallArgs.take, 'number');
    assert.equal(typeof firstCallArgs.skip, 'number');
    assert.equal(firstCallArgs.take, 5);
    assert.equal(firstCallArgs.skip, 2);
    assert.equal(firstCallArgs.where.deviceId, 'device-1');
    assert.equal(firstCallArgs.where.status, 'uploaded');
  });

  it('falls back to safe defaults for invalid query values', async () => {
    const findMany = mock.fn(async () => []);
    const service = new UploadItemsService(makeUploadItemsPrisma({ findMany }));

    await service.getPendingSync({
      limit: 'abc',
      offset: '-10',
    });

    const firstCallArgs = findMany.mock.calls[0]?.arguments[0] as {
      take: number;
      skip: number;
    };

    assert.equal(firstCallArgs.take, 10);
    assert.equal(firstCallArgs.skip, 0);
  });

  it('keeps upload item response mapping in one shared helper', () => {
    const source = fs.readFileSync('src/modules/upload-items/upload-items.service.ts', 'utf8');

    assert.equal(source.match(/fileSize: item\.fileSize/g)?.length, 1);
  });
});
