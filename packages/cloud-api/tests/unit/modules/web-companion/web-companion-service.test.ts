import { describe, it, beforeEach } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import { fileURLToPath } from "node:url";

import { WebCompanionService } from "../../../../src/modules/web-companion/web-companion.service.ts";
import { PrismaService } from "../../../../src/infrastructure/database/prisma.service.ts";

type SessionStatus = "active" | "closed" | "expired";
type UploadItemStatus = "pending" | "uploaded" | "synced" | "failed";

type SessionRow = {
  id: string;
  childId: string;
  status: SessionStatus;
  expiresAt: Date;
  maxItems: number;
  createdAt: Date;
  updatedAt: Date;
};

type UploadItemRow = {
  id: string;
  sessionId: string;
  objectKey: string;
  fileName: string;
  fileSize: bigint;
  mimeType: string;
  status: UploadItemStatus;
  uploadedAt: Date | null;
  syncedAt: Date | null;
  errorMessage: string | null;
  createdAt: Date;
  updatedAt: Date;
};

type ShareTokenRow = {
  id: string;
  token: string;
  childId: string;
  bookId: string | null;
  accessLimit: number | null;
  accessCount: number;
  revokedAt: Date | null;
  expiresAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
};

type ShareAccessLogRow = {
  tokenId: string;
  ipAddress: string;
  userAgent: string | null;
};

type UploadSessionFindUniqueArgs = { where: { id: string } };
type UploadItemCountArgs = { where: { sessionId?: string } };
type UploadItemCreateArgs = {
  data: {
    id?: string;
    sessionId: string;
    objectKey: string;
    fileName: string;
    fileSize: bigint;
    mimeType: string;
    status?: UploadItemStatus;
  };
};
type UploadItemFindUniqueArgs = { where: { id: string } };
type UploadItemUpdateArgs = {
  where: { id: string };
  data: Partial<Pick<UploadItemRow, "status" | "uploadedAt" | "syncedAt" | "errorMessage" | "fileSize" | "mimeType">>;
};
type UploadItemFindManyArgs = { where?: { sessionId?: string } };
type ShareTokenFindUniqueArgs = { where: { token: string } };
type ShareTokenUpdateArgs = { where: { id: string }; data: Partial<Pick<ShareTokenRow, "accessCount" | "revokedAt">> };
type ShareAccessLogCreateArgs = { data: ShareAccessLogRow };

