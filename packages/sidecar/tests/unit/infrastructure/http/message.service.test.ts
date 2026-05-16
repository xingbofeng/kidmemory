import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { MessageService } from '../../../../src/infrastructure/http/message.service.ts';

describe('MessageService', () => {
  const service = new MessageService();

  it('should return zh-CN message by default', () => {
    const msg = service.getMessage(0);
    assert.equal(msg, '成功');
  });

  it('should return zh-CN message when locale is zh-CN', () => {
    assert.equal(service.getMessage(0, 'zh-CN'), '成功');
    assert.equal(service.getMessage(10001, 'zh-CN'), '资源不存在');
    assert.equal(service.getMessage(16001, 'zh-CN'), '请求过于频繁');
  });

  it('should return en-US message when locale is en-US', () => {
    assert.equal(service.getMessage(0, 'en-US'), 'Success');
    assert.equal(service.getMessage(10001, 'en-US'), 'Resource not found');
    assert.equal(service.getMessage(16001, 'en-US'), 'Rate limit exceeded');
  });

  it('should fallback to unknown error message for unknown code', () => {
    const msg = service.getMessage(99999, 'zh-CN');
    assert.equal(msg, '未知错误');
  });

  it('should fallback to unknown error message for unknown code in en-US', () => {
    const msg = service.getMessage(99999, 'en-US');
    assert.equal(msg, 'Unknown error');
  });

  it('should cover all error code ranges', () => {
    // 通用错误
    assert.ok(service.getMessage(10000, 'zh-CN'));
    // 认证错误
    assert.ok(service.getMessage(11000, 'zh-CN'));
    // 参数错误
    assert.ok(service.getMessage(12000, 'zh-CN'));
    // 业务错误
    assert.ok(service.getMessage(13000, 'zh-CN'));
    // 分享错误
    assert.ok(service.getMessage(14000, 'zh-CN'));
    // 上传错误
    assert.ok(service.getMessage(15000, 'zh-CN'));
    // 限流错误
    assert.ok(service.getMessage(16001, 'zh-CN'));
    // 服务器错误
    assert.ok(service.getMessage(50000, 'zh-CN'));
  });
});
