import assert from "node:assert/strict";
import { test } from "node:test";
import { HttpException, HttpStatus } from "@nestjs/common";

import {
  AppConfigService,
  loadConfigFromEnv,
} from "../../../../src/infrastructure/config/app-config.service.ts";
import { DirectUploadController } from "../../../../src/modules/web-companion/direct-upload.controller.ts";
import {
  DirectUploadService,
  type DirectUploadStorageGateway,
  type DirectUploadAssetGateway,
} from "../../../../src/modules/web-companion/direct-upload.service.ts";

/**
 * Direct Upload — controller contract tests.
 *
 * 这一组测试守住 `/web-companion/direct-upload/sessions` 与子路由的对外契约：
 *
 *   POST /web-companion/direct-upload/sessions
 *     - 返回 { sessionId, bucket, sessionPath, supabaseUrl, anonKey, publicUrl,
 *              recommendedClientLimit, expiresAtHint }
 *     - 不包含 service role key / 数据库连接串 / 本地绝对路径
 *     - 缺失必需配置时返回结构化错误（code: web_companion_direct_upload_config_missing）
 *
 *   GET /web-companion/direct-upload/sessions/:sessionId/objects
 *     - 仅返回 {bucket}/{sessionId}/ 前缀对象
 *     - 不暴露 service role key 或本地路径
 *
 *   POST /web-companion/direct-upload/sessions/:sessionId/pullback
 *     - 全量回拉 / 部分 objectKeys / 重复幂等 / 失败保留远端对象
 *
 *   GET /web-companion/direct-upload/sessions/:sessionId/status
 *     - 返回 { sessionId, items, summary }
 */

const baseEnv: Record<string, string> = {
  POSTGRES_PASSWORD: "secret-db-password",
  POSTGRES_URL: "postgres://postgres:secret-db-password@localhost:5432/kidmemory",
  KIDMEMORY_DATA_DIR: "/private/tmp/kidmemory/data",
  KIDMEMORY_WORKSPACE_DIR: "/private/tmp/kidmemory/workspace",
  KIDMEMORY_EXPORT_DIR: "/private/tmp/kidmemory/exports",
  SUPABASE_URL: "https://kidmemory.supabase.co",
  SUPABASE_SERVICE_ROLE_KEY: "service-role-secret",
  SUPABASE_ANON_KEY: "anon-public-key",
  SUPABASE_DIRECT_UPLOAD_BUCKET: "web-companion-uploads",
  WEB_COMPANION_DIRECT_PUBLIC_URL: "https://kidmemory-companion.example.com",
  WEB_COMPANION_DIRECT_UPLOAD_ENABLED: "true",
};

function configServiceFromEnv(envOverride: Record<string, string> = {}): AppConfigService {
  const config = loadConfigFromEnv({
    POSTGRES_PASSWORD: baseEnv.POSTGRES_PASSWORD,
    POSTGRES_URL: baseEnv.POSTGRES_URL,
    KIDMEMORY_DATA_DIR: baseEnv.KIDMEMORY_DATA_DIR,
    KIDMEMORY_WORKSPACE_DIR: baseEnv.KIDMEMORY_WORKSPACE_DIR,
    KIDMEMORY_EXPORT_DIR: baseEnv.KIDMEMORY_EXPORT_DIR,
  });

  const service = new AppConfigService(config);
  service.updateSupabaseStorageConfig({
    url: envOverride.SUPABASE_URL ?? baseEnv.SUPABASE_URL,
    serviceRoleKey: envOverride.SUPABASE_SERVICE_ROLE_KEY ?? baseEnv.SUPABASE_SERVICE_ROLE_KEY,
    anonKey: envOverride.SUPABASE_ANON_KEY ?? baseEnv.SUPABASE_ANON_KEY,
  });
  service.updateWebCompanionDirectUploadConfig({
    enabled: (envOverride.WEB_COMPANION_DIRECT_UPLOAD_ENABLED ?? baseEnv.WEB_COMPANION_DIRECT_UPLOAD_ENABLED) === "true",
    bucket: envOverride.SUPABASE_DIRECT_UPLOAD_BUCKET ?? baseEnv.SUPABASE_DIRECT_UPLOAD_BUCKET,
    publicUrl: envOverride.WEB_COMPANION_DIRECT_PUBLIC_URL ?? baseEnv.WEB_COMPANION_DIRECT_PUBLIC_URL,
  });
  return service;
}

interface FakeStorage {
  objects: Map<string, { size: number; contentType: string; lastModified: string; body: Buffer }>;
  listBucket: string | null;
  listPrefix: string | null;
  downloadCalls: string[];
}

