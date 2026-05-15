import assert from "node:assert/strict";
import { test } from "node:test";

import {
  assertWebCompanionDirectUploadReady,
  collectWebCompanionDirectUploadMissing,
  loadConfigFromEnv,
  redactConfig,
  redactWebCompanionDirectUpload,
  WebCompanionDirectUploadConfigError,
} from "../../../src/infrastructure/config/app-config.service.ts";

/**
 * Web Companion Supabase Direct Upload — config redaction & validation tests.
 *
 * 这一组测试守住「配置脱敏边界」与「缺失必需项时拒绝签发」两条 spec 红线：
 *   - service role key、数据库连接串、本地绝对路径不能出现在 sidecar 暴露给前端的脱敏结构里。
 *   - SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_DIRECT_UPLOAD_BUCKET / WEB_COMPANION_DIRECT_PUBLIC_URL
 *     四项中任一缺失，签发会话前置必须抛出可行动错误。
 */

const baseEnvWithSecrets: Record<string, string> = {
  POSTGRES_HOST: "localhost",
  POSTGRES_PORT: "5432",
  POSTGRES_DATABASE: "kidmemory",
  POSTGRES_USER: "postgres",
  POSTGRES_PASSWORD: "very-secret-db-password",
  POSTGRES_URL: "postgres://postgres:very-secret-db-password@localhost:5432/kidmemory",
  KIDMEMORY_WORKSPACE_DIR: "/private/tmp/kidmemory/workspace",
  KIDMEMORY_EXPORT_DIR: "/private/tmp/kidmemory/exports",
  KIDMEMORY_DATA_DIR: "/private/tmp/kidmemory/data",
  SUPABASE_URL: "https://kidmemory.supabase.co",
  SUPABASE_SERVICE_ROLE_KEY: "supabase-service-role-secret",
  SUPABASE_ANON_KEY: "supabase-anon-public-but-routed-through-sidecar",
  SUPABASE_DIRECT_UPLOAD_BUCKET: "web-companion-uploads",
  WEB_COMPANION_DIRECT_PUBLIC_URL: "https://kidmemory-companion.example.com",
  WEB_COMPANION_DIRECT_UPLOAD_ENABLED: "true",
};

test(
  "redactConfig 暴露 Web Companion Direct Upload 脱敏快照，但不泄露 service role key、anon key 原文、本地绝对路径或 db 连接串",
  () => {
    const config = loadConfigFromEnv(baseEnvWithSecrets);
    const redacted = redactConfig(config);

    // 基础结构断言：脱敏快照里能看到 Direct Upload 子段
    assert.ok(redacted.webCompanionDirectUpload, "redacted config must expose webCompanionDirectUpload section");
    assert.equal(redacted.webCompanionDirectUpload.enabled, true);
    assert.equal(redacted.webCompanionDirectUpload.bucket, "web-companion-uploads");
    assert.equal(redacted.webCompanionDirectUpload.publicUrl, "https://kidmemory-companion.example.com");
    assert.equal(redacted.webCompanionDirectUpload.bucketConfigured, true);
    assert.equal(redacted.webCompanionDirectUpload.publicUrlConfigured, true);
    assert.equal(redacted.webCompanionDirectUpload.anonKeyConfigured, true);
    assert.equal(redacted.webCompanionDirectUpload.serviceRoleKeyConfigured, true);
    assert.equal(redacted.webCompanionDirectUpload.canSignSession, true);
    assert.deepEqual(redacted.webCompanionDirectUpload.missingConfigKeys, []);

    // 关键脱敏断言：service role key、anon key 原文、db 连接串、本地路径都不允许出现在序列化结果里
    const serialized = JSON.stringify(redacted);
    assert.equal(
      serialized.includes("supabase-service-role-secret"),
      false,
      "service role key must not appear in redacted output",
    );
    assert.equal(
      serialized.includes("supabase-anon-public-but-routed-through-sidecar"),
      false,
      "anon key value must not be embedded in redacted output (sidecar forwards via session API only)",
    );
    assert.equal(
      serialized.includes("very-secret-db-password"),
      false,
      "postgres password must not appear in redacted output",
    );
    assert.equal(
      serialized.includes("postgres://postgres:"),
      false,
      "database connection url must not appear in redacted output",
    );
    // 注意：redactConfig 仍然会暴露 paths（既有 0.x 行为），但 **session 签发响应** 不会复用 paths。
    // 这里我们直接检查 webCompanionDirectUpload 子段不包含本地绝对路径。
    const directUploadSerialized = JSON.stringify(redacted.webCompanionDirectUpload);
    assert.equal(
      directUploadSerialized.includes("/private/tmp"),
      false,
      "Direct Upload section must not embed local absolute paths",
    );
  },
);

