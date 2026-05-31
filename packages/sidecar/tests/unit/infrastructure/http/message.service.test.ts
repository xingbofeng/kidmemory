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
    for (const code of [10000, 11000, 12000, 13000, 14000, 15000, 16001, 50000]) {
      assert.ok(service.getMessage(code, 'zh-CN'), String(code));
    }
  });
});
