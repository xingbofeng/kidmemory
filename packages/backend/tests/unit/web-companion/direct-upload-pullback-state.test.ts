import assert from "node:assert/strict";
import { test } from "node:test";

import {
  DIRECT_UPLOAD_PULLBACK_STATUSES,
  applyDirectUploadPullbackTransition,
  isValidDirectUploadPullbackTransition,
} from "../../../src/modules/web-companion/direct-upload-pullback-state.ts";
import type {
  DirectUploadPullbackRecord,
  DirectUploadPullbackStatus,
} from "../../../src/modules/web-companion/direct-upload-pullback-state.ts";

/**
 * direct_upload_pullbacks 状态机纯逻辑测试。
 *
 * spec 状态机：
 *   pending_remote → downloading → ready
 *                 └────────────→ failed
 *                 (失败可重试：failed → downloading)
 *
 * 守住的不变量：
 *   - status 仅取 4 个 spec 值。
 *   - 成功路径必须填充 asset_id / local_path / pulled_at。
 *   - 失败路径必须填充 error_code / error_message，且 asset_id / local_path 保持空便于幂等重试。
 */

const baseRecord: DirectUploadPullbackRecord = {
  id: "dup_test_1",
  sessionId: "wcs_direct_test",
  childId: "child_test",
  objectKey: "wcs_direct_test/uuid-drawing.jpg",
  status: "pending_remote",
  assetId: null,
  localPath: null,
  errorCode: null,
  errorMessage: null,
  pulledAt: null,
};

test("DIRECT_UPLOAD_PULLBACK_STATUSES 只包含 spec 中的 4 个值", () => {
  assert.deepEqual(
    [...DIRECT_UPLOAD_PULLBACK_STATUSES].sort(),
    ["downloading", "failed", "pending_remote", "ready"].sort(),
  );
});

test("isValidDirectUploadPullbackTransition 接受 pending_remote → downloading", () => {
  assert.equal(isValidDirectUploadPullbackTransition("pending_remote", "downloading"), true);
});

test("isValidDirectUploadPullbackTransition 接受 downloading → ready 与 downloading → failed", () => {
  assert.equal(isValidDirectUploadPullbackTransition("downloading", "ready"), true);
  assert.equal(isValidDirectUploadPullbackTransition("downloading", "failed"), true);
});

test("isValidDirectUploadPullbackTransition 接受 failed → downloading 用于重试", () => {
  assert.equal(isValidDirectUploadPullbackTransition("failed", "downloading"), true);
});

test("isValidDirectUploadPullbackTransition 拒绝跳过中间态的非法转换", () => {
  // pending_remote 不能直接跳到 ready / failed
  assert.equal(isValidDirectUploadPullbackTransition("pending_remote", "ready"), false);
  assert.equal(isValidDirectUploadPullbackTransition("pending_remote", "failed"), false);
  // ready 是终态
  assert.equal(isValidDirectUploadPullbackTransition("ready", "downloading"), false);
  assert.equal(isValidDirectUploadPullbackTransition("ready", "failed"), false);
  assert.equal(isValidDirectUploadPullbackTransition("ready", "pending_remote"), false);
  // failed 重试只能回 downloading，不能直接到 ready
  assert.equal(isValidDirectUploadPullbackTransition("failed", "ready"), false);
});

test("applyDirectUploadPullbackTransition: pending_remote → downloading 不要求 asset_id/local_path", () => {
  const next = applyDirectUploadPullbackTransition(baseRecord, {
    type: "begin_download",
  });
  assert.equal(next.status, "downloading");
  assert.equal(next.assetId, null);
  assert.equal(next.localPath, null);
  assert.equal(next.errorCode, null);
  assert.equal(next.errorMessage, null);
});

test("applyDirectUploadPullbackTransition: downloading → ready 必须填充 asset_id/local_path/pulled_at", () => {
  const downloading: DirectUploadPullbackRecord = {
    ...baseRecord,
    status: "downloading",
  };
  const pulledAt = "2026-05-14T09:02:00.000Z";
  const next = applyDirectUploadPullbackTransition(downloading, {
    type: "mark_ready",
    assetId: "asset_direct_test",
    localPath: "managed/direct/wcs_direct_test/uuid-drawing.jpg",
    pulledAt,
  });
  assert.equal(next.status, "ready");
  assert.equal(next.assetId, "asset_direct_test");
  assert.equal(next.localPath, "managed/direct/wcs_direct_test/uuid-drawing.jpg");
  assert.equal(next.pulledAt, pulledAt);
  assert.equal(next.errorCode, null);
  assert.equal(next.errorMessage, null);
});

