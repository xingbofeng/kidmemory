/**
 * 数据归属问题验证测试（简化版）
 *
 * 验证以下修复：
 * 1. Web Companion 服务不再调用不存在的 importAsset 方法
 * 2. 使用正确的 importAssets 方法
 * 3. 确保 childId 正确传递
 */

import { strict as assert } from "node:assert";
import { test, describe } from "node:test";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { DatasetService } from "../../../../src/modules/dataset/dataset.service.ts";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

describe("Web Companion Data Attribution Fixes", () => {

  test("DatasetService should not have importAsset method (singular)", () => {
    // 验证 DatasetService 没有 importAsset 方法（单数）
    const datasetService = new DatasetService({} as any, {} as any);

    // importAsset（单数）不应该存在
    const hasImportAsset = typeof (datasetService as any).importAsset === 'function';
    assert.equal(hasImportAsset, false,
      'DatasetService should not have importAsset method (singular)');

    // importAssets（复数）应该存在
    const hasImportAssets = typeof datasetService.importAssets === 'function';
    assert.equal(hasImportAssets, true,
      'DatasetService should have importAssets method (plural)');
  });

  test("Web Companion service should not call non-existent importAsset method", () => {
    // 读取 Web Companion 服务源码
    const servicePath = path.join(__dirname, '../../../src/modules/web-companion/web-companion.service.ts');
    const serviceSource = fs.readFileSync(servicePath, 'utf8');

    // 检查是否还有对不存在的 importAsset 方法的调用
    const callsImportAsset = serviceSource.includes('this.datasetService.importAsset(');

    assert.equal(callsImportAsset, false,
      'Web Companion service should not call non-existent DatasetService.importAsset method');
  });

  test("Web Companion service should use importAssets method correctly", () => {
    // 读取 Web Companion 服务源码
    const servicePath = path.join(__dirname, '../../../src/modules/web-companion/web-companion.service.ts');
    const serviceSource = fs.readFileSync(servicePath, 'utf8');

    // 检查是否正确使用 importAssets 方法
    const callsImportAssets = serviceSource.includes('this.datasetService.importAssets(');

    assert.equal(callsImportAssets, true,
      'Web Companion service should use DatasetService.importAssets method');

    // 检查是否传递了 childId 参数
    const passesChildId = serviceSource.includes('childId: session.childId');

    assert.equal(passesChildId, true,
      'Web Companion service should pass session.childId to importAssets');
  });

  test("Web Companion service should pass session childId to persistence port", () => {
    // 读取 Web Companion 服务源码
    const servicePath = path.join(__dirname, '../../../src/modules/web-companion/web-companion.service.ts');
    const serviceSource = fs.readFileSync(servicePath, 'utf8');

    const usesSessionChildId =
      serviceSource.includes("childId: options.session.childId") &&
      serviceSource.includes("createUploadItemWithAsset");

    assert.equal(usesSessionChildId, true,
      'Upload item persistence should use options.session.childId for the asset child scope');
  });

  test("Web Companion service should handle pullback with correct childId", () => {
    // 读取 Web Companion 服务源码
    const servicePath = path.join(__dirname, '../../../src/modules/web-companion/web-companion.service.ts');
    const serviceSource = fs.readFileSync(servicePath, 'utf8');

    // 检查 pullback 流程是否获取并使用正确的 childId
    const pullbackPattern = /session = await this\.getSessionById.*session\.childId/s;
    const usesPullbackChildId = pullbackPattern.test(serviceSource);

    assert.equal(usesPullbackChildId, true,
      'Pullback process should get session and use session.childId');
  });
});
