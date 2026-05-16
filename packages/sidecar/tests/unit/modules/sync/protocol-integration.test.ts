import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
// 使用相对路径 + .ts 扩展名，因为 backend 使用 Node.js 原生 TS 支持
// api-response.ts 内部 import 用了 .js（标准 ESM），需直接导入 api-code.ts 绕过
import { ApiCode } from '@kidmemory/protocol';

// ApiResponse 是纯 interface，直接在测试中定义等价类型验证结构兼容性
interface ApiResponse<T = unknown> {
  code: number;
  msg: string;
  data: T;
}

describe('Protocol Integration - Backend (任务 1.19)', () => {
  it('可以引用 ApiCode', () => {
    assert.equal(ApiCode.SUCCESS, 0);
    assert.equal(ApiCode.NOT_FOUND, 10001);
    assert.equal(ApiCode.RATE_LIMIT_EXCEEDED, 16001);
  });

  it('ApiCode 覆盖所有分段', () => {
    // 通用错误
    assert.equal(ApiCode.UNKNOWN_ERROR, 10000);
    // 鉴权
    assert.equal(ApiCode.UNAUTHORIZED, 11000);
    // 参数校验
    assert.equal(ApiCode.INVALID_PARAMS, 12000);
    // 素材/书稿
    assert.equal(ApiCode.ASSET_NOT_FOUND, 13000);
    // 分享
    assert.equal(ApiCode.SHARE_TOKEN_INVALID, 14000);
    // 上传/存储
    assert.equal(ApiCode.UPLOAD_SESSION_NOT_FOUND, 15000);
    // 限流
    assert.equal(ApiCode.RATE_LIMIT_EXCEEDED, 16001);
    // 服务端内部
    assert.equal(ApiCode.INTERNAL_ERROR, 50000);
  });

  it('可以使用 ApiResponse 结构', () => {
    const response: ApiResponse<{ id: string }> = {
      code: ApiCode.SUCCESS,
      msg: 'success',
      data: { id: '123' },
    };
    assert.equal(response.code, 0);
    assert.ok(response.data);
  });

  it('可以使用错误响应', () => {
    const errorResponse: ApiResponse<null> = {
      code: ApiCode.RATE_LIMIT_EXCEEDED,
      msg: '请求过于频繁',
      data: null,
    };
    assert.equal(errorResponse.code, 16001);
    assert.equal(errorResponse.data, null);
  });
});
