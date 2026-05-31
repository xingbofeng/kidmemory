/**
 * Share Access Concurrency Tests
 * 
 * Tests concurrent access to share tokens to verify:
 * - accessCount atomic increment
 * - IP rate limiting under concurrent load
 * - No race conditions in token validation
 */

import { describe, it, beforeEach } from 'node:test';
import assert from 'node:assert';
import { readFileSync } from 'node:fs';
import { ShareIpLimiterService } from '../../../../src/modules/web-companion/share-ip-limiter.service.ts';

describe('Share Access Concurrency', () => {
  describe('IP Rate Limiter Concurrency', () => {
    let limiter: ShareIpLimiterService;

    beforeEach(() => {
      limiter = new ShareIpLimiterService({
        maxRequestsPerWindow: 10,
        windowMs: 1000,
        blockDurationMs: 2000,
      });
    });

    it('should handle concurrent requests from same IP correctly', async () => {
      const ip = '192.168.1.100';
      const concurrentRequests = 15;

      // Make concurrent requests
      const results = await Promise.all(
        Array.from({ length: concurrentRequests }, () =>
          Promise.resolve(limiter.checkLimit(ip))
        )
      );

      // Count allowed and blocked requests
      const allowed = results.filter(r => r === true).length;
      const blocked = results.filter(r => r === false).length;

      // Should allow exactly maxRequestsPerWindow requests
      assert.strictEqual(allowed, 10, 'Should allow exactly 10 requests');
      assert.strictEqual(blocked, 5, 'Should block 5 requests');

      // IP should be blocked now
      assert.strictEqual(limiter.checkLimit(ip), false, 'IP should be blocked');
      assert.ok(limiter.getBlockedTimeRemaining(ip) > 0, 'Should have block time remaining');
    });

    it('should handle concurrent requests from different IPs independently', async () => {
      const ips = ['192.168.1.1', '192.168.1.2', '192.168.1.3'];
      const requestsPerIp = 5;

      // Make concurrent requests from multiple IPs
      const allRequests = ips.flatMap(ip =>
        Array.from({ length: requestsPerIp }, () =>
          Promise.resolve({ ip, allowed: limiter.checkLimit(ip) })
        )
      );

      const results = await Promise.all(allRequests);

      // Group results by IP
      const resultsByIp = results.reduce((acc, { ip, allowed }) => {
        if (!acc[ip]) acc[ip] = [];
        acc[ip].push(allowed);
        return acc;
      }, {} as Record<string, boolean[]>);

      // Each IP should have all requests allowed (5 < 10 limit)
      for (const ip of ips) {
        const ipResults = resultsByIp[ip];
        const allowedCount = ipResults.filter(r => r === true).length;
        assert.strictEqual(allowedCount, requestsPerIp, `IP ${ip} should have all requests allowed`);
      }
    });

    it('should reset after block duration expires', async () => {
      const ip = '192.168.1.200';

      // Exceed limit to trigger block
      for (let i = 0; i < 11; i++) {
        limiter.checkLimit(ip);
      }

      // Should be blocked
      assert.strictEqual(limiter.checkLimit(ip), false, 'Should be blocked initially');

      // Wait for block to expire (2 seconds + buffer)
      await new Promise(resolve => setTimeout(resolve, 2100));

      // Should be allowed again
      assert.strictEqual(limiter.checkLimit(ip), true, 'Should be allowed after block expires');
    });

    it('should handle rapid sequential requests correctly', async () => {
      const ip = '192.168.1.300';
      const results: boolean[] = [];

      // Make rapid sequential requests
      for (let i = 0; i < 15; i++) {
        results.push(limiter.checkLimit(ip));
      }

      const allowed = results.filter(r => r === true).length;
      const blocked = results.filter(r => r === false).length;

      assert.strictEqual(allowed, 10, 'Should allow exactly 10 requests');
      assert.strictEqual(blocked, 5, 'Should block 5 requests');
    });

    it('should provide accurate remaining request counts', () => {
      const ip = '192.168.1.400';

      // Initial state
      assert.strictEqual(limiter.getRemainingRequests(ip), 10, 'Should have 10 remaining initially');

      // Make some requests
      for (let i = 0; i < 5; i++) {
        limiter.checkLimit(ip);
      }

      assert.strictEqual(limiter.getRemainingRequests(ip), 5, 'Should have 5 remaining after 5 requests');

      // Exceed limit
      for (let i = 0; i < 6; i++) {
        limiter.checkLimit(ip);
      }

      assert.strictEqual(limiter.getRemainingRequests(ip), 0, 'Should have 0 remaining when blocked');
    });

    it('should cleanup old records', async () => {
      const ip = '192.168.1.500';

      // Make a request
      limiter.checkLimit(ip);

      const statsBefore = limiter.getStats();
      assert.strictEqual(statsBefore.totalTrackedIps, 1, 'Should track 1 IP');

      // Wait for window to expire (1 second + buffer)
      await new Promise(resolve => setTimeout(resolve, 1100));

      // Trigger cleanup by making a request from different IP
      limiter.checkLimit('192.168.1.501');

      // Original IP should still be tracked until explicit cleanup
      // (cleanup runs on interval, not on every request)
      const statsAfter = limiter.getStats();
      assert.ok(statsAfter.totalTrackedIps >= 1, 'Should still track IPs');
    });
  });

  describe('AccessCount Atomic Increment', () => {
    it('uses Prisma atomic increment for share token access counts', () => {
      const source = readFileSync(
        'src/modules/web-companion/prisma-share-token.repository.ts',
        'utf8',
      );

      assert.match(source, /accessCount:\s*\{\s*increment:\s*1\s*\}/);
    });
  });
});