test(
  "redactWebCompanionDirectUpload 单独调用时同样不泄露敏感值",
  () => {
    const config = loadConfigFromEnv(baseEnvWithSecrets);
    const snapshot = redactWebCompanionDirectUpload(config);
    const serialized = JSON.stringify(snapshot);

    assert.equal(snapshot.canSignSession, true);
    assert.deepEqual(snapshot.missingConfigKeys, []);
    assert.equal(snapshot.serviceRoleKeyConfigured, true);
    assert.equal(snapshot.anonKeyConfigured, true);

    assert.equal(serialized.includes("supabase-service-role-secret"), false);
    assert.equal(serialized.includes("supabase-anon-public-but-routed-through-sidecar"), false);
    assert.equal(serialized.includes("very-secret-db-password"), false);
    assert.equal(serialized.includes("/private/tmp"), false);
  },
);

test(
  "collectWebCompanionDirectUploadMissing 空配置下报告全部 4 个必需项缺失",
  () => {
    const config = loadConfigFromEnv({});
    const missing = collectWebCompanionDirectUploadMissing(config);
    assert.deepEqual(
      missing.sort(),
      [
        "SUPABASE_ANON_KEY",
        "SUPABASE_DIRECT_UPLOAD_BUCKET",
        "SUPABASE_URL",
        "WEB_COMPANION_DIRECT_PUBLIC_URL",
      ].sort(),
    );

    // assertWebCompanionDirectUploadReady 也应抛错并把 4 个 key 全部列出
    assert.throws(
      () => assertWebCompanionDirectUploadReady(config),
      (err: unknown) => {
        assert.ok(err instanceof WebCompanionDirectUploadConfigError);
        assert.deepEqual(
          err.missingConfigKeys.sort(),
          [
            "SUPABASE_ANON_KEY",
            "SUPABASE_DIRECT_UPLOAD_BUCKET",
            "SUPABASE_URL",
            "WEB_COMPANION_DIRECT_PUBLIC_URL",
          ].sort(),
        );
        return true;
      },
    );
  },
);

test(
  "缺失 SUPABASE_URL 时 assertWebCompanionDirectUploadReady 抛出可行动错误",
  () => {
    const env = { ...baseEnvWithSecrets };
    delete env.SUPABASE_URL;
    const config = loadConfigFromEnv(env);

    assert.throws(
      () => assertWebCompanionDirectUploadReady(config),
      (err: unknown) => {
        assert.ok(err instanceof WebCompanionDirectUploadConfigError, "应抛出 WebCompanionDirectUploadConfigError");
        assert.equal(err.code, "web_companion_direct_upload_config_missing");
        assert.deepEqual(err.missingConfigKeys, ["SUPABASE_URL"]);
        assert.ok(
          err.message.includes("SUPABASE_URL"),
          "错误消息必须列出缺失的配置 key 名称",
        );
        // 错误消息不能包含具体值或本地路径
        assert.equal(err.message.includes("supabase-service-role-secret"), false);
        assert.equal(err.message.includes("/private/tmp"), false);
        return true;
      },
    );

    const snapshot = redactWebCompanionDirectUpload(config);
    assert.equal(snapshot.canSignSession, false);
    assert.deepEqual(snapshot.missingConfigKeys, ["SUPABASE_URL"]);
  },
);

test(
  "缺失 SUPABASE_ANON_KEY 时 assertWebCompanionDirectUploadReady 抛出可行动错误",
  () => {
    const env = { ...baseEnvWithSecrets };
    delete env.SUPABASE_ANON_KEY;
    const config = loadConfigFromEnv(env);

    assert.throws(
      () => assertWebCompanionDirectUploadReady(config),
      (err: unknown) => {
        assert.ok(err instanceof WebCompanionDirectUploadConfigError);
        assert.deepEqual(err.missingConfigKeys, ["SUPABASE_ANON_KEY"]);
        return true;
      },
    );
  },
);

