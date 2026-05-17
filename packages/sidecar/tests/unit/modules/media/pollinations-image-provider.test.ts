import assert from 'node:assert/strict';
import test from 'node:test';

import { PollinationsImageProvider } from '../../../../src/modules/media/providers/pollinations-image.provider.ts';

test('pollinations provider builds text-only URL payload without child photo fields', async () => {
  const provider = new PollinationsImageProvider();

  const result = await provider.generate({
    prompt: 'watercolor memory book cover',
    width: 768,
    height: 1024,
    seed: 12,
    traceId: 'trace_provider_privacy',
  });

  assert.equal(result.ok, true);
  assert.equal(result.provider, 'pollinations');
  assert.equal(result.privacyBoundary.textOnly, true);
  assert.equal(result.privacyBoundary.childPhotoUpload, false);
  assert.equal(typeof result.imageUrl, 'string');

  const url = result.imageUrl ?? '';
  assert.match(url, /image\.pollinations\.ai\/prompt\//i);
  assert.ok(!url.includes('childPhoto'));
  assert.ok(!url.includes('imageUrl='));
  assert.ok(!url.includes('photo='));
});

test('pollinations provider returns recoverable error when prompt is empty', async () => {
  const provider = new PollinationsImageProvider();

  const result = await provider.generate({
    prompt: '   ',
    traceId: 'trace_provider_empty_prompt',
  });

  assert.equal(result.ok, false);
  assert.equal(result.error?.recoverable, true);
  assert.equal(result.error?.code, 'PROMPT_REQUIRED');
  assert.equal(result.privacyBoundary.textOnly, true);
});

test('pollinations provider retries timeout errors and degrades with recoverable result', async () => {
  let attempts = 0;
  const provider = new PollinationsImageProvider({
    probeEnabled: true,
    retryCount: 2,
    timeoutMs: 1,
    fetchImpl: async () => {
      attempts += 1;
      const timeoutError = new Error('request timeout');
      (timeoutError as Error & { name: string }).name = 'TimeoutError';
      throw timeoutError;
    },
  });

  const result = await provider.generate({
    prompt: 'retryable timeout case',
    traceId: 'trace_pollinations_retry',
  });

  assert.equal(attempts, 3);
  assert.equal(result.ok, false);
  assert.equal(result.error?.code, 'PROVIDER_TIMEOUT');
  assert.equal(result.error?.recoverable, true);
  assert.equal(result.privacyBoundary.textOnly, true);
  assert.equal(result.privacyBoundary.childPhotoUpload, false);
});

test('pollinations provider rejects non-text payload fields to protect privacy boundary', async () => {
  let attempts = 0;
  const provider = new PollinationsImageProvider({
    probeEnabled: true,
    retryCount: 1,
    timeoutMs: 100,
    fetchImpl: async () => {
      attempts += 1;
      return new Response(null, { status: 200 });
    },
  });

  const result = await provider.generate({
    prompt: 'family memory cover',
    imageUrl: 'https://example.com/photo.jpg',
  } as unknown as Parameters<PollinationsImageProvider['generate']>[0]);

  assert.equal(attempts, 0);
  assert.equal(result.ok, false);
  assert.equal(result.error?.code, 'PHOTO_INPUT_NOT_ALLOWED');
  assert.equal(result.error?.recoverable, true);
  assert.equal(result.privacyBoundary.textOnly, true);
  assert.equal(result.privacyBoundary.childPhotoUpload, false);
});
