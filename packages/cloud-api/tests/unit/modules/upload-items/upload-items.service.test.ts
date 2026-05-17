import { describe, it, mock } from 'node:test';
import assert from 'node:assert/strict';

import { UploadItemsService } from '../../../../src/modules/upload-items/upload-items.service.ts';

describe('UploadItemsService', () => {
  it('coerces string limit/offset query values before Prisma findMany', async () => {
    const findMany = mock.fn(async () => []);
    const count = mock.fn(async () => 0);

    const service = new UploadItemsService({
      uploadItem: {
        findMany,
        count,
      },
    } as never);

    await service.getPendingSync({
      deviceId: 'device-1',
      limit: '5' as unknown as number,
      offset: '2' as unknown as number,
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
    const count = mock.fn(async () => 0);

    const service = new UploadItemsService({
      uploadItem: {
        findMany,
        count,
      },
    } as never);

    await service.getPendingSync({
      limit: 'abc' as unknown as number,
      offset: '-10' as unknown as number,
    });

    const firstCallArgs = findMany.mock.calls[0]?.arguments[0] as {
      take: number;
      skip: number;
    };

    assert.equal(firstCallArgs.take, 10);
    assert.equal(firstCallArgs.skip, 0);
  });
});