function createFakeStorageGateway(): { gateway: DirectUploadStorageGateway; state: FakeStorage } {
  const state: FakeStorage = {
    objects: new Map(),
    listBucket: null,
    listPrefix: null,
    downloadCalls: [],
  };
  const gateway: DirectUploadStorageGateway = {
    async listObjects({ bucket, prefix }) {
      state.listBucket = bucket;
      state.listPrefix = prefix;
      const result = [];
      for (const [key, value] of state.objects.entries()) {
        if (key.startsWith(prefix)) {
          result.push({
            objectKey: key,
            size: value.size,
            contentType: value.contentType,
            lastModified: value.lastModified,
          });
        }
      }
      return result;
    },
    async downloadObject({ bucket, objectKey }) {
      state.downloadCalls.push(`${bucket}:${objectKey}`);
      const obj = state.objects.get(objectKey);
      if (!obj) {
        throw new Error(`fake storage: object not found ${objectKey}`);
      }
      return { body: obj.body, contentType: obj.contentType, size: obj.size };
    },
  };
  return { gateway, state };
}

interface FakeAssetIngest {
  imported: { objectKey: string; childId: string; sessionId: string; assetId: string }[];
  shouldFailOnce: boolean;
}

function createFakeAssetGateway(): { gateway: DirectUploadAssetGateway; state: FakeAssetIngest } {
  const state: FakeAssetIngest = { imported: [], shouldFailOnce: false };
  let failures = 0;
  const gateway: DirectUploadAssetGateway = {
    async importPullback({ objectKey, childId, sessionId, body, contentType }) {
      void body;
      void contentType;
      if (state.shouldFailOnce && failures === 0) {
        failures++;
        throw new Error("fake asset import failure");
      }
      const assetId = `asset_for_${objectKey}`;
      state.imported.push({ objectKey, childId, sessionId, assetId });
      return {
        assetId,
        localPath: `managed/direct/${sessionId}/${objectKey.split("/").pop()}`,
      };
    },
  };
  return { gateway, state };
}

interface FakePullbackStore {
  rows: Map<string, {
    id: string;
    sessionId: string;
    childId: string;
    objectKey: string;
    status: "failed" | "ready" | "pending_remote" | "downloading";
    assetId: string | null;
    localPath: string | null;
    errorCode: string | null;
    errorMessage: string | null;
  }>;
}

interface DirectUploadConfigError {
  code: "web_companion_direct_upload_config_missing";
  missingConfigKeys: string[];
}

function assertHttpException(
  error: unknown,
  status: number,
  code: string,
): asserts error is HttpException {
  assert.ok(error instanceof HttpException);
  assert.equal(error.getStatus(), status);
  const response = error.getResponse() as { code?: string; missingConfigKeys?: string[] };
  assert.equal(response.code, code);
}

async function captureRejected(operation: Promise<unknown>): Promise<unknown> {
  try {
    await operation;
    assert.fail("expected operation to reject");
  } catch (error) {
    return error;
  }
}

function assertDirectUploadConfigError(error: unknown): asserts error is DirectUploadConfigError {
  assert.equal(typeof error, "object");
  assert.notEqual(error, null);

  const payload = error as {
    code?: unknown;
    missingConfigKeys?: unknown;
  };
  assert.equal(payload.code, "web_companion_direct_upload_config_missing");
  assert.ok(Array.isArray(payload.missingConfigKeys));
  assert.ok(payload.missingConfigKeys.every((key) => typeof key === "string"));
}

function createFakePullbackStore() {
  const state: FakePullbackStore = { rows: new Map() };
  return {
    state,
    store: {
      async upsertPending({ sessionId, childId, objectKey }: { sessionId: string; childId: string; objectKey: string }) {
        const key = `${sessionId}::${objectKey}`;
        const existing = state.rows.get(key);
        if (existing) return existing;
        const row = {
          id: `dup_${state.rows.size + 1}`,
          sessionId,
          childId,
          objectKey,
          status: "pending_remote" as const,
          assetId: null,
          localPath: null,
          errorCode: null,
          errorMessage: null,
        };
        state.rows.set(key, row);
        return row;
      },
      async findBySessionId(sessionId: string) {
        return Array.from(state.rows.values()).filter((row) => row.sessionId === sessionId);
      },
      async update(id: string, patch: Partial<typeof state.rows extends Map<string, infer V> ? V : never>) {
        for (const [key, row] of state.rows.entries()) {
          if (row.id === id) {
            Object.assign(row, patch);
            state.rows.set(key, row);
            return row;
          }
        }
        return null;
      },
    },
  };
}

