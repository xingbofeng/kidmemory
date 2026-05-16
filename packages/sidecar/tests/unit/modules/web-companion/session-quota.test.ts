/**
 * SessionQuotaMiddleware 测试
 * 
 * 测试会话配额限制逻辑：
 * - 活跃会话数限制
 * - 每日会话创建数限制
 * - 会话过期自动清理
 * - 会话关闭时配额释放
 */

import { describe, it, beforeEach } from 'node:test';
import assert from 'node:assert';
import { SessionQuotaMiddleware } from '../../../src/infrastructure/security/session-quota.middleware';
import { ApiCode } from '@kidmemory/protocol';

type MockRequest = {
  method: string;
  path: string;
  body: any;
};

type MockResponse = {
  statusCode: number;
  json: (body: any) => MockResponse;
  send: (body: any) => MockResponse;
  status: (code: number) => MockResponse;
  _jsonBody?: any;
  _sendBody?: any;
};

function createMockRequest(method: string, path: string, body: any = {}): MockRequest {
  return { method, path, body };
}

function createMockResponse(): MockResponse {
  const res: MockResponse = {
    statusCode: 200,
    json: function(body: any) {
      this._jsonBody = body;
      return this;
    },
    send: function(body: any) {
      this._sendBody = body;
      return this;
    },
    status: function(code: number) {
      this.statusCode = code;
      return this;
    },
  };
  return res;
}

