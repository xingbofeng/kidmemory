import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { ApiResponse, PageData } from '../src/common/api-response.js';
import { ApiCode } from '../src/common/api-code.js';

describe('ApiResponse', () => {
  it('成功响应格式正确', () => {
    const response: ApiResponse<{ id: string }> = {
      code: ApiCode.SUCCESS,
      msg: 'success',
      data: { id: '123' },
    };

    assert.equal(response.code, 0);
    assert.equal(response.msg, 'success');
    assert.deepEqual(response.data, { id: '123' });
  });

  it('失败响应格式正确', () => {
    const response: ApiResponse<null> = {
      code: ApiCode.NOT_FOUND,
      msg: '资源不存在',
      data: null,
    };

    assert.equal(response.code, 10001);
    assert.equal(response.msg, '资源不存在');
    assert.equal(response.data, null);
  });

  it('失败响应可以包含错误详情', () => {
    const response: ApiResponse<{ field: string; reason: string }> = {
      code: ApiCode.INVALID_PARAMS,
      msg: '参数校验失败',
      data: { field: 'email', reason: '格式不正确' },
    };

    assert.equal(response.code, 12000);
    assert.ok(response.data);
    assert.equal(response.data.field, 'email');
  });
});

describe('PageData', () => {
  it('分页响应格式正确', () => {
    const pageData: PageData<{ id: string; name: string }> = {
      items: [
        { id: '1', name: 'Item 1' },
        { id: '2', name: 'Item 2' },
      ],
      page: 1,
      pageSize: 10,
      total: 2,
    };

    assert.equal(pageData.items.length, 2);
    assert.equal(pageData.page, 1);
    assert.equal(pageData.pageSize, 10);
    assert.equal(pageData.total, 2);
  });

  it('空分页响应格式正确', () => {
    const pageData: PageData<{ id: string }> = {
      items: [],
      page: 1,
      pageSize: 10,
      total: 0,
    };

    assert.equal(pageData.items.length, 0);
    assert.equal(pageData.total, 0);
  });

  it('分页响应可以包装在 ApiResponse 中', () => {
    const response: ApiResponse<PageData<{ id: string }>> = {
      code: ApiCode.SUCCESS,
      msg: 'success',
      data: {
        items: [{ id: '1' }],
        page: 1,
        pageSize: 10,
        total: 1,
      },
    };

    assert.equal(response.code, 0);
    assert.ok(response.data);
    assert.equal(response.data.items.length, 1);
    assert.equal(response.data.total, 1);
  });
});