function buildController(envOverride: Record<string, string> = {}, options: {
  storageState?: FakeStorage;
  assetState?: FakeAssetIngest;
} = {}) {
  const cfg = configServiceFromEnv(envOverride);
  const storage = createFakeStorageGateway();
  const asset = createFakeAssetGateway();
  const pullback = createFakePullbackStore();
  if (options.storageState) Object.assign(storage.state, options.storageState);
  if (options.assetState) Object.assign(asset.state, options.assetState);
  const service = new DirectUploadService({
    appConfig: cfg,
    storage: storage.gateway,
    assets: asset.gateway,
    pullback: pullback.store,
    idFactory: createDeterministicIdFactory(),
  });
  const controller = new DirectUploadController(service);
  return { controller, service, storage, asset, pullback, cfg };
}

function createDeterministicIdFactory() {
  let counter = 0;
  return {
    nextSessionId: () => `wcs_direct_${++counter}`,
  };
}

test(
  "POST /sessions 返回完整非敏感字段集，且响应不泄露 service role key/db url/本地路径",
  async () => {
    const { controller, storage } = buildController();
    const response = await controller.createSession({ childId: "child_test" });
    void storage;

    assert.match(response.sessionId, /^wcs_direct_/);
    assert.equal(response.childId, "child_test");
    assert.equal(response.bucket, "web-companion-uploads");
    assert.equal(response.sessionPath, `web-companion-uploads/${response.sessionId}`);
    assert.equal(response.supabaseUrl, "https://kidmemory.supabase.co");
    assert.equal(response.anonKey, "anon-public-key");
    assert.match(response.publicUrl, /^https:\/\/kidmemory-companion\.example\.com\/direct-upload\?/);
    assert.match(response.publicUrl, /sessionId=wcs_direct_/);
    assert.match(response.publicUrl, /childId=child_test/);
    assert.match(response.publicUrl, /token=/);
    assert.equal(new URL(response.publicUrl).searchParams.get("token"), response.token);
    assert.equal(response.recommendedClientLimit, 200);
    assert.equal(response.expiresAtHintSeconds, 3 * 60 * 60);

    const serialized = JSON.stringify(response);
    assert.equal(serialized.includes("service-role-secret"), false);
    assert.equal(serialized.includes("secret-db-password"), false);
    assert.equal(serialized.includes("postgres://"), false);
    assert.equal(serialized.includes("/private/tmp"), false);
  },
);

test(
  "POST /sessions 缺失必需配置时返回 web_companion_direct_upload_config_missing 错误",
  async () => {
    const { controller } = buildController({
      // 把 SUPABASE_URL 与 SUPABASE_ANON_KEY 都置空
      SUPABASE_URL: "",
      SUPABASE_ANON_KEY: "",
    });
    const err = await captureRejected(controller.createSession({ childId: "child_test" }));
    assertHttpException(err, HttpStatus.SERVICE_UNAVAILABLE, "web_companion_direct_upload_config_missing");
    const body = err.getResponse() as DirectUploadConfigError;
    assertDirectUploadConfigError(body);
    assert.ok(body.missingConfigKeys.includes("SUPABASE_URL"));
    assert.ok(body.missingConfigKeys.includes("SUPABASE_ANON_KEY"));
  },
);

test("POST /sessions maps validation errors to 400 instead of leaking 500", async () => {
  const { controller } = buildController();

  const err = await captureRejected(controller.createSession({ childId: "" }));

  assertHttpException(err, HttpStatus.BAD_REQUEST, "child_id_required");
});

test("GET /sessions/:sessionId/status maps token errors to 401 instead of leaking 500", async () => {
  const { controller } = buildController();
  const session = await controller.createSession({ childId: "child_test" });

  const err = await captureRejected(controller.getStatus(session.sessionId, "wrong-token"));

  assertHttpException(err, HttpStatus.UNAUTHORIZED, "invalid_token");
});

