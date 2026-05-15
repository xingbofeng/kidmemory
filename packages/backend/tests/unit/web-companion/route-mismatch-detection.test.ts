/**
 * Web Companion 路由契约不匹配问题验证测试
 *
 * 这个测试应该失败，因为存在以下不匹配：
 * 1. 测试期望 upload-items 路径，但控制器注册的是 items 路径
 * 2. 测试中的 DTO 结构与类型定义不匹配
 * 3. 控制器方法签名与测试调用不匹配
 */

import { strict as assert } from "node:assert";
import { test, describe } from "node:test";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

describe("Web Companion Route Contract Mismatch Detection", () => {

  test("should detect route path mismatch between tests and implementation", () => {
    // 读取控制器源码
    const controllerPath = path.join(__dirname, '../../../src/modules/web-companion/web-companion.controller.ts');
    const controllerSource = fs.readFileSync(controllerPath, 'utf8');

    // 读取现有测试文件
    const testPath = path.join(__dirname, 'web-companion.controller.test.ts');
    const testSource = fs.readFileSync(testPath, 'utf8');

    // 检测路径不匹配：测试中使用 upload-items，控制器中使用 items
    const testUsesUploadItems = testSource.includes('POST /sessions/:sessionId/upload-items');
    const controllerUsesItems = controllerSource.includes('Post("sessions/:sessionId/items")');

    // 这应该暴露不匹配问题
    if (testUsesUploadItems && controllerUsesItems) {
      assert.fail('Route path mismatch detected: tests expect "upload-items" but controller registers "items"');
    }
  });

  test("should detect DTO structure mismatch in tests", () => {
    // 读取测试文件检查 DTO 使用
    const testPath = path.join(__dirname, 'web-companion.controller.test.ts');
    const testSource = fs.readFileSync(testPath, 'utf8');

    // 检查测试中是否使用了错误的 DTO 结构
    const usesWrongItemsStructure = testSource.includes('items: [') && testSource.includes('mimeType:');
    const usesWrongCommitStructure = testSource.includes('uploadedUrl:') && testSource.includes('uploadedSizeBytes:');

    if (usesWrongItemsStructure) {
      assert.fail('DTO mismatch detected: test uses "items" array with "mimeType" but should use "files" array with "contentType"');
    }

    if (usesWrongCommitStructure) {
      assert.fail('DTO mismatch detected: test uses "uploadedUrl" and "uploadedSizeBytes" but should use "objectKey" and "sizeBytes"');
    }
  });

  test("should detect method signature mismatch", () => {
    // 读取测试文件检查方法调用
    const testPath = path.join(__dirname, 'web-companion.controller.test.ts');
    const testSource = fs.readFileSync(testPath, 'utf8');

    // 检查是否存在错误的方法调用签名
    const wrongCreateItemsCall = testSource.includes('controller.createUploadItems(mockSessionId, mockToken, request)');
    const wrongCommitCall = testSource.includes('controller.commitUploadItem(mockSessionId, "item_123", request)');

    if (wrongCreateItemsCall) {
      assert.fail('Method signature mismatch: createUploadItems should be called with (sessionId, request), not (sessionId, token, request)');
    }

    // 注意：commitUploadItem 的调用看起来是正确的，所以这个检查可能不会失败
  });
});