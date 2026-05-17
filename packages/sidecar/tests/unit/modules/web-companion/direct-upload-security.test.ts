import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { DirectUploadService } from '../../../../src/modules/web-companion/direct-upload.service.ts';

// 最小化 mock 依赖
function makeMinimalDeps(overrides: Record<string, unknown> = {}) {
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

describe('Direct Upload Security (任务 0.1-0.4)', () => {
  it('0.1: rejects empty childId', async () => {
    const service = new DirectUploadService(makeMinimalDeps() as any);
    await assert.rejects(
      () => service.createSession({ childId: '' }),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'child_id_required');
        return true;
      },
    );
    service.destroy();
  });

  it('0.1: rejects whitespace-only childId', async () => {
    const service = new DirectUploadService(makeMinimalDeps() as any);
    await assert.rejects(
      () => service.createSession({ childId: '   ' }),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'child_id_required');
        return true;
      },
    );
    service.destroy();
  });

  it('0.1: rejects non-existent childId when childExists is provided', async () => {
    const service = new DirectUploadService({
      ...makeMinimalDeps(),
      childExists: async () => false,
    } as any);
    await assert.rejects(
      () => service.createSession({ childId: 'non-existent-child' }),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'child_not_found');
        return true;
      },
    );
    service.destroy();
  });

  it('0.1: accepts valid childId when childExists returns true', async () => {
    const service = new DirectUploadService({
      ...makeMinimalDeps(),
      childExists: async () => true,
    } as any);
    const result = await service.createSession({ childId: 'valid-child' });
    assert.equal(result.childId, 'valid-child');
    assert.ok(result.sessionId);
    service.destroy();
  });

  it('0.1: skips childExists check when not provided', async () => {
    const service = new DirectUploadService(makeMinimalDeps() as any);
    // 没有 childExists，任何非空 childId 都应该通过
    const result = await service.createSession({ childId: 'any-child' });
    assert.equal(result.childId, 'any-child');
    service.destroy();
  });

  it('0.2: createSession returns a token', async () => {
    const service = new DirectUploadService(makeMinimalDeps() as any);
    const result = await service.createSession({ childId: 'child-1' });
    assert.ok(result.token, 'session should include a token');
    assert.equal(typeof result.token, 'string');
    assert.ok(result.token.length >= 32, `token should be at least 32 chars, got ${result.token.length}`);
    service.destroy();
  });

  it('0.2: each session gets a unique token', async () => {
    const counter = { n: 0 };
    const service = new DirectUploadService({
      ...makeMinimalDeps(),
      idFactory: { nextSessionId: () => `session-${++counter.n}` },
    } as any);
    const r1 = await service.createSession({ childId: 'child-1' });
    const r2 = await service.createSession({ childId: 'child-1' });
    assert.notEqual(r1.token, r2.token, 'tokens should be unique per session');
    service.destroy();
  });

  it('0.2: pullback rejects invalid token', async () => {
    const service = new DirectUploadService(makeMinimalDeps() as any);
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

  it('0.2: pullback accepts correct token', async () => {
    const service = new DirectUploadService(makeMinimalDeps() as any);
    const session = await service.createSession({ childId: 'child-1' });
    // 正确 token 不应该抛出
    const result = await service.pullback('test-session-id', { token: session.token });
    assert.equal(result.sessionId, 'test-session-id');
    service.destroy();
  });

  it('0.2: pullback without token is rejected', async () => {
    const service = new DirectUploadService(makeMinimalDeps() as any);
    await service.createSession({ childId: 'child-1' });
    await assert.rejects(
      () => service.pullback('test-session-id', {} as any),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'token_required');
        return true;
      },
    );
    service.destroy();
  });

  it('0.2: pullback without request object is rejected', async () => {
    const service = new DirectUploadService(makeMinimalDeps() as any);
    await service.createSession({ childId: 'child-1' });
    await assert.rejects(
      () => service.pullback('test-session-id', undefined as any),
      (err: Error & { code?: string }) => {
        assert.equal(err.code, 'token_required');
        return true;
      },
    );
    service.destroy();
  });
});
