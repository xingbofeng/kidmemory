import assert from "node:assert/strict";
import fs from "node:fs/promises";
import { test } from "node:test";

import {
  DatasetServiceDirectUploadAssetGateway,
  PrismaDirectUploadSessionStore,
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

test("DatasetServiceDirectUploadAssetGateway removes temporary pullback files after import", async () => {
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

  await assert.rejects(fs.access(result.localPath));
});

test("PrismaDirectUploadSessionStore persists bucket and only accepts direct upload session ids", async () => {
  type UploadSessionRow = {
    id: string;
    childId: string;
    tokenHash: string;
    status: string;
    expiresAt: Date;
    maxItems: number;
    directUploadBucket: string | null;
  };
  const rows = new Map<string, UploadSessionRow>();
  const prisma = {
    uploadSession: {
      async create({ data }) {
        rows.set(data.id, {
          ...data,
          directUploadBucket: data.directUploadBucket ?? null,
        });
        return rows.get(data.id)!;
      },
      async findUnique({ where }) {
        return rows.get(where.id) ?? null;
      },
      async deleteMany({ where }) {
        let count = 0;
        for (const [id, row] of [...rows.entries()]) {
          const idMatches = typeof where.id === "string"
            ? id === where.id
            : !where.id || (typeof where.id === "object" && id.startsWith(where.id.startsWith));
          const expiresMatches = !where.expiresAt || row.expiresAt < where.expiresAt.lt;
          const statusMatches = !where.status || row.status === where.status;
          if (idMatches && expiresMatches && statusMatches) {
            rows.delete(id);
            count += 1;
          }
        }
        return { count };
      },
    },
    directUploadPullback: {
      async upsert() { throw new Error("unused"); },
      async findMany() { throw new Error("unused"); },
      async update() { throw new Error("unused"); },
      async findUnique() { throw new Error("unused"); },
    },
  } satisfies ConstructorParameters<typeof PrismaDirectUploadSessionStore>[0];
  const store = new PrismaDirectUploadSessionStore(prisma, 200);

  await assert.rejects(
    () => store.insert({
      sessionId: "session_legacy",
      childId: "child_1",
      bucket: "direct-bucket",
      tokenHash: "hash",
      expiresAt: new Date(Date.now() + 60_000),
    }),
    /Direct upload session id must start with wcs_direct_/,
  );

  await store.insert({
    sessionId: "wcs_direct_test",
    childId: "child_1",
    bucket: "direct-bucket",
    tokenHash: "hash",
    expiresAt: new Date(Date.now() + 60_000),
  });
  const stored = await store.findBySessionId("wcs_direct_test");

  assert.equal(stored?.bucket, "direct-bucket");
  assert.equal(await store.findBySessionId("session_legacy"), null);
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