test(
  "缺失 WEB_COMPANION_DIRECT_PUBLIC_URL 时 assertWebCompanionDirectUploadReady 抛出可行动错误",
  () => {
    const env = { ...baseEnvWithSecrets };
    delete env.WEB_COMPANION_DIRECT_PUBLIC_URL;
    const config = loadConfigFromEnv(env);

    assert.throws(
      () => assertWebCompanionDirectUploadReady(config),
      (err: unknown) => {
        assert.ok(err instanceof WebCompanionDirectUploadConfigError);
        assert.deepEqual(err.missingConfigKeys, ["WEB_COMPANION_DIRECT_PUBLIC_URL"]);
        return true;
      },
    );
  },
);

test(
  "service role key 缺失时仍可签发（service role 是可选项，回退到 anon key + bucket policy）",
  () => {
    const env = { ...baseEnvWithSecrets };
    delete env.SUPABASE_SERVICE_ROLE_KEY;
    const config = loadConfigFromEnv(env);

    // 必需项齐全（SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_DIRECT_UPLOAD_BUCKET / WEB_COMPANION_DIRECT_PUBLIC_URL），
    // 即使 service role key 缺失也应该允许签发会话——sidecar 后续会回退到 anon key + bucket policy。
    assert.deepEqual(collectWebCompanionDirectUploadMissing(config), []);
    assert.doesNotThrow(() => assertWebCompanionDirectUploadReady(config));

    const snapshot = redactWebCompanionDirectUpload(config);
    assert.equal(snapshot.canSignSession, true);
    assert.equal(snapshot.serviceRoleKeyConfigured, false);
    assert.equal(snapshot.anonKeyConfigured, true);
  },
);

test(
  "feature flag 默认关闭；不设置 WEB_COMPANION_DIRECT_UPLOAD_ENABLED 时 enabled === false",
  () => {
    const env = { ...baseEnvWithSecrets };
    delete env.WEB_COMPANION_DIRECT_UPLOAD_ENABLED;
    const config = loadConfigFromEnv(env);
    assert.equal(config.webCompanionDirectUpload.enabled, false);
  },
);

test(
  "WEB_COMPANION_DIRECT_UPLOAD_ENABLED 接受多种 truthy / falsy 字面量",
  () => {
    for (const value of ["1", "true", "yes", "on", "TRUE"]) {
      const config = loadConfigFromEnv({
        ...baseEnvWithSecrets,
        WEB_COMPANION_DIRECT_UPLOAD_ENABLED: value,
      });
      assert.equal(
        config.webCompanionDirectUpload.enabled,
        true,
        `value ${JSON.stringify(value)} should map to enabled=true`,
      );
    }
    for (const value of ["0", "false", "no", "off", "FALSE"]) {
      const config = loadConfigFromEnv({
        ...baseEnvWithSecrets,
        WEB_COMPANION_DIRECT_UPLOAD_ENABLED: value,
      });
      assert.equal(
        config.webCompanionDirectUpload.enabled,
        false,
        `value ${JSON.stringify(value)} should map to enabled=false`,
      );
    }
  },
);

test(
  "recommendedClientLimit / expiresAtHintSeconds 有合理默认且能被环境覆盖",
  () => {
    const defaults = loadConfigFromEnv({});
    assert.equal(defaults.webCompanionDirectUpload.recommendedClientLimit, 200);
    assert.equal(defaults.webCompanionDirectUpload.expiresAtHintSeconds, 3 * 60 * 60);

    const overridden = loadConfigFromEnv({
      WEB_COMPANION_DIRECT_RECOMMENDED_CLIENT_LIMIT: "50",
      WEB_COMPANION_DIRECT_EXPIRES_AT_HINT_SECONDS: "1800",
    });
    assert.equal(overridden.webCompanionDirectUpload.recommendedClientLimit, 50);
    assert.equal(overridden.webCompanionDirectUpload.expiresAtHintSeconds, 1800);
  },
);
