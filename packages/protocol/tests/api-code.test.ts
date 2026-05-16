import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { ApiCode } from '../src/common/api-code.js';

describe('ApiCode', () => {
  it('成功码必须为 0', () => {
    assert.equal(ApiCode.SUCCESS, 0);
  });

  it('错误码必须按功能分段', () => {
    // 通用错误：10000-10999
    assert.ok(ApiCode.UNKNOWN_ERROR >= 10000 && ApiCode.UNKNOWN_ERROR < 11000);

    // 鉴权：11000-11999
    assert.ok(ApiCode.UNAUTHORIZED >= 11000 && ApiCode.UNAUTHORIZED < 12000);

    // 参数校验：12000-12999
    assert.ok(ApiCode.INVALID_PARAMS >= 12000 && ApiCode.INVALID_PARAMS < 13000);

    // 素材/书稿：13000-13999
    assert.ok(ApiCode.ASSET_NOT_FOUND >= 13000 && ApiCode.ASSET_NOT_FOUND < 14000);

    // 分享：14000-14999
    assert.ok(ApiCode.SHARE_TOKEN_INVALID >= 14000 && ApiCode.SHARE_TOKEN_INVALID < 15000);

    // 上传/存储：15000-15999
    assert.ok(ApiCode.UPLOAD_SESSION_NOT_FOUND >= 15000 && ApiCode.UPLOAD_SESSION_NOT_FOUND < 16000);

    // 限流/安全：16000-16999
    assert.ok(ApiCode.RATE_LIMIT_EXCEEDED >= 16000 && ApiCode.RATE_LIMIT_EXCEEDED < 17000);

    // 服务端内部错误：50000+
    assert.ok(ApiCode.INTERNAL_ERROR >= 50000);
  });

  it('错误码必须无重复', () => {
    const codes = Object.values(ApiCode).filter(v => typeof v === 'number');
    const uniqueCodes = new Set(codes);
    assert.equal(codes.length, uniqueCodes.size, '存在重复的错误码');
  });

  it('所有错误码必须是数字类型', () => {
    const values = Object.values(ApiCode).filter(v => typeof v === 'number');
    assert.ok(values.length > 0, '至少应该有一个错误码');
    for (const value of values) {
      assert.equal(typeof value, 'number', `错误码 ${value} 不是数字类型`);
    }
  });
});