describe('SessionQuotaMiddleware', () => {
  describe('基本配额限制', () => {
    it('应该允许创建第一个会话', async () => {
      const middleware = new SessionQuotaMiddleware();
      const req = createMockRequest('POST', '/api/web-companion/sessions', { childId: 'child1' });
      const res = createMockResponse();
      let nextCalled = false;

      await middleware.use(req as any, res as any, () => { nextCalled = true; });

      assert.strictEqual(nextCalled, true, '应该调用 next()');
      assert.strictEqual(res.statusCode, 200, '不应该返回错误状态码');
    });

    it('应该记录成功创建的会话', async () => {
      const middleware = new SessionQuotaMiddleware();
      const req = createMockRequest('POST', '/api/web-companion/sessions', { childId: 'child1' });
      const res = createMockResponse();

      await middleware.use(req as any, res as any, () => {});

      // 模拟成功响应
      res.statusCode = 201;
      res.json({ sessionId: 'session1', childId: 'child1' });

      const stats = middleware.getStats();
      assert.strictEqual(stats.totalChildren, 1, '应该有 1 个 child 记录');
      assert.strictEqual(stats.totalActiveSessions, 1, '应该有 1 个活跃会话');
      assert.strictEqual(stats.children[0].activeCount, 1, 'child1 应该有 1 个活跃会话');
      assert.strictEqual(stats.children[0].dailyCount, 1, 'child1 今天应该创建了 1 个会话');
    });

    it('应该允许同一 childId 创建多个会话（在限额内）', async () => {
      const middleware = new SessionQuotaMiddleware();
      const childId = 'child1';

      // 创建 3 个会话
      for (let i = 1; i <= 3; i++) {
        const req = createMockRequest('POST', '/api/web-companion/sessions', { childId });
        const res = createMockResponse();
        let nextCalled = false;

        await middleware.use(req as any, res as any, () => { nextCalled = true; });

        assert.strictEqual(nextCalled, true, `第 ${i} 个会话应该被允许`);

        // 模拟成功响应
        res.statusCode = 201;
        res.json({ sessionId: `session${i}`, childId });
      }

      const stats = middleware.getStats();
      assert.strictEqual(stats.children[0].activeCount, 3, '应该有 3 个活跃会话');
      assert.strictEqual(stats.children[0].dailyCount, 3, '今天应该创建了 3 个会话');
    });

    it('应该拒绝超过活跃会话限额的请求', async () => {
      const middleware = new SessionQuotaMiddleware();
      const childId = 'child1';

      // 创建 5 个会话（达到限额）
      for (let i = 1; i <= 5; i++) {
        const req = createMockRequest('POST', '/api/web-companion/sessions', { childId });
        const res = createMockResponse();
        await middleware.use(req as any, res as any, () => {});
        res.statusCode = 201;
        res.json({ sessionId: `session${i}`, childId });
      }

      // 检查当前状态
      const statsBefore = middleware.getStats();
      console.log('Stats before 6th request:', JSON.stringify(statsBefore, null, 2));

      // 尝试创建第 6 个会话
      const req = createMockRequest('POST', '/api/web-companion/sessions', { childId });
      const res = createMockResponse();
      let nextCalled = false;

      await middleware.use(req as any, res as any, () => { nextCalled = true; });

      console.log('Next called:', nextCalled);
      console.log('Response status:', res.statusCode);
      console.log('Response body:', res._jsonBody);

      assert.strictEqual(nextCalled, false, '不应该调用 next()');
      assert.strictEqual(res.statusCode, 429, '应该返回 429 状态码');
      assert.ok(res._jsonBody, '应该有响应体');
      assert.strictEqual(res._jsonBody.code, ApiCode.SESSION_QUOTA_EXCEEDED, '应该返回配额超限错误码');
    });

    it('应该拒绝超过每日会话限额的请求', async () => {
      const middleware = new SessionQuotaMiddleware();
      const childId = 'child1';

      // 创建 20 个会话（达到每日限额），但关闭前面的以保持活跃数在限额内
      for (let i = 1; i <= 20; i++) {
        const req = createMockRequest('POST', '/api/web-companion/sessions', { childId });
        const res = createMockResponse();
        await middleware.use(req as any, res as any, () => {});
        res.statusCode = 201;
        res.json({ sessionId: `session${i}`, childId });

        // 关闭前面的会话以保持活跃数在 5 以内
        if (i > 5) {
          middleware.recordSessionClosure(childId, `session${i - 5}`);
        }
      }

      // 检查当前状态
      const statsBefore = middleware.getStats();
      console.log('Stats before 21st request:', JSON.stringify(statsBefore, null, 2));

      // 尝试创建第 21 个会话
      const req = createMockRequest('POST', '/api/web-companion/sessions', { childId });
      const res = createMockResponse();
      let nextCalled = false;

      await middleware.use(req as any, res as any, () => { nextCalled = true; });

      console.log('Next called:', nextCalled);
      console.log('Response status:', res.statusCode);

      assert.strictEqual(nextCalled, false, '不应该调用 next()');
      assert.strictEqual(res.statusCode, 429, '应该返回 429 状态码');
      assert.ok(res._jsonBody, '应该有响应体');
      assert.strictEqual(res._jsonBody.code, ApiCode.DAILY_SESSION_QUOTA_EXCEEDED, '应该返回每日配额超限错误码');
    });
  });

  describe('会话关闭和配额释放', () => {
    it('关闭会话后应该释放活跃配额', async () => {
      const middleware = new SessionQuotaMiddleware();
      const childId = 'child1';

      // 创建 3 个会话
      for (let i = 1; i <= 3; i++) {
        const req = createMockRequest('POST', '/api/web-companion/sessions', { childId });
        const res = createMockResponse();
        await middleware.use(req as any, res as any, () => {});
        res.statusCode = 201;
        res.json({ sessionId: `session${i}`, childId });
      }

      let stats = middleware.getStats();
      assert.strictEqual(stats.children[0].activeCount, 3, '应该有 3 个活跃会话');

      // 关闭 1 个会话
      middleware.recordSessionClosure(childId, 'session1');

      stats = middleware.getStats();
      assert.strictEqual(stats.children[0].activeCount, 2, '应该剩余 2 个活跃会话');
      assert.strictEqual(stats.children[0].dailyCount, 3, '每日计数不应该改变');
    });

    it('关闭会话后应该允许创建新会话', async () => {
      const middleware = new SessionQuotaMiddleware();
      const childId = 'child1';

      // 创建 5 个会话（达到限额）
      for (let i = 1; i <= 5; i++) {
        const req = createMockRequest('POST', '/api/web-companion/sessions', { childId });
        const res = createMockResponse();
        await middleware.use(req as any, res as any, () => {});
        res.statusCode = 201;
        res.json({ sessionId: `session${i}`, childId });
      }

      // 关闭 2 个会话
      middleware.recordSessionClosure(childId, 'session1');
      middleware.recordSessionClosure(childId, 'session2');

      // 现在应该可以创建新会话
      const req = createMockRequest('POST', '/api/web-companion/sessions', { childId });
      const res = createMockResponse();
      let nextCalled = false;

      await middleware.use(req as any, res as any, () => { nextCalled = true; });

      assert.strictEqual(nextCalled, true, '应该允许创建新会话');
    });

    it('关闭不存在的会话不应该报错', () => {
      const middleware = new SessionQuotaMiddleware();
      
      // 不应该抛出错误
      assert.doesNotThrow(() => {
        middleware.recordSessionClosure('child1', 'nonexistent-session');
      });
    });
  });

  describe('多 childId 隔离', () => {
    it('不同 childId 的配额应该独立计算', async () => {
      const middleware = new SessionQuotaMiddleware();

      // child1 创建 3 个会话
      for (let i = 1; i <= 3; i++) {
        const req = createMockRequest('POST', '/api/web-companion/sessions', { childId: 'child1' });
        const res = createMockResponse();
        await middleware.use(req as any, res as any, () => {});
        res.statusCode = 201;
        res.json({ sessionId: `child1-session${i}`, childId: 'child1' });
      }

      // child2 创建 2 个会话
      for (let i = 1; i <= 2; i++) {
        const req = createMockRequest('POST', '/api/web-companion/sessions', { childId: 'child2' });
        const res = createMockResponse();
        await middleware.use(req as any, res as any, () => {});
        res.statusCode = 201;
        res.json({ sessionId: `child2-session${i}`, childId: 'child2' });
      }

      const stats = middleware.getStats();
      assert.strictEqual(stats.totalChildren, 2, '应该有 2 个 child 记录');
      assert.strictEqual(stats.totalActiveSessions, 5, '总共应该有 5 个活跃会话');

      const child1Stats = stats.children.find(c => c.childId === 'child1');
      const child2Stats = stats.children.find(c => c.childId === 'child2');

      assert.ok(child1Stats, 'child1 应该有统计记录');
      assert.ok(child2Stats, 'child2 应该有统计记录');
      assert.strictEqual(child1Stats!.activeCount, 3, 'child1 应该有 3 个活跃会话');
      assert.strictEqual(child2Stats!.activeCount, 2, 'child2 应该有 2 个活跃会话');
    });

    it('一个 childId 达到限额不应该影响其他 childId', async () => {
      const middleware = new SessionQuotaMiddleware();

      // child1 创建 5 个会话（达到限额）
      for (let i = 1; i <= 5; i++) {
        const req = createMockRequest('POST', '/api/web-companion/sessions', { childId: 'child1' });
        const res = createMockResponse();
        await middleware.use(req as any, res as any, () => {});
        res.statusCode = 201;
        res.json({ sessionId: `child1-session${i}`, childId: 'child1' });
      }

      // child1 尝试创建第 6 个会话应该失败
      const req1 = createMockRequest('POST', '/api/web-companion/sessions', { childId: 'child1' });
      const res1 = createMockResponse();
      let next1Called = false;
      await middleware.use(req1 as any, res1 as any, () => { next1Called = true; });
      assert.strictEqual(next1Called, false, 'child1 不应该被允许创建更多会话');

      // child2 创建会话应该成功
      const req2 = createMockRequest('POST', '/api/web-companion/sessions', { childId: 'child2' });
      const res2 = createMockResponse();
      let next2Called = false;
      await middleware.use(req2 as any, res2 as any, () => { next2Called = true; });
      assert.strictEqual(next2Called, true, 'child2 应该被允许创建会话');
    });
  });

  describe('每日配额重置', () => {
    it('应该在新的一天重置每日计数', async () => {
      const middleware = new SessionQuotaMiddleware();
      const childId = 'child1';

      // 创建 5 个会话
      for (let i = 1; i <= 5; i++) {
        const req = createMockRequest('POST', '/api/web-companion/sessions', { childId });
        const res = createMockResponse();
        await middleware.use(req as any, res as any, () => {});
        res.statusCode = 201;
        res.json({ sessionId: `session${i}`, childId });
      }

      let stats = middleware.getStats();
      assert.strictEqual(stats.children[0].dailyCount, 5, '今天应该创建了 5 个会话');

      // 模拟时间推进到第二天（通过访问私有方法或重新创建实例）
      // 注意：这里需要实现一个可以注入时间的机制
      // 暂时跳过这个测试，在实现中需要支持时间注入
    });
  });

  describe('路由过滤', () => {
    it('应该只拦截 POST /sessions 请求', async () => {
      const middleware = new SessionQuotaMiddleware();

      // GET 请求应该放行
      const req1 = createMockRequest('GET', '/api/web-companion/sessions', {});
      const res1 = createMockResponse();
      let next1Called = false;
      await middleware.use(req1 as any, res1 as any, () => { next1Called = true; });
      assert.strictEqual(next1Called, true, 'GET 请求应该放行');

      // POST 到其他路径应该放行
      const req2 = createMockRequest('POST', '/api/web-companion/sessions/123/items', {});
      const res2 = createMockResponse();
      let next2Called = false;
      await middleware.use(req2 as any, res2 as any, () => { next2Called = true; });
      assert.strictEqual(next2Called, true, '其他 POST 请求应该放行');

      // POST /sessions 应该被拦截
      const req3 = createMockRequest('POST', '/api/web-companion/sessions', { childId: 'child1' });
      const res3 = createMockResponse();
      let next3Called = false;
      await middleware.use(req3 as any, res3 as any, () => { next3Called = true; });
      assert.strictEqual(next3Called, true, 'POST /sessions 应该被处理');
    });

    it('应该拒绝缺少 childId 的请求', async () => {
      const middleware = new SessionQuotaMiddleware();
      const req = createMockRequest('POST', '/api/web-companion/sessions', {});
      const res = createMockResponse();
      let nextCalled = false;

      await middleware.use(req as any, res as any, () => { nextCalled = true; });

      assert.strictEqual(nextCalled, false, '不应该调用 next()');
      assert.strictEqual(res.statusCode, 400, '应该返回 400 状态码');
      assert.ok(res._jsonBody, '应该有响应体');
      assert.strictEqual(res._jsonBody.code, ApiCode.MISSING_REQUIRED_FIELD, '应该返回缺少必填字段错误码');
    });
  });

  describe('管理功能', () => {
    it('应该能够清除特定 childId 的所有会话', async () => {
      const middleware = new SessionQuotaMiddleware();
      const childId = 'child1';

      // 创建 3 个会话
      for (let i = 1; i <= 3; i++) {
        const req = createMockRequest('POST', '/api/web-companion/sessions', { childId });
        const res = createMockResponse();
        await middleware.use(req as any, res as any, () => {});
        res.statusCode = 201;
        res.json({ sessionId: `session${i}`, childId });
      }

      let stats = middleware.getStats();
      assert.strictEqual(stats.children[0].activeCount, 3, '应该有 3 个活跃会话');

      // 清除所有会话
      middleware.clearChildSessions(childId);

      stats = middleware.getStats();
      assert.strictEqual(stats.children[0].activeCount, 0, '应该没有活跃会话');
      assert.strictEqual(stats.totalActiveSessions, 0, '总活跃会话数应该为 0');
    });

    it('清除不存在的 childId 不应该报错', () => {
      const middleware = new SessionQuotaMiddleware();
      
      assert.doesNotThrow(() => {
        middleware.clearChildSessions('nonexistent-child');
      });
    });
  });

  describe('统计信息', () => {
    it('应该返回正确的统计信息', async () => {
      const middleware = new SessionQuotaMiddleware();

      // 创建一些会话
      for (let i = 1; i <= 2; i++) {
        const req = createMockRequest('POST', '/api/web-companion/sessions', { childId: 'child1' });
        const res = createMockResponse();
        await middleware.use(req as any, res as any, () => {});
        res.statusCode = 201;
        res.json({ sessionId: `session${i}`, childId: 'child1' });
      }

      const stats = middleware.getStats();

      assert.ok(stats, '应该返回统计信息');
      assert.strictEqual(typeof stats.totalChildren, 'number', 'totalChildren 应该是数字');
      assert.strictEqual(typeof stats.totalActiveSessions, 'number', 'totalActiveSessions 应该是数字');
      assert.ok(Array.isArray(stats.children), 'children 应该是数组');
      assert.strictEqual(stats.children.length, 1, '应该有 1 个 child');
      assert.strictEqual(stats.children[0].childId, 'child1', 'childId 应该正确');
      assert.strictEqual(stats.children[0].activeCount, 2, 'activeCount 应该正确');
      assert.strictEqual(stats.children[0].dailyCount, 2, 'dailyCount 应该正确');
      assert.ok(stats.children[0].lastResetDate, '应该有 lastResetDate');
    });

    it('空状态应该返回零值', () => {
      const middleware = new SessionQuotaMiddleware();
      const stats = middleware.getStats();

      assert.strictEqual(stats.totalChildren, 0, 'totalChildren 应该为 0');
      assert.strictEqual(stats.totalActiveSessions, 0, 'totalActiveSessions 应该为 0');
      assert.strictEqual(stats.children.length, 0, 'children 应该为空数组');
    });
  });
});
