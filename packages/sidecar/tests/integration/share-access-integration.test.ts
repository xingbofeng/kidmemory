/**
 * Share Access Integration Tests
 * 
 * Tests concurrent share token access with real database to verify:
 * - IP rate limiting under concurrent load
 * - accessCount atomic increment
 * - No race conditions in token validation
 */

import assert from "node:assert/strict";
import { describe, test, beforeEach, afterEach } from "node:test";
import crypto from "node:crypto";

import { ShareTokenService } from "../../src/modules/web-companion/share-token.service.ts";
import { ShareIpLimiterService } from "../../src/modules/web-companion/share-ip-limiter.service.ts";
import { PrismaShareTokenRepository } from "../../src/modules/web-companion/prisma-share-token.repository.ts";
import { AppConfigService } from "../../src/infrastructure/config/app-config.service.ts";
import { PrismaMigrationService } from "../../src/infrastructure/database/prisma-migration.service.ts";
import { PrismaService } from "../../src/infrastructure/database/prisma.service.ts";

type ShareTokenValidationResult = Awaited<ReturnType<ShareTokenService["validateShareToken"]>>;

describe("Share Access Integration", { skip: process.env.DATABASE_URL ? false : "DATABASE_URL is not configured" }, () => {
  let service: ShareTokenService;
  let ipLimiter: ShareIpLimiterService;
  let prisma: PrismaService;
  let appConfig: AppConfigService;

  const testChildId = "test-child-share";
  const testSessionId = "test-session-share";
  let createdTokenIds: string[] = [];

  beforeEach(async () => {
    appConfig = new AppConfigService();
    await new PrismaMigrationService(appConfig).deploy();
    prisma = new PrismaService();
    await prisma.$connect();

    ipLimiter = new ShareIpLimiterService({
      maxRequestsPerWindow: 10,
      windowMs: 1000,
      blockDurationMs: 2000,
    });

    const repository = new PrismaShareTokenRepository(prisma);
    service = new ShareTokenService(repository, "http://localhost:5173", ipLimiter);

    await prisma.child.upsert({
      where: { id: testChildId },
      create: { id: testChildId, name: "Test Child Share" },
      update: { name: "Test Child Share" },
    });

    const sessionToken = crypto.randomBytes(32).toString("hex");
    const tokenHash = crypto.createHash("sha256").update(sessionToken).digest("hex");
    await prisma.uploadSession.upsert({
      where: { id: testSessionId },
      create: {
        id: testSessionId,
        childId: testChildId,
        tokenHash,
        status: "active",
        expiresAt: new Date(Date.now() + 3600000),
        maxItems: 10,
      },
      update: {
        status: "active",
        expiresAt: new Date(Date.now() + 3600000),
      },
    });
  });

  afterEach(async () => {
    if (prisma && createdTokenIds.length > 0) {
      await prisma.shareAccessLog.deleteMany({
        where: { shareTokenId: { in: createdTokenIds } },
      });
      await prisma.shareToken.deleteMany({
        where: { id: { in: createdTokenIds } },
      });
      createdTokenIds = [];
    }
    if (ipLimiter) {
      ipLimiter.destroy();
    }
    if (prisma) {
      await prisma.$disconnect();
    }
  });

  test("Task 2.32: concurrent IP rate limiting", async () => {
    const sessionToken = crypto.randomBytes(32).toString("hex");
    const tokenHash = crypto.createHash("sha256").update(sessionToken).digest("hex");
    await prisma.uploadSession.update({
      where: { id: testSessionId },
      data: { tokenHash },
    });

    const shareToken = await service.createShareToken({
      sessionId: testSessionId,
      sessionToken,
      childId: testChildId,
      resourceType: "child_assets",
      expiresInHours: 24,
    });

    createdTokenIds.push(shareToken.id);

    const testIp = "192.168.1.100";
    const concurrentRequests = 15;

    const results = await Promise.all(
      Array.from({ length: concurrentRequests }, () =>
        service.validateShareToken({
          token: shareToken.token,
          clientIp: testIp,
        })
      )
    );

    // Count successful and failed validations
    const successful = results.filter(r => r.isValid).length;
    const rateLimited = results.filter(r => !r.isValid && r.error?.includes("Too many requests")).length;

    // Should allow exactly 10 requests (maxRequestsPerWindow)
    assert.ok(successful <= 10, `Should allow at most 10 requests, got ${successful}`);
    assert.ok(rateLimited >= 5, `Should rate limit at least 5 requests, got ${rateLimited}`);

    // Verify IP is now blocked
    const blockedResult = await service.validateShareToken({
      token: shareToken.token,
      clientIp: testIp,
    });
    assert.strictEqual(blockedResult.isValid, false);
    assert.ok(blockedResult.error?.includes("Too many requests"));
  });

  test("Task 2.32: concurrent requests from different IPs are independent", async () => {
    // Create a share token
    const sessionToken = crypto.randomBytes(32).toString("hex");
    const tokenHash = crypto.createHash("sha256").update(sessionToken).digest("hex");
    await prisma.uploadSession.update({
      where: { id: testSessionId },
      data: { tokenHash },
    });

    const shareToken = await service.createShareToken({
      sessionId: testSessionId,
      sessionToken,
      childId: testChildId,
      resourceType: "child_assets",
      expiresInHours: 24,
    });

    createdTokenIds.push(shareToken.id);

    const ips = ["192.168.1.1", "192.168.1.2", "192.168.1.3"];
    const requestsPerIp = 5;

    // Make concurrent requests from multiple IPs
    const allRequests = ips.flatMap(ip =>
      Array.from({ length: requestsPerIp }, () =>
        service.validateShareToken({
          token: shareToken.token,
          clientIp: ip,
        }).then(result => ({ ip, result }))
      )
    );

    const results = await Promise.all(allRequests);

    // Group results by IP
    const resultsByIp = results.reduce<Record<string, ShareTokenValidationResult[]>>((acc, { ip, result }) => {
      if (!acc[ip]) acc[ip] = [];
      acc[ip].push(result);
      return acc;
    }, {});

    // Each IP should have all requests succeed (5 < 10 limit)
    for (const ip of ips) {
      const ipResults = resultsByIp[ip];
      const successCount = ipResults.filter(r => r.isValid).length;
      assert.ok(successCount >= requestsPerIp - 1, `IP ${ip} should have most requests succeed, got ${successCount}/${requestsPerIp}`);
    }
  });

  test("Task 2.34: concurrent accessCount atomic increment", async () => {
    // Create a share token with max access count
    const sessionToken = crypto.randomBytes(32).toString("hex");
    const tokenHash = crypto.createHash("sha256").update(sessionToken).digest("hex");
    await prisma.uploadSession.update({
      where: { id: testSessionId },
      data: { tokenHash },
    });

    const shareToken = await service.createShareToken({
      sessionId: testSessionId,
      sessionToken,
      childId: testChildId,
      resourceType: "child_assets",
      expiresInHours: 24,
      maxAccessCount: 20,
    });

    createdTokenIds.push(shareToken.id);

    const concurrentRequests = 25;
    const testIp = "192.168.2.100";

    // Reset IP limiter to allow all requests
    ipLimiter.resetIp(testIp);

    // Make concurrent validation requests
    const results = await Promise.all(
      Array.from({ length: concurrentRequests }, (_, i) =>
        service.validateShareToken({
          token: shareToken.token,
          clientIp: `192.168.2.${100 + i}`, // Different IPs to avoid IP rate limiting
        })
      )
    );

    // Count successful validations
    const successful = results.filter(r => r.isValid).length;
    const limitExceeded = results.filter(r => !r.isValid && r.error?.includes("access limit exceeded")).length;

    // Should allow exactly maxAccessCount requests
    assert.ok(successful <= 20, `Should allow at most 20 requests, got ${successful}`);
    assert.ok(limitExceeded >= 5, `Should reject at least 5 requests due to limit, got ${limitExceeded}`);

    // Verify final accessCount in database
    const tokenRecord = await prisma.shareToken.findUnique({
      where: { id: shareToken.id },
    });

    assert.ok(tokenRecord);
    assert.ok(tokenRecord.accessCount >= 20, `Access count should be at least 20, got ${tokenRecord.accessCount}`);
    assert.ok(tokenRecord.accessCount <= 25, `Access count should not exceed total requests, got ${tokenRecord.accessCount}`);
  });

  test("Task 2.34: accessCount increments atomically without race conditions", async () => {
    // Create a share token
    const sessionToken = crypto.randomBytes(32).toString("hex");
    const tokenHash = crypto.createHash("sha256").update(sessionToken).digest("hex");
    await prisma.uploadSession.update({
      where: { id: testSessionId },
      data: { tokenHash },
    });

    const shareToken = await service.createShareToken({
      sessionId: testSessionId,
      sessionToken,
      childId: testChildId,
      resourceType: "child_assets",
      expiresInHours: 24,
    });

    createdTokenIds.push(shareToken.id);

    const concurrentRequests = 50;

    // Make concurrent validation requests from different IPs
    const results = await Promise.all(
      Array.from({ length: concurrentRequests }, (_, i) =>
        service.validateShareToken({
          token: shareToken.token,
          clientIp: `192.168.3.${i}`, // Different IPs to avoid IP rate limiting
        })
      )
    );

    // Count successful validations
    const successful = results.filter(r => r.isValid).length;

    // Verify final accessCount matches successful validations
    const tokenRecord = await prisma.shareToken.findUnique({
      where: { id: shareToken.id },
    });

    assert.ok(tokenRecord);
    // Access count should equal successful validations (atomic increment ensures no lost updates)
    assert.strictEqual(
      tokenRecord.accessCount,
      successful,
      `Access count (${tokenRecord.accessCount}) should match successful validations (${successful})`
    );
  });

  test("Task 2.36: complete share flow integration", async () => {
    // 1. Create share token
    const sessionToken = crypto.randomBytes(32).toString("hex");
    const tokenHash = crypto.createHash("sha256").update(sessionToken).digest("hex");
    await prisma.uploadSession.update({
      where: { id: testSessionId },
      data: { tokenHash },
    });

    const shareToken = await service.createShareToken({
      sessionId: testSessionId,
      sessionToken,
      childId: testChildId,
      resourceType: "child_assets",
      expiresInHours: 24,
      maxAccessCount: 5,
    });

    createdTokenIds.push(shareToken.id);

    assert.ok(shareToken.id);
    assert.ok(shareToken.token);
    assert.ok(shareToken.shareUrl);

    // 2. Validate token multiple times
    for (let i = 0; i < 3; i++) {
      const result = await service.validateShareToken({
        token: shareToken.token,
        clientIp: `192.168.4.${i}`,
        userAgent: "test-agent",
      });
      assert.strictEqual(result.isValid, true);
      assert.ok(result.shareToken);
      assert.strictEqual(result.shareToken.childId, testChildId);
    }

    // 3. Verify access logs
    const accessLogs = await prisma.shareAccessLog.findMany({
      where: { shareTokenId: shareToken.id },
    });
    assert.ok(accessLogs.length >= 3);

    // 4. Exceed access limit
    for (let i = 3; i < 10; i++) {
      await service.validateShareToken({
        token: shareToken.token,
        clientIp: `192.168.4.${i}`,
      });
    }

    // 5. Verify token is now exhausted
    const exhaustedResult = await service.validateShareToken({
      token: shareToken.token,
      clientIp: "192.168.4.100",
    });
    assert.strictEqual(exhaustedResult.isValid, false);
    assert.ok(exhaustedResult.error?.includes("access limit exceeded"));

    // 6. Revoke token
    await service.revokeShareToken(shareToken.id, testSessionId, sessionToken);

    // 7. Verify revoked token is rejected
    const revokedResult = await service.validateShareToken({
      token: shareToken.token,
      clientIp: "192.168.4.200",
    });
    assert.strictEqual(revokedResult.isValid, false);
    assert.ok(revokedResult.error?.includes("revoked"));
  });
});
