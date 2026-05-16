import test from 'node:test';
import assert from 'node:assert/strict';

import { CloudApiClient } from '../../../../src/modules/sync/cloud-api.client.ts';

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

function createClient(baseUrl = 'http://cloud.test') {
  process.env.CLOUD_API_URL = baseUrl;
  process.env.CLOUD_API_TIMEOUT = '1000';
  return new CloudApiClient({} as never);
}

test('registerDevice uses cloud-api endpoint and unwraps data envelope', async () => {
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
    const client = createClient();
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

test('sync endpoints use expected paths and verbs', async () => {
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
    if (call.url.includes('/jobs/pending')) {
      return createJsonResponse({ code: 0, msg: 'ok', data: [] });
    }
    if (call.url.includes('/jobs/job_1/status')) {
      return createJsonResponse({ code: 0, msg: 'ok', data: { id: 'job_1', status: 'completed' } });
    }
    return createJsonResponse({ code: 9999, msg: 'unexpected' }, 500);
  });

  try {
    const client = createClient();
    await client.heartbeat('dev_1');
    await client.getPendingUploadItems('dev_1', 7);
    await client.updateUploadItemSyncStatus('item_1', { status: 'synced' });
    await client.getPendingJobs('dev_1', 5);
    await client.updateJobStatus('job_1', { status: 'completed' });

    assert.deepEqual(
      fetchMock.calls.map((call) => ({ url: call.url, method: call.options?.method })),
      [
        { url: 'http://cloud.test/devices/dev_1/heartbeat', method: 'PUT' },
        { url: 'http://cloud.test/upload-items/pending-sync?deviceId=dev_1&limit=7&offset=0', method: 'GET' },
        { url: 'http://cloud.test/upload-items/item_1/sync-status', method: 'PUT' },
        { url: 'http://cloud.test/jobs/pending?deviceId=dev_1&limit=5', method: 'GET' },
        { url: 'http://cloud.test/jobs/job_1/status', method: 'PUT' },
      ]
    );
  } finally {
    fetchMock.restore();
  }
});

test('throws when cloud-api returns non-zero code', async () => {
  const fetchMock = installFetchMock(async () =>
    createJsonResponse({
      code: 12000,
      msg: 'business error',
      data: null,
    })
  );

  try {
    const client = createClient();
    await assert.rejects(
      () => client.getPendingJobs('dev_1'),
      /business error/
    );
  } finally {
    fetchMock.restore();
  }
});