test(
  "GET /sessions/:sessionId/objects 仅返回 {bucket}/{sessionId}/ 前缀对象，不混入其它 sessionId",
  async () => {
    const { controller, storage } = buildController();
    const session = await controller.createSession({ childId: "child_test" });
    storage.state.objects.set(`${session.sessionId}/uuid-a.jpg`, {
      size: 1234,
      contentType: "image/jpeg",
      lastModified: "2026-05-14T09:00:00.000Z",
      body: Buffer.from("fake-a"),
    });
    storage.state.objects.set(`${session.sessionId}/uuid-b.png`, {
      size: 5678,
      contentType: "image/png",
      lastModified: "2026-05-14T09:01:00.000Z",
      body: Buffer.from("fake-b"),
    });
    storage.state.objects.set("OTHER_SESSION/uuid-c.jpg", {
      size: 9999,
      contentType: "image/jpeg",
      lastModified: "2026-05-14T09:02:00.000Z",
      body: Buffer.from("fake-c"),
    });

    const response = await controller.listObjects(session.sessionId, session.token);
    assert.equal(response.objects.length, 2);
    const keys = response.objects.map((o) => o.objectKey).sort();
    assert.deepEqual(
      keys,
      [`${session.sessionId}/uuid-a.jpg`, `${session.sessionId}/uuid-b.png`].sort(),
    );

    // gateway 收到的 prefix 必须是 sessionId/
    assert.equal(storage.state.listBucket, "web-companion-uploads");
    assert.equal(storage.state.listPrefix, `${session.sessionId}/`);

    // 不暴露 body 或本地路径
    const serialized = JSON.stringify(response);
    assert.equal(serialized.includes("/private/tmp"), false);
    assert.equal(serialized.includes("service-role-secret"), false);
  },
);

test(
  "GET /sessions/:sessionId/objects 缺失或错误 token 时拒绝列对象",
  async () => {
    const { controller } = buildController();
    const session = await controller.createSession({ childId: "child_test" });

    const missing = await captureRejected(controller.listObjects(session.sessionId, ""));
    assertHttpException(missing, HttpStatus.UNAUTHORIZED, "token_required");

    const invalid = await captureRejected(controller.listObjects(session.sessionId, "wrong-token"));
    assertHttpException(invalid, HttpStatus.UNAUTHORIZED, "invalid_token");
  },
);

test(
  "POST /sessions/:sessionId/pullback 全量回拉成功，写入 assets 与 direct_upload_pullbacks，状态 ready",
  async () => {
    const { controller, storage, asset, pullback } = buildController();
    const session = await controller.createSession({ childId: "child_test" });
    storage.state.objects.set(`${session.sessionId}/uuid-a.jpg`, {
      size: 1234,
      contentType: "image/jpeg",
      lastModified: "2026-05-14T09:00:00.000Z",
      body: Buffer.from("fake-a"),
    });
    storage.state.objects.set(`${session.sessionId}/uuid-b.png`, {
      size: 5678,
      contentType: "image/png",
      lastModified: "2026-05-14T09:01:00.000Z",
      body: Buffer.from("fake-b"),
    });

    const response = await controller.pullback(session.sessionId, {
      token: session.token,
    });
    assert.equal(response.results.length, 2);
    for (const r of response.results) {
      assert.equal(r.status, "ready");
      assert.equal(r.errorCode, null);
    }

    // assets 注入了 2 项
    assert.equal(asset.state.imported.length, 2);

    // direct_upload_pullbacks 写入了 2 行 ready
    const rows = await pullback.store.findBySessionId(session.sessionId);
    assert.equal(rows.length, 2);
    for (const row of rows) {
      assert.equal(row.status, "ready");
      assert.ok(row.assetId);
      assert.ok(row.localPath);
    }
  },
);

test(
  "POST /sessions/:sessionId/pullback 部分 objectKeys 仅处理指定对象",
  async () => {
    const { controller, storage } = buildController();
    const session = await controller.createSession({ childId: "child_test" });
    storage.state.objects.set(`${session.sessionId}/uuid-a.jpg`, {
      size: 100,
      contentType: "image/jpeg",
      lastModified: "2026-05-14T09:00:00.000Z",
      body: Buffer.from("a"),
    });
    storage.state.objects.set(`${session.sessionId}/uuid-b.png`, {
      size: 200,
      contentType: "image/png",
      lastModified: "2026-05-14T09:01:00.000Z",
      body: Buffer.from("b"),
    });

    const response = await controller.pullback(session.sessionId, {
      token: session.token,
      objectKeys: [`${session.sessionId}/uuid-a.jpg`],
    });
    assert.equal(response.results.length, 1);
    assert.equal(response.results[0].objectKey, `${session.sessionId}/uuid-a.jpg`);
    assert.equal(response.results[0].status, "ready");
  },
);

test(
  "POST /sessions/:sessionId/pullback 指定不存在 objectKey 时返回 failed result",
  async () => {
    const { controller, storage } = buildController();
    const session = await controller.createSession({ childId: "child_test" });
    storage.state.objects.set(`${session.sessionId}/uuid-a.jpg`, {
      size: 100,
      contentType: "image/jpeg",
      lastModified: "2026-05-14T09:00:00.000Z",
      body: Buffer.from("a"),
    });

    const missingObjectKey = `${session.sessionId}/missing.jpg`;
    const response = await controller.pullback(session.sessionId, {
      token: session.token,
      objectKeys: [missingObjectKey],
    });

    assert.equal(response.results.length, 1);
    assert.equal(response.results[0].objectKey, missingObjectKey);
    assert.equal(response.results[0].status, "failed");
    assert.equal(response.results[0].errorCode, "remote_object_missing");
    assert.equal(response.results[0].errorMessage, "Remote object was not found in direct upload storage.");
  },
);

