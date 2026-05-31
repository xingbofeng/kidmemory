import assert from "node:assert/strict";
import { test } from "node:test";

import {
  DatasetServiceDirectUploadAssetGateway,
  PrismaDirectUploadPullbackStore,
} from "../../../../src/modules/web-companion/direct-upload.providers.ts";
import type {
  DirectUploadPullbackRow,
} from "../../../../src/modules/web-companion/direct-upload.service.ts";

type TestPullbackRow = DirectUploadPullbackRow & {
  createdAt: Date;
  updatedAt: Date;
  pulledAt: Date | null;
};

test("DatasetServiceDirectUploadAssetGateway maps DatasetService import report id/path to pullback result", async () => {
  const gateway = new DatasetServiceDirectUploadAssetGateway({
    async importAssets(input) {
      return {
        ok: true,
        imported: [{ id: "asset_from_dataset", path: input.paths[0] }],
        duplicates: [],
        failed: [],
        skipped: [],
      };
    },
  });

  const result = await gateway.importPullback({
    objectKey: "wcs_direct_test/photo.png",
    childId: "child_1",
    sessionId: "wcs_direct_test",
    body: Buffer.from("image-bytes"),
    contentType: "image/png",
  });

  assert.equal(result.assetId, "asset_from_dataset");
  assert.match(result.localPath, /photo\.png$/);
});

test("PrismaDirectUploadPullbackStore persists pullback rows through Prisma", async () => {
  const rows = new Map<string, TestPullbackRow>();
  const prisma = {
    directUploadPullback: {
      async upsert({ where, create, update }) {
        const key = `${where.sessionId_objectKey.sessionId}:${where.sessionId_objectKey.objectKey}`;
        const existing = rows.get(key);
        const row = existing
          ? { ...existing, ...update }
          : {
              ...create,
              assetId: null,
              localPath: null,
              errorCode: null,
              errorMessage: null,
              pulledAt: null,
              createdAt: new Date(),
              updatedAt: new Date(),
            };
        rows.set(key, row);
        return row;
      },
      async findMany({ where }) {
        return [...rows.values()].filter((row) => row.sessionId === where.sessionId);
      },
      async update({ where, data }) {
        const row = [...rows.values()].find((candidate) => candidate.id === where.id);
        if (!row) {
          const error = new Error("not found") as Error & { code?: string };
          error.code = "P2025";
          throw error;
        }
        Object.assign(row, data);
        return row;
      },
      async findUnique({ where }) {
        return [...rows.values()].find((row) => row.id === where.id) || null;
      },
    },
  } satisfies ConstructorParameters<typeof PrismaDirectUploadPullbackStore>[0];
  const store = new PrismaDirectUploadPullbackStore(prisma);

  const pending = await store.upsertPending({
    sessionId: "session_1",
    childId: "child_1",
    objectKey: "session_1/photo.jpg",
  });
  const ready = await store.update(pending.id, {
    status: "ready",
    assetId: "asset_1",
    localPath: "/tmp/photo.jpg",
  });
  const bySession = await store.findBySessionId("session_1");

  assert.equal(ready?.status, "ready");
  assert.equal(ready?.assetId, "asset_1");
  assert.equal(ready?.localPath, "/tmp/photo.jpg");
  assert.equal(bySession.length, 1);
  assert.equal(bySession[0].objectKey, "session_1/photo.jpg");
  assert.equal(await store.update("missing", { status: "failed" }), null);
});
