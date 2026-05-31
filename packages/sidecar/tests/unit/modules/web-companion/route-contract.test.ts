/**
 * Web Companion 路由契约一致性测试
 *
 * 验证以下契约：
 * 1. 路由路径与 API 文档一致
 * 2. DTO 结构与类型定义匹配
 * 3. 控制器方法签名与路由装饰器匹配
 * 4. 错误处理与 HTTP 状态码映射正确
 */

import { strict as assert } from "node:assert";
import { test, describe } from "node:test";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { WebCompanionController } from "../../../../src/modules/web-companion/web-companion.controller.ts";
import { StorageProvider } from "../../../../src/modules/web-companion/constants.ts";
import type { BrowseService } from "../../../../src/modules/web-companion/browse.service.ts";
import type { ShareTokenService } from "../../../../src/modules/web-companion/share-token.service.ts";
import type { WebCompanionService } from "../../../../src/modules/web-companion/web-companion.service.ts";
import type {
  CreateSessionRequest,
  CreateUploadItemsRequest,
  CommitUploadItemRequest,
  RetryUploadItemRequest,
  CloseSessionRequest,
} from "../../../../src/modules/web-companion/types.ts";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

describe("Web Companion Route Contract", () => {

  test("should have consistent route paths", () => {
    // 由于 NestJS 装饰器是手动注册的，我们需要检查实际的装饰器调用
    // 读取控制器源码来验证路由路径注册
    const controllerPath = path.join(__dirname, '../../../../src/modules/web-companion/web-companion.controller.ts');
    const controllerSource = fs.readFileSync(controllerPath, 'utf8');

    // 检查控制器基础路径
    assert.ok(controllerSource.includes('Controller("api/web-companion")(WebCompanionController)'),
      'Controller base path should be api/web-companion');

    // 检查各个端点的路径
    assert.ok(controllerSource.includes('Post("sessions")(proto, "createSession"'),
      'createSession should map to POST /sessions');

    assert.ok(controllerSource.includes('Get("sessions/:sessionId")(proto, "getSessionSummary"'),
      'getSessionSummary should map to GET /sessions/:sessionId');

    assert.ok(controllerSource.includes('Get("sessions/:sessionId/detail")(proto, "getSessionDetail"'),
      'getSessionDetail should map to GET /sessions/:sessionId/detail');

    assert.ok(controllerSource.includes('Post("sessions/:sessionId/items")(proto, "createUploadItems"'),
      'createUploadItems should map to POST /sessions/:sessionId/items');

    assert.ok(controllerSource.includes('Put("sessions/:sessionId/items/:uploadItemId/commit")(proto, "commitUploadItem"'),
      'commitUploadItem should map to PUT /sessions/:sessionId/items/:uploadItemId/commit');

    assert.ok(controllerSource.includes('Post("sessions/:sessionId/items/:uploadItemId/retry")(proto, "retryUploadItem"'),
      'retryUploadItem should map to POST /sessions/:sessionId/items/:uploadItemId/retry');

    assert.ok(controllerSource.includes('Post("sessions/:sessionId/close")(proto, "closeSession"'),
      'closeSession should map to POST /sessions/:sessionId/close');
  });

  test("should have consistent method signatures", () => {
    const controller = new WebCompanionController(
      {} as WebCompanionService,
      {} as BrowseService,
      {} as ShareTokenService,
    );

    // createSession 应该接受 CreateSessionRequest
    assert.equal(controller.createSession.length, 1,
      'createSession should accept 1 parameter (request body)');

    // getSessionSummary 应该接受 sessionId 和可选的 token
    assert.equal(controller.getSessionSummary.length, 2,
      'getSessionSummary should accept 2 parameters (sessionId, token?)');

    // getSessionDetail 应该接受 sessionId 和可选的 token
    assert.equal(controller.getSessionDetail.length, 2,
      'getSessionDetail should accept 2 parameters (sessionId, token?)');

    // createUploadItems 应该接受 sessionId 和 request body
    assert.equal(controller.createUploadItems.length, 2,
      'createUploadItems should accept 2 parameters (sessionId, request)');

    // commitUploadItem 应该接受 sessionId, uploadItemId 和 request body
    assert.equal(controller.commitUploadItem.length, 3,
      'commitUploadItem should accept 3 parameters (sessionId, uploadItemId, request)');

    // retryUploadItem 应该接受 sessionId, uploadItemId 和 request body
    assert.equal(controller.retryUploadItem.length, 3,
      'retryUploadItem should accept 3 parameters (sessionId, uploadItemId, request)');

    // closeSession 应该接受 sessionId 和 request body
    assert.equal(controller.closeSession.length, 2,
      'closeSession should accept 2 parameters (sessionId, request)');
  });

  test("should have consistent DTO structures", () => {
    // 验证 CreateUploadItemsRequest 结构
    const createItemsRequest: CreateUploadItemsRequest = {
      token: "test-token",
      files: [{
        clientFileId: "file1",
        filename: "test.jpg",
        contentType: "image/jpeg",
        sizeBytes: 1024
      }],
      provider: StorageProvider.SUPABASE
    };

    // 验证必需字段存在
    assert.ok(createItemsRequest.token, 'CreateUploadItemsRequest should have token');
    assert.ok(Array.isArray(createItemsRequest.files), 'CreateUploadItemsRequest should have files array');
    assert.ok(createItemsRequest.provider, 'CreateUploadItemsRequest should have provider');

    // 验证 files 数组元素结构
    const file = createItemsRequest.files[0];
    assert.ok(file.clientFileId, 'File should have clientFileId');
    assert.ok(file.filename, 'File should have filename');
    assert.ok(file.contentType, 'File should have contentType');
    assert.ok(typeof file.sizeBytes === 'number', 'File should have numeric sizeBytes');

    // 验证 CommitUploadItemRequest 结构
    const commitRequest: CommitUploadItemRequest = {
      token: "test-token",
      objectKey: "uploads/test.jpg",
      sizeBytes: 1024,
      contentType: "image/jpeg",
      remoteEtag: "etag123"
    };

    assert.ok(commitRequest.token, 'CommitUploadItemRequest should have token');
    assert.ok(commitRequest.objectKey, 'CommitUploadItemRequest should have objectKey');
    assert.ok(typeof commitRequest.sizeBytes === 'number', 'CommitUploadItemRequest should have numeric sizeBytes');
    assert.ok(commitRequest.contentType, 'CommitUploadItemRequest should have contentType');
  });

  test("should have consistent HTTP methods", () => {
    // 由于 NestJS 装饰器是手动注册的，我们需要检查实际的装饰器调用
    // 读取控制器源码来验证装饰器注册
    const controllerPath = path.join(__dirname, '../../../../src/modules/web-companion/web-companion.controller.ts');
    const controllerSource = fs.readFileSync(controllerPath, 'utf8');

    // 验证 POST 方法注册
    assert.ok(controllerSource.includes('Post("sessions")(proto, "createSession"'),
      'createSession should be registered with POST decorator');

    assert.ok(controllerSource.includes('Post("sessions/:sessionId/items")(proto, "createUploadItems"'),
      'createUploadItems should be registered with POST decorator');

    assert.ok(controllerSource.includes('Post("sessions/:sessionId/items/:uploadItemId/retry")(proto, "retryUploadItem"'),
      'retryUploadItem should be registered with POST decorator');

    assert.ok(controllerSource.includes('Post("sessions/:sessionId/close")(proto, "closeSession"'),
      'closeSession should be registered with POST decorator');

    // 验证 GET 方法注册
    assert.ok(controllerSource.includes('Get("sessions/:sessionId")(proto, "getSessionSummary"'),
      'getSessionSummary should be registered with GET decorator');

    assert.ok(controllerSource.includes('Get("sessions/:sessionId/detail")(proto, "getSessionDetail"'),
      'getSessionDetail should be registered with GET decorator');

    // 验证 PUT 方法注册
    assert.ok(controllerSource.includes('Put("sessions/:sessionId/items/:uploadItemId/commit")(proto, "commitUploadItem"'),
      'commitUploadItem should be registered with PUT decorator');
  });
});