function createService() {
  const sessions = new Map<string, SessionRow>();
  const items = new Map<string, UploadItemRow>();
  const shares = new Map<string, ShareTokenRow>();
  const shareLogs: ShareAccessLogRow[] = [];

  sessions.set("session-1", {
    id: "session-1",
    childId: "child-1",
    status: "active",
    expiresAt: new Date(Date.now() + 60_000),
    maxItems: 10,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  shares.set("token-assets", {
    id: "share-1",
    token: "token-assets",
    childId: "child-1",
    bookId: null,
    accessLimit: 3,
    accessCount: 0,
    revokedAt: null,
    expiresAt: new Date(Date.now() + 60_000),
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  const prisma = {
    uploadSession: {
      findUnique: async ({ where: { id } }: UploadSessionFindUniqueArgs) => sessions.get(id) ?? null,
    },
    uploadItem: {
      count: async ({ where: { sessionId } }: UploadItemCountArgs) =>
        [...items.values()].filter((item) => item.sessionId === sessionId).length,
      create: async ({ data }: UploadItemCreateArgs) => {
        const row = {
          ...data,
          id: data.id ?? `item-${items.size + 1}`,
          status: data.status ?? "pending",
          uploadedAt: null,
          syncedAt: null,
          errorMessage: null,
          createdAt: new Date(),
          updatedAt: new Date(),
        };
        items.set(row.id, row);
        return row;
      },
      findUnique: async ({ where: { id } }: UploadItemFindUniqueArgs) => items.get(id) ?? null,
      update: async ({ where: { id }, data }: UploadItemUpdateArgs) => {
        const existing = items.get(id);
        if (!existing) throw new Error("upload item not found");
        const updated = { ...existing, ...data, updatedAt: new Date() };
        items.set(id, updated);
        return updated;
      },
      findMany: async ({ where }: UploadItemFindManyArgs) => {
        const all = [...items.values()];
        return all.filter((item) => (!where?.sessionId || item.sessionId === where.sessionId));
      },
    },
    shareToken: {
      findUnique: async ({ where: { token } }: ShareTokenFindUniqueArgs) => shares.get(token) ?? null,
      update: async ({ where: { id }, data }: ShareTokenUpdateArgs) => {
        const target = [...shares.values()].find((item) => item.id === id);
        if (!target) throw new Error("share token not found");
        const updated = { ...target, ...data, updatedAt: new Date() };
        shares.set(updated.token, updated);
        return updated;
      },
    },
    shareAccessLog: {
      create: async ({ data }: ShareAccessLogCreateArgs) => {
        shareLogs.push(data);
        return data;
      },
    },
  };

  const service = new WebCompanionService(prisma as PrismaService);
  return { service, items, shares, shareLogs };
}

describe("Web Companion service contract", () => {
  let fixture: ReturnType<typeof createService>;

  beforeEach(() => {
    fixture = createService();
  });

  it("uses current Web Companion service wording", () => {
    const currentFilePath = fileURLToPath(import.meta.url);
    const source = fs.readFileSync(currentFilePath, "utf8");
    const historicalFileSegment = ["migr", "ation"].join("");
    const historicalSuiteName = ["Web Companion", "migration service"].join(" ");

    assert.equal(currentFilePath.includes(historicalFileSegment), false);
    assert.equal(source.includes(historicalSuiteName), false);
  });

  it("returns trusted upload session summary shape used by web", async () => {
    const data = await fixture.service.getSessionSummary("session-1", "valid-token");
    assert.equal(data.sessionId, "session-1");
    assert.equal(data.child.id, "child-1");
    assert.equal(data.status, "active");
    assert.equal(typeof data.maxItems, "number");
    assert.equal(typeof data.usedItems, "number");
  });

  it("creates upload items for trusted upload session", async () => {
    const data = await fixture.service.createUploadItems("session-1", {
      token: "ignored-for-now",
      provider: "supabase",
      files: [
        {
          clientFileId: "client-1",
          filename: "photo-1.jpg",
          contentType: "image/jpeg",
          sizeBytes: 1024,
        },
      ],
    });

    assert.equal(data.items.length, 1);
    assert.equal(data.items[0].clientFileId, "client-1");
    assert.equal(data.items[0].status, "pending");
  });

  it("commits an upload item and marks it uploaded", async () => {
    const created = await fixture.service.createUploadItems("session-1", {
      token: "ignored-for-now",
      provider: "supabase",
      files: [
        {
          clientFileId: "client-2",
          filename: "photo-2.jpg",
          contentType: "image/jpeg",
          sizeBytes: 2048,
        },
      ],
    });

    const target = created.items[0];
    const committed = await fixture.service.commitUploadItem("session-1", target.uploadItemId, {
      token: "ignored-for-now",
      objectKey: target.objectKey,
      sizeBytes: 2048,
      contentType: "image/jpeg",
    });

    assert.equal(committed.status, "uploaded");
  });

  it("validates share token and records access log", async () => {
    const result = await fixture.service.validateShareToken({
      token: "token-assets",
      clientIp: "127.0.0.1",
      userAgent: "test-agent",
    });

    assert.equal(result.isValid, true);
    assert.equal(result.shareToken?.childId, "child-1");
    assert.equal(fixture.shareLogs.length, 1);
  });

  it("keeps invalid share token responses in one helper", () => {
    const source = fs.readFileSync("src/modules/web-companion/web-companion.service.ts", "utf8");

    assert.equal(source.match(/isValid: false/g)?.length, 1);
  });

  it("rejects trusted upload session summary without token", async () => {
    await assert.rejects(
      () => fixture.service.getSessionSummary("session-1"),
      /Trusted upload token required/
    );
  });

  it("rejects create upload items without token", async () => {
    await assert.rejects(
      () =>
        fixture.service.createUploadItems("session-1", {
          token: "",
          provider: "supabase",
          files: [
            {
              clientFileId: "client-3",
              filename: "photo-3.jpg",
              contentType: "image/jpeg",
              sizeBytes: 1024,
            },
          ],
        }),
      /Trusted upload token required/
    );
  });

  it("rejects commit upload item without token", async () => {
    const created = await fixture.service.createUploadItems("session-1", {
      token: "token-ok",
      provider: "supabase",
      files: [
        {
          clientFileId: "client-4",
          filename: "photo-4.jpg",
          contentType: "image/jpeg",
          sizeBytes: 2048,
        },
      ],
    });

    const target = created.items[0];
    await assert.rejects(
      () =>
        fixture.service.commitUploadItem("session-1", target.uploadItemId, {
          token: "",
          objectKey: target.objectKey,
          sizeBytes: 2048,
          contentType: "image/jpeg",
        }),
      /Trusted upload token required/
    );
  });
});
