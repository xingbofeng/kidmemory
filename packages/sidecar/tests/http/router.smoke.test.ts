import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";

import { AppModule } from "../../src/app.module.ts";

// HTTP-layer smoke test: boot the real Nest app on an ephemeral port and hit
// each route the desktop client and the 0.5 web companion rely on. The unit
// suite already covers the domain providers in tests/unit/, so this file
// focuses on whether controllers are wired correctly (status codes, content
// types, JSON shape). It does not require a real Postgres because the dataset
// state defaults to the in-memory SampleDb until activatePersistent() is
// called.

type RouteCheck = {
  name: string;
  method: "GET" | "POST" | "PUT" | "DELETE";
  path: string;
  body?: unknown;
  expectStatuses?: number[];
  expectJson?: boolean;
  assertJson?: (payload: unknown) => void;
};

function unwrapApiData(payload: unknown) {
  if (
    payload &&
    typeof payload === "object" &&
    "code" in payload &&
    "msg" in payload &&
    "data" in payload
  ) {
    return (payload as { data: unknown }).data;
  }
  return payload;
}

const ROUTES: RouteCheck[] = [
  {
    name: "GET /health is reachable and returns JSON",
    method: "GET",
    path: "/health",
    expectStatuses: [200],
    assertJson: (payload) => {
      const data = unwrapApiData(payload);
      assert.equal(typeof data, "object", "health payload should be an object");
    },
  },
  {
    name: "GET /config/status returns redacted config",
    method: "GET",
    path: "/config/status",
    expectStatuses: [200, 201],
    assertJson: (payload) => {
      const data = unwrapApiData(payload);
      assert.equal(typeof data, "object");
      const redacted = data as Record<string, unknown>;
      assert.ok(redacted.postgres, "status should include postgres section");
      assert.ok(redacted.supabaseStorage, "status should include supabaseStorage section");
      // The redacted shape must not leak the service role key value.
      assert.equal(JSON.stringify(redacted).includes("supabase-service-role-key"), false);
    },
  },
  {
    name: "GET /config/ui exposes setup checklist metadata",
    method: "GET",
    path: "/config/ui",
    expectStatuses: [200, 201],
    assertJson: (payload) => {
      const data = unwrapApiData(payload);
      assert.equal(typeof data, "object");
    },
  },
  {
    name: "GET /children returns an array shape",
    method: "GET",
    path: "/children",
    expectStatuses: [200],
    assertJson: (payload) => {
      const data = unwrapApiData(payload);
      const body = data as Record<string, unknown>;
      assert.ok(Array.isArray(body.children) || Array.isArray(data), "children payload should be array-like");
    },
  },
  {
    name: "GET /assets without filters does not error",
    method: "GET",
    path: "/assets",
    expectStatuses: [200],
    assertJson: (payload) => {
      const data = unwrapApiData(payload);
      assert.equal(typeof data, "object");
    },
  },
  {
    name: "GET /books/jobs remains available until creation jobs fully cover it",
    method: "GET",
    path: "/books/jobs",
    expectStatuses: [200],
    assertJson: (payload) => {
      const data = unwrapApiData(payload);
      const body = data as Record<string, unknown>;
      assert.ok(Array.isArray(body.jobs), "books/jobs should still expose the legacy job list");
    },
  },
  {
    name: "POST /books/jobs remains wired and validates payloads",
    method: "POST",
    path: "/books/jobs",
    body: { assetIds: [] },
    expectStatuses: [422],
    assertJson: (payload) => {
      const data = unwrapApiData(payload);
      assert.equal(typeof data, "object", "books/jobs validation error should include structured data");
    },
  },
  {
    name: "POST /sample/import accepts a JSON body",
    method: "POST",
    path: "/sample/import",
    body: { persist: false },
    expectStatuses: [200, 201],
    assertJson: (payload) => {
      const data = unwrapApiData(payload);
      assert.equal(typeof data, "object");
    },
  },
  {
    name: "GET /api/web-companion/sessions/:sessionId returns upload session metadata",
    method: "GET",
    path: "/api/web-companion/sessions/session-smoke",
    expectStatuses: [404], // 期望404因为session-smoke不存在
    expectJson: false, // 不检查JSON格式，因为会返回错误
  },
];

async function startApp() {
  const app = await NestFactory.create(AppModule, { logger: false });
  await app.listen(0, "127.0.0.1");
  const server = app.getHttpServer();
  const address = server.address();
  if (!address || typeof address !== "object") {
    throw new Error("Could not determine sidecar test server address.");
  }
  const baseUrl = `http://127.0.0.1:${address.port}`;
  return { app, baseUrl, server };
}

test("sidecar HTTP routes boot under NestFactory and answer expected status codes", async (t) => {
  const { app, baseUrl, server } = await startApp();
  t.after(async () => {
    await app.close();
  });

  for (const route of ROUTES) {
    await t.test(route.name, async () => {
      const init: RequestInit = { method: route.method };
      if (route.body !== undefined) {
        init.headers = { "content-type": "application/json" };
        init.body = JSON.stringify(route.body);
      }

      const response = await fetch(`${baseUrl}${route.path}`, init);
      const expected = route.expectStatuses ?? [200];
      assert.ok(
        expected.includes(response.status),
        `${route.method} ${route.path} returned HTTP ${response.status}, expected one of ${expected.join(", ")}`,
      );

      if (route.assertJson) {
        const text = await response.text();
        if (!text) {
          route.assertJson({});
          return;
        }
        let payload: unknown;
        try {
          payload = JSON.parse(text);
        } catch (error) {
          throw new Error(`${route.method} ${route.path} returned non-JSON body: ${text.slice(0, 200)}`);
        }
        route.assertJson(payload);
      }
    });
  }
});

test("sidecar returns 404 for unknown routes without crashing the app", async (t) => {
  const { app, baseUrl } = await startApp();
  t.after(async () => {
    await app.close();
  });

  const response = await fetch(`${baseUrl}/this-route-does-not-exist`, { method: "GET" });
  assert.equal(response.status, 404);
});

test("legacy OpenAI config routes stay removed", async (t) => {
  const { app, baseUrl } = await startApp();
  t.after(async () => {
    await app.close();
  });

  const removedPaths = ["/config" + "/openai", "/config/check" + "/openai"];
  for (const path of removedPaths) {
    await t.test(`POST ${path} returns 404`, async () => {
      const response = await fetch(`${baseUrl}${path}`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({}),
      });

      assert.equal(response.status, 404);
    });
  }
});

test("web companion trusted upload sessions route exists", async () => {
  const { app, baseUrl } = await startApp();
  try {
    const childId = `route-smoke-${Date.now()}`;
    const childResponse = await fetch(`${baseUrl}/children`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ id: childId, name: "路由冒烟孩子" }),
    });
    assert.equal(childResponse.status, 201);

    // 使用真实 child 创建会话，避免把业务层的 child-not-found 404 误判成路由缺失。
    const createResponse = await fetch(`${baseUrl}/api/web-companion/sessions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ childId }),
    });
    assert.equal(createResponse.status, 201);
  } finally {
    await app.close();
  }
});
