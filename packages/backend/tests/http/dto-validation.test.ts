import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";

import { AppModule } from "../../src/app.module.ts";

// Routes that pipe their request body through zod-backed DTO schemas. Sending
// payloads that violate the schema must return 400 with a structured
// description instead of cascading down into the domain providers.

type InvalidPayloadCase = {
  name: string;
  path: string;
  body: unknown;
  // Path inside the response body's `issues[]` we expect to surface.
  expectedIssuePath?: string;
  // Or, when the violation is at object level (e.g. unknown keys), match the
  // issue.message against this pattern instead.
  expectedIssueMessage?: RegExp;
};

const INVALID_PAYLOADS: InvalidPayloadCase[] = [
  {
    name: "POST /sample/import rejects non-boolean persist",
    path: "/sample/import",
    body: { persist: "yes" },
    expectedIssuePath: "persist",
  },
  {
    name: "POST /assets/import rejects missing childId",
    path: "/assets/import",
    body: { paths: ["/tmp/example.png"] },
    expectedIssuePath: "childId",
  },
  {
    name: "POST /assets/import rejects empty paths",
    path: "/assets/import",
    body: { childId: "child-1", paths: [] },
    expectedIssuePath: "paths",
  },
  {
    name: "POST /search/query rejects missing childId",
    path: "/search/query",
    body: { query: "rainbow" },
    expectedIssuePath: "childId",
  },
  {
    name: "POST /search/candidate-pool/items rejects empty assetIds",
    path: "/search/candidate-pool/items",
    body: { childId: "child-1", assetIds: [] },
    expectedIssuePath: "assetIds",
  },
  {
    name: "POST /config/postgres rejects unknown fields",
    path: "/config/postgres",
    body: { host: "localhost", evil: "drop table" },
    expectedIssueMessage: /evil/,
  },
  {
    name: "POST /books/jobs rejects non-array assetIds",
    path: "/books/jobs",
    body: { assetIds: "asset-1" },
    expectedIssuePath: "assetIds",
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
  return { app, baseUrl: `http://127.0.0.1:${address.port}` };
}

test("write routes return 400 with issue paths when the DTO schema rejects the body", async (t) => {
  const { app, baseUrl } = await startApp();
  t.after(async () => {
    await app.close();
  });

  for (const caseInfo of INVALID_PAYLOADS) {
    await t.test(caseInfo.name, async () => {
      const response = await fetch(`${baseUrl}${caseInfo.path}`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify(caseInfo.body),
      });

      assert.equal(
        response.status,
        400,
        `${caseInfo.path} should reject invalid bodies with HTTP 400`,
      );
      const text = await response.text();
      assert.ok(text, `${caseInfo.path} should respond with a JSON body`);
      const payload = JSON.parse(text);
      assert.match(String(payload.message), /Invalid .* payload/);
      assert.ok(Array.isArray(payload.issues), "issues should be an array");
      if (caseInfo.expectedIssuePath) {
        const matched = payload.issues.some((issue: { path: string }) =>
          issue.path === caseInfo.expectedIssuePath,
        );
        assert.ok(
          matched,
          `expected an issue at path "${caseInfo.expectedIssuePath}", got ${JSON.stringify(payload.issues)}`,
        );
      }
      if (caseInfo.expectedIssueMessage) {
        const matched = payload.issues.some((issue: { message: string }) =>
          caseInfo.expectedIssueMessage!.test(issue.message),
        );
        assert.ok(
          matched,
          `expected an issue message matching ${caseInfo.expectedIssueMessage}, got ${JSON.stringify(payload.issues)}`,
        );
      }
    });
  }
});
