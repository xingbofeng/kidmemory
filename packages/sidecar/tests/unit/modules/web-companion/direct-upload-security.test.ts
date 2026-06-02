import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import {
  DirectUploadService,
  type DirectUploadSessionStore,
  type DirectUploadServiceDeps,
} from '../../../../src/modules/web-companion/direct-upload.service.ts';

function makeMinimalDeps(
  overrides: Partial<DirectUploadServiceDeps> = {},
): DirectUploadServiceDeps {
  return {
    appConfig: {
      config: {
        supabaseStorage: {
          url: 'https://test.supabase.co',
          anonKey: 'anon-key',
          serviceRoleKey: 'service-key',
        },
        webCompanionDirectUpload: {
          enabled: true,
          bucket: 'test-bucket',
          publicUrl: 'http://localhost:3001',
          recommendedClientLimit: 200,
          expiresAtHintSeconds: 10800,
        },
      },
    },
    storage: {
      listObjects: async () => [],
      downloadObject: async () => ({ body: Buffer.from(''), contentType: 'image/jpeg', size: 0 }),
    },
    assets: {
      importPullback: async () => ({ assetId: 'asset-1', localPath: '/tmp/test' }),
    },
    pullback: {
      upsertPending: async (input: { sessionId: string; childId: string; objectKey: string }) => ({
        id: '1',
        sessionId: input.sessionId,
        childId: input.childId,
        objectKey: input.objectKey,
        status: 'pending_remote' as const,
        assetId: null,
        localPath: null,
        errorCode: null,
        errorMessage: null,
      }),
      findBySessionId: async () => [],
      update: async () => null,
    },
    idFactory: { nextSessionId: () => 'test-session-id' },
    ...overrides,
  };
}

function createPersistentSessionStore(): DirectUploadSessionStore {
  const sessions = new Map<string, Parameters<DirectUploadSessionStore['insert']>[0]>();
  return {
    async insert(session) {
      sessions.set(session.sessionId, session);
    },
    async findBySessionId(sessionId) {
      return sessions.get(sessionId) ?? null;
    },
    async delete(sessionId) {
      sessions.delete(sessionId);
    },
    async deleteExpired(now) {
      let deleted = 0;
      for (const [sessionId, session] of sessions.entries()) {
        if (session.expiresAt < now) {
          sessions.delete(sessionId);
          deleted += 1;
        }
      }
      return deleted;
    },
  };
}