test("applyDirectUploadPullbackTransition: downloading → ready 缺少 asset_id 时抛错", () => {
  const downloading: DirectUploadPullbackRecord = {
    ...baseRecord,
    status: "downloading",
  };
  assert.throws(
    () =>
      applyDirectUploadPullbackTransition(downloading, {
        type: "mark_ready",
        assetId: "",
        localPath: "managed/direct/wcs_direct_test/uuid-drawing.jpg",
        pulledAt: new Date().toISOString(),
      }),
    /assetId/i,
  );
});

test("applyDirectUploadPullbackTransition: downloading → ready 缺少 local_path 时抛错", () => {
  const downloading: DirectUploadPullbackRecord = {
    ...baseRecord,
    status: "downloading",
  };
  assert.throws(
    () =>
      applyDirectUploadPullbackTransition(downloading, {
        type: "mark_ready",
        assetId: "asset_direct_test",
        localPath: "",
        pulledAt: new Date().toISOString(),
      }),
    /localPath/i,
  );
});

test("applyDirectUploadPullbackTransition: downloading → failed 必须填充 error_code 与 error_message，且不填充 asset_id/local_path", () => {
  const downloading: DirectUploadPullbackRecord = {
    ...baseRecord,
    status: "downloading",
  };
  const next = applyDirectUploadPullbackTransition(downloading, {
    type: "mark_failed",
    errorCode: "remote_download_failed",
    errorMessage: "supabase storage returned 500",
  });
  assert.equal(next.status, "failed");
  assert.equal(next.errorCode, "remote_download_failed");
  assert.equal(next.errorMessage, "supabase storage returned 500");
  assert.equal(next.assetId, null, "失败路径不应填充 asset_id，便于幂等重试");
  assert.equal(next.localPath, null, "失败路径不应填充 local_path，便于幂等重试");
});

test("applyDirectUploadPullbackTransition: downloading → failed 缺少 error_code 或 error_message 时抛错", () => {
  const downloading: DirectUploadPullbackRecord = {
    ...baseRecord,
    status: "downloading",
  };
  assert.throws(
    () =>
      applyDirectUploadPullbackTransition(downloading, {
        type: "mark_failed",
        errorCode: "",
        errorMessage: "supabase storage returned 500",
      }),
    /errorCode/i,
  );
  assert.throws(
    () =>
      applyDirectUploadPullbackTransition(downloading, {
        type: "mark_failed",
        errorCode: "remote_download_failed",
        errorMessage: "",
      }),
    /errorMessage/i,
  );
});

test("applyDirectUploadPullbackTransition: failed → downloading 重试时清空 error_code 与 error_message", () => {
  const failed: DirectUploadPullbackRecord = {
    ...baseRecord,
    status: "failed",
    errorCode: "remote_download_failed",
    errorMessage: "supabase storage returned 500",
  };
  const next = applyDirectUploadPullbackTransition(failed, {
    type: "begin_download",
  });
  assert.equal(next.status, "downloading");
  assert.equal(next.errorCode, null);
  assert.equal(next.errorMessage, null);
});

test("applyDirectUploadPullbackTransition: 在 ready 上重复调用 mark_ready 是幂等 no-op", () => {
  const ready: DirectUploadPullbackRecord = {
    ...baseRecord,
    status: "ready",
    assetId: "asset_direct_test",
    localPath: "managed/direct/wcs_direct_test/uuid-drawing.jpg",
    pulledAt: "2026-05-14T09:02:00.000Z",
  };
  const next = applyDirectUploadPullbackTransition(ready, {
    type: "mark_ready",
    assetId: "asset_direct_test",
    localPath: "managed/direct/wcs_direct_test/uuid-drawing.jpg",
    pulledAt: "2026-05-14T09:02:00.000Z",
  });
  assert.deepEqual(next, ready, "ready → mark_ready 应保持不变");
});

test("applyDirectUploadPullbackTransition: 非法转换抛错并保留原记录语义（不静默吞掉）", () => {
  const ready: DirectUploadPullbackRecord = {
    ...baseRecord,
    status: "ready",
    assetId: "asset_direct_test",
    localPath: "managed/direct/wcs_direct_test/uuid-drawing.jpg",
  };
  assert.throws(
    () =>
      applyDirectUploadPullbackTransition(ready, {
        type: "mark_failed",
        errorCode: "x",
        errorMessage: "y",
      }),
    /transition/i,
  );
});

test("DirectUploadPullbackStatus 类型只接受 4 个 spec 字面量（编译期保证 + 运行期 sanity）", () => {
  // 运行期测试：把所有合法值塞进 status 不报错
  const statuses: DirectUploadPullbackStatus[] = [
    "pending_remote",
    "downloading",
    "ready",
    "failed",
  ];
  for (const s of statuses) {
    assert.ok(DIRECT_UPLOAD_PULLBACK_STATUSES.includes(s));
  }
});