test(
  "POST /sessions/:sessionId/pullback 重复回拉对已 ready 对象幂等保持 ready",
  async () => {
    const { controller, storage, asset } = buildController();
    const session = await controller.createSession({ childId: "child_test" });
    storage.state.objects.set(`${session.sessionId}/uuid-a.jpg`, {
      size: 100,
      contentType: "image/jpeg",
      lastModified: "2026-05-14T09:00:00.000Z",
      body: Buffer.from("a"),
    });

    const first = await controller.pullback(session.sessionId, {
      token: session.token,
    });
    assert.equal(first.results[0].status, "ready");
    assert.equal(asset.state.imported.length, 1);

    const second = await controller.pullback(session.sessionId, {
      token: session.token,
    });
    assert.equal(second.results[0].status, "ready");
    // 不重复 import
    assert.equal(asset.state.imported.length, 1, "重复回拉不得再次 import asset");
  },
);

test(
  "POST /sessions/:sessionId/pullback 下载/入库失败：状态 failed、error_code/error_message 填充、远端不删除",
  async () => {
    const { controller, storage, asset, pullback } = buildController();
    const session = await controller.createSession({ childId: "child_test" });
    storage.state.objects.set(`${session.sessionId}/uuid-a.jpg`, {
      size: 100,
      contentType: "image/jpeg",
      lastModified: "2026-05-14T09:00:00.000Z",
      body: Buffer.from("a"),
    });
    asset.state.shouldFailOnce = true;

    const response = await controller.pullback(session.sessionId, {
      token: session.token,
    });
    assert.equal(response.results.length, 1);
    assert.equal(response.results[0].status, "failed");
    assert.ok(response.results[0].errorCode);
    assert.ok(response.results[0].errorMessage);

    // 远端对象不被删除
    assert.equal(storage.state.objects.has(`${session.sessionId}/uuid-a.jpg`), true);

    // 持久化记录是 failed，asset_id 与 local_path 保持空，便于幂等重试
    const rows = await pullback.store.findBySessionId(session.sessionId);
    assert.equal(rows.length, 1);
    assert.equal(rows[0].status, "failed");
    assert.equal(rows[0].assetId, null);
    assert.equal(rows[0].localPath, null);
  },
);

test(
  "GET /sessions/:sessionId/status 返回 items 与 summary",
  async () => {
    const { controller, storage } = buildController();
    const session = await controller.createSession({ childId: "child_test" });
    storage.state.objects.set(`${session.sessionId}/uuid-a.jpg`, {
      size: 1234,
      contentType: "image/jpeg",
      lastModified: "2026-05-14T09:00:00.000Z",
      body: Buffer.from("a"),
    });
    await controller.pullback(session.sessionId, {
      token: session.token,
    });

    const status = await controller.getStatus(session.sessionId, session.token);
    assert.equal(status.sessionId, session.sessionId);
    assert.equal(status.items.length, 1);
    assert.equal(status.items[0].status, "ready");
    assert.equal(status.summary.ready, 1);
    assert.equal(status.summary.failed, 0);
    assert.equal(status.summary.downloading, 0);
    assert.equal(status.summary.pending_remote, 0);

    const serialized = JSON.stringify(status);
    assert.equal(serialized.includes("service-role-secret"), false);
    assert.equal(serialized.includes("/private/tmp"), false);
  },
);

test(
  "GET /sessions/:sessionId/config 与 status 都要求 token",
  async () => {
    const { controller } = buildController();
    const session = await controller.createSession({ childId: "child_test" });

    await assert.rejects(
      () => controller.getSessionConfig(session.sessionId, ""),
      (error: unknown) => {
        assertHttpException(error, HttpStatus.UNAUTHORIZED, "token_required");
        return true;
      },
    );
    await assert.rejects(
      () => controller.getStatus(session.sessionId, "wrong-token"),
      (error: unknown) => {
        assertHttpException(error, HttpStatus.UNAUTHORIZED, "invalid_token");
        return true;
      },
    );

    const config = await controller.getSessionConfig(session.sessionId, session.token);
    assert.equal(config.bucket, "web-companion-uploads");
  },
);
