import test, { type TestContext } from 'node:test';
import assert from 'node:assert/strict';

import { CloudApiClient } from '../../../../src/modules/sync/cloud-api.client.ts';
import { useTestEnv } from '../../../test-env.ts';

type FetchCall = {
  url: string;
  options?: RequestInit;
};

function createJsonResponse(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}

function installFetchMock(handler: (call: FetchCall) => Promise<Response>) {
  const calls: FetchCall[] = [];
  const originalFetch = globalThis.fetch;
  globalThis.fetch = (async (input: RequestInfo | URL, init?: RequestInit) => {
    const url = typeof input === 'string' ? input : input.toString();
    const call = { url, options: init };
    calls.push(call);
    return handler(call);
  }) as typeof fetch;

  return {
    calls,
    restore() {
      globalThis.fetch = originalFetch;
    },
  };
}

function createClient(t: Pick<TestContext, 'after'>, baseUrl = 'http://cloud.test') {
  useTestEnv(t, {
    CLOUD_API_URL: baseUrl,
    CLOUD_API_TIMEOUT: '1000',
  });
  return new CloudApiClient();
}

test('registerDevice uses cloud-api endpoint and unwraps data envelope', async (t) => {
  const fetchMock = installFetchMock(async () =>
    createJsonResponse({
      code: 0,
      msg: 'ok',
      data: {
        id: 'dev_1',
        machineId: 'machine_1',
      },
    })
  );

  try {
    const client = createClient(t);
    const result = await client.registerDevice({
      machineId: 'machine_1',
      platform: 'darwin',
      hostname: 'local-mac',
    });

    assert.equal(result.id, 'dev_1');
    assert.equal(fetchMock.calls.length, 1);
    assert.equal(fetchMock.calls[0].url, 'http://cloud.test/devices/register');
    assert.equal(fetchMock.calls[0].options?.method, 'POST');
  } finally {
    fetchMock.restore();
  }
});

test('sync endpoints use expected paths and verbs', async (t) => {
  const fetchMock = installFetchMock(async (call) => {
    if (call.url.endsWith('/devices/dev_1/heartbeat')) {
      return createJsonResponse({ code: 0, msg: 'ok', data: { id: 'dev_1' } });
    }
    if (call.url.includes('/upload-items/pending-sync')) {
      return createJsonResponse({ code: 0, msg: 'ok', data: [] });
    }
    if (call.url.includes('/upload-items/item_1/sync-status')) {
      return createJsonResponse({
        code: 0,
        msg: 'ok',
        data: { id: 'item_1', status: 'synced' },
      });
    }
    return createJsonResponse({ code: 9999, msg: 'unexpected' }, 500);
  });

  try {
    const client = createClient(t);
    await client.heartbeat('dev_1');
    await client.getPendingUploadItems('dev_1', 7);
    await client.updateUploadItemSyncStatus('item_1', { status: 'synced' });

    assert.deepEqual(
      fetchMock.calls.map((call) => ({ url: call.url, method: call.options?.method })),
      [
        { url: 'http://cloud.test/devices/dev_1/heartbeat', method: 'PUT' },
        { url: 'http://cloud.test/upload-items/pending-sync?deviceId=dev_1&limit=7&offset=0', method: 'GET' },
        { url: 'http://cloud.test/upload-items/item_1/sync-status', method: 'PUT' },
      ]
    );
  } finally {
    fetchMock.restore();
  }
});

test('throws when cloud-api returns non-zero code', async (t) => {
  const fetchMock = installFetchMock(async () =>
    createJsonResponse({
      code: 12000,
      msg: 'business error',
      data: null,
    })
  );

  try {
    const client = createClient(t);
    await assert.rejects(
      () => client.getPendingUploadItems('dev_1'),
      /business error/
    );
  } finally {
    fetchMock.restore();
  }
});