describe('Direct Upload security', () => {
  it('rejects empty childId', async () => {
    const service = new DirectUploadService(makeMinimalDeps());
    await assert.rejects(
      () => service.createSession({ childId: '' }),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'child_id_required');
        return true;
      },
    );
    service.destroy();
  });

  it('rejects whitespace-only childId', async () => {
    const service = new DirectUploadService(makeMinimalDeps());
    await assert.rejects(
      () => service.createSession({ childId: '   ' }),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'child_id_required');
        return true;
      },
    );
    service.destroy();
  });

  it('rejects non-existent childId when childExists is provided', async () => {
    const service = new DirectUploadService({
      ...makeMinimalDeps(),
      childExists: async () => false,
    });
    await assert.rejects(
      () => service.createSession({ childId: 'non-existent-child' }),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'child_not_found');
        return true;
      },
    );
    service.destroy();
  });

  it('accepts valid childId when childExists returns true', async () => {
    const service = new DirectUploadService({
      ...makeMinimalDeps(),
      childExists: async () => true,
    });
    const result = await service.createSession({ childId: 'valid-child' });
    assert.equal(result.childId, 'valid-child');
    assert.ok(result.sessionId);
    service.destroy();
  });

  it('skips childExists check when not provided', async () => {
    const service = new DirectUploadService(makeMinimalDeps());
    const result = await service.createSession({ childId: 'any-child' });
    assert.equal(result.childId, 'any-child');
    service.destroy();
  });

  it('createSession returns a token', async () => {
    const service = new DirectUploadService(makeMinimalDeps());
    const result = await service.createSession({ childId: 'child-1' });
    assert.ok(result.token, 'session should include a token');
    assert.equal(typeof result.token, 'string');
    assert.ok(result.token.length >= 32, `token should be at least 32 chars, got ${result.token.length}`);
    service.destroy();
  });

  it('each session gets a unique token', async () => {
    const counter = { n: 0 };
    const service = new DirectUploadService({
      ...makeMinimalDeps(),
      idFactory: { nextSessionId: () => `session-${++counter.n}` },
    });
    const r1 = await service.createSession({ childId: 'child-1' });
    const r2 = await service.createSession({ childId: 'child-1' });
    assert.notEqual(r1.token, r2.token, 'tokens should be unique per session');
    service.destroy();
  });

  it('pullback rejects invalid token', async () => {
    const service = new DirectUploadService(makeMinimalDeps());
    await service.createSession({ childId: 'child-1' });
    await assert.rejects(
      () => service.pullback('test-session-id', { token: 'wrong-token' }),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'invalid_token');
        return true;
      },
    );
    service.destroy();
  });

  it('pullback accepts correct token', async () => {
    const service = new DirectUploadService(makeMinimalDeps());
    const session = await service.createSession({ childId: 'child-1' });
    const result = await service.pullback('test-session-id', { token: session.token });
    assert.equal(result.sessionId, 'test-session-id');
    service.destroy();
  });

  it('recovers direct upload session validation from the persistent store after service restart', async () => {
    const sessionStore = createPersistentSessionStore();
    const firstService = new DirectUploadService({
      ...makeMinimalDeps(),
      sessionStore,
    });
    const session = await firstService.createSession({ childId: 'child-1' });
    firstService.destroy();

    const restartedService = new DirectUploadService({
      ...makeMinimalDeps(),
      sessionStore,
    });
    const result = await restartedService.getStatus(session.sessionId, session.token);

    assert.equal(result.sessionId, session.sessionId);
    restartedService.destroy();
  });

  it('uses the bucket persisted with the session when pulling back after config changes', async () => {
    const sessionStore = createPersistentSessionStore();
    const listBuckets: string[] = [];
    const downloadBuckets: string[] = [];
    const service = new DirectUploadService({
      ...makeMinimalDeps({
        appConfig: {
          config: {
            supabaseStorage: {
              url: 'https://test.supabase.co',
              anonKey: 'anon-key',
              serviceRoleKey: 'service-key',
            },
            webCompanionDirectUpload: {
              enabled: true,
              bucket: 'current-config-bucket',
              publicUrl: 'http://localhost:3001',
              recommendedClientLimit: 200,
              expiresAtHintSeconds: 10800,
            },
          },
        },
        sessionStore,
        storage: {
          async listObjects({ bucket, prefix }) {
            listBuckets.push(bucket);
            return [{
              objectKey: `${prefix}photo.jpg`,
              size: 12,
              contentType: 'image/jpeg',
              lastModified: new Date().toISOString(),
            }];
          },
          async downloadObject({ bucket }) {
            downloadBuckets.push(bucket);
            return { body: Buffer.from('image'), contentType: 'image/jpeg', size: 5 };
          },
        },
      }),
    });
    const session = await service.createSession({ childId: 'child-1' });
    const persisted = await sessionStore.findBySessionId(session.sessionId);
    assert.ok(persisted);
    persisted.bucket = 'persisted-session-bucket';

    const result = await service.pullback(session.sessionId, { token: session.token });

    assert.equal(result.sessionId, session.sessionId);
    assert.deepEqual(listBuckets, ['persisted-session-bucket']);
    assert.deepEqual(downloadBuckets, ['persisted-session-bucket']);
    service.destroy();
  });

  it('signs a COS direct upload object inside the session prefix without exposing the secret key', async () => {
    const service = new DirectUploadService({
      ...makeMinimalDeps({
        appConfig: {
          config: {
            supabaseStorage: {
              provider: 'cos',
              url: '',
              anonKey: '',
              serviceRoleKey: '',
              bucket: 'counter-1252496948',
              publicBaseUrl: '',
              signedUrlTtlSeconds: 300,
              s3: {
                endpoint: 'https://cos.ap-guangzhou.myqcloud.com',
                region: 'ap-guangzhou',
                accessKeyId: 'cos-secret-id',
                secretAccessKey: 'cos-secret-key',
              },
            },
            webCompanionDirectUpload: {
              enabled: true,
              bucket: 'counter-1252496948',
              publicUrl: 'http://localhost:3001',
              recommendedClientLimit: 200,
              expiresAtHintSeconds: 10800,
            },
          },
        },
      }),
    });
    const session = await service.createSession({ childId: 'child-1' });

    const signed = await service.createSignedUploadTarget(session.sessionId, {
      token: session.token,
      objectKey: `${session.sessionId}/photo.jpg`,
      contentType: 'image/jpeg',
      sizeBytes: 12,
    });

    assert.equal(signed.method, 'PUT');
    assert.match(signed.url, /^https:\/\/counter-1252496948\.cos\.ap-guangzhou\.myqcloud\.com\//);
    assert.match(signed.url, /q-sign-algorithm|sign=/);
    assert.equal(signed.url.includes('cos-secret-key'), false);
    service.destroy();
  });

  it('refuses to sign a direct upload object outside the session prefix', async () => {
    const service = new DirectUploadService(makeMinimalDeps());
    const session = await service.createSession({ childId: 'child-1' });

    await assert.rejects(
      () => service.createSignedUploadTarget(session.sessionId, {
        token: session.token,
        objectKey: 'other-session/photo.jpg',
        contentType: 'image/jpeg',
        sizeBytes: 12,
      }),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'object_key_mismatch');
        return true;
      },
    );
    service.destroy();
  });

  it('refuses to sign a direct upload object with traversal path segments', async () => {
    const service = new DirectUploadService(makeMinimalDeps());
    const session = await service.createSession({ childId: 'child-1' });

    await assert.rejects(
      () => service.createSignedUploadTarget(session.sessionId, {
        token: session.token,
        objectKey: `${session.sessionId}/../other-session/photo.jpg`,
        contentType: 'image/jpeg',
        sizeBytes: 12,
      }),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'object_key_mismatch');
        return true;
      },
    );
    service.destroy();
  });

  it('pullback without token is rejected', async () => {
    const service = new DirectUploadService(makeMinimalDeps());
    await service.createSession({ childId: 'child-1' });
    await assert.rejects(
      () => service.pullback('test-session-id', {}),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'token_required');
        return true;
      },
    );
    service.destroy();
  });

  it('pullback without request object is rejected', async () => {
    const service = new DirectUploadService(makeMinimalDeps());
    await service.createSession({ childId: 'child-1' });
    await assert.rejects(
      () => service.pullback('test-session-id', undefined),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'token_required');
        return true;
      },
    );
    service.destroy();
  });
});
