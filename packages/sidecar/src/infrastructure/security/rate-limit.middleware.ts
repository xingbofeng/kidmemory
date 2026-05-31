/**
 * 多维度速率限制中间件（纯内存实现，零依赖）
 *
 * 防护层级：
 * 1. IP 级别 - 防止单点爆破
 * 2. 全局级别 - 防止分布式攻击
 * 3. 路径级别 - 针对敏感端点的额外限制
 */

import { Logger, type NestMiddleware } from '@nestjs/common';
import type { Request, Response, NextFunction } from 'express';
import { ApiCode } from '@kidmemory/protocol';
import { sendErrorResponse } from '../http/response-format.util.js';

interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
}

interface RequestRecord {
  timestamps: number[];
  blockedUntil?: number;
}

export class RateLimitMiddleware implements NestMiddleware {
  private readonly logger = new Logger(RateLimitMiddleware.name);

  private cleanupTimer: NodeJS.Timeout | null = null;

  private readonly ipRecords = new Map<string, RequestRecord>();

  private globalTimestamps: number[] = [];

  private readonly pathRecords = new Map<string, Map<string, RequestRecord>>();

  private readonly configs = {
    ip: { windowMs: 60000, maxRequests: 100 },

    global: { windowMs: 60000, maxRequests: 1000 },

    createSession: { windowMs: 60000, maxRequests: 20 },
  };

  private readonly autoBlockConfig = {
    failureThreshold: 50,
    failureWindowMs: 60000,
    blockDurationMs: 3600000,
  };

  private readonly failureRecords = new Map<string, number[]>();

  private lastCleanupTime = Date.now();

  constructor() {
    this.cleanupTimer = setInterval(() => {
      this.cleanup(Date.now());
    }, 60_000);
    if (this.cleanupTimer.unref) {
      this.cleanupTimer.unref();
    }
  }

  onModuleDestroy(): void {
    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
      this.cleanupTimer = null;
    }
  }

  use(req: Request, res: Response, next: NextFunction) {
    const ip = this.getClientIp(req);
    const path = req.path;
    const now = Date.now();

    try {
      if (this.isBlocked(ip, now)) {
        this.sendRateLimitResponse(res, req, 3600);
        return;
      }

      if (!this.checkRateLimit(this.globalTimestamps, this.configs.global, now)) {
        this.recordFailure(ip, now);
        this.sendRateLimitResponse(res, req, 60);
        return;
      }

      const ipRecord = this.getOrCreateRecord(this.ipRecords, ip);
      if (!this.checkRateLimit(ipRecord.timestamps, this.configs.ip, now)) {
        this.recordFailure(ip, now);
        this.sendRateLimitResponse(res, req, 60);
        return;
      }

      if (this.isSensitivePath(path)) {
        const pathMap = this.getOrCreatePathMap(path);
        const pathRecord = this.getOrCreateRecord(pathMap, ip);
        const config = this.getPathConfig(path);

        if (!this.checkRateLimit(pathRecord.timestamps, config, now)) {
          this.recordFailure(ip, now);
          this.sendRateLimitResponse(res, req, 60);
          return;
        }

        pathRecord.timestamps.push(now);
      }

      this.globalTimestamps.push(now);
      ipRecord.timestamps.push(now);

      this.checkAutoBlock(ip, now);

      next();
    } catch (error) {
      this.logger.error(
        'Rate limit middleware error',
        error instanceof Error ? error.stack : String(error),
      );
      next();
    }
  }

  private getClientIp(req: Request): string {
    const forwarded = req.headers['x-forwarded-for'];
    if (forwarded) {
      const ips = (typeof forwarded === 'string' ? forwarded : forwarded[0]).split(',');
      return ips[0].trim();
    }

    const realIp = req.headers['x-real-ip'];
    if (realIp) {
      return typeof realIp === 'string' ? realIp : realIp[0];
    }

    return req.ip || req.socket.remoteAddress || 'unknown';
  }

  private isBlocked(ip: string, now: number): boolean {
    const record = this.ipRecords.get(ip);
    if (!record || !record.blockedUntil) {
      return false;
    }

    if (now < record.blockedUntil) {
      return true;
    }

    delete record.blockedUntil;
    return false;
  }

  private checkRateLimit(
    timestamps: number[],
    config: RateLimitConfig,
    now: number
  ): boolean {
    const windowStart = now - config.windowMs;
    const recentRequests = timestamps.filter(t => t > windowStart);

    timestamps.length = 0;
    timestamps.push(...recentRequests);

    return recentRequests.length < config.maxRequests;
  }

  private getOrCreateRecord(
    map: Map<string, RequestRecord>,
    key: string
  ): RequestRecord {
    let record = map.get(key);
    if (!record) {
      record = { timestamps: [] };
      map.set(key, record);
    }
    // 防止单个 IP 的时间戳数组无限增长
    if (record.timestamps.length >= 10000) {
      const windowStart = Date.now() - Math.max(
        this.configs.ip.windowMs,
        this.configs.global.windowMs
      );
      record.timestamps = record.timestamps.filter(t => t > windowStart);
    }
    return record;
  }

  private getOrCreatePathMap(path: string): Map<string, RequestRecord> {
    let pathMap = this.pathRecords.get(path);
    if (!pathMap) {
      pathMap = new Map();
      this.pathRecords.set(path, pathMap);
    }
    return pathMap;
  }

  private isSensitivePath(path: string): boolean {
    return path.includes('/sessions') && !path.includes('/sessions/');
  }

  private getPathConfig(path: string): RateLimitConfig {
    if (path.includes('/sessions') && !path.includes('/sessions/')) {
      return this.configs.createSession;
    }
    return this.configs.ip;
  }

  private recordFailure(ip: string, now: number) {
    let failures = this.failureRecords.get(ip);
    if (!failures) {
      failures = [];
      this.failureRecords.set(ip, failures);
    }

    const windowStart = now - this.autoBlockConfig.failureWindowMs;
    const recentFailures = failures.filter(t => t > windowStart);
    recentFailures.push(now);

    this.failureRecords.set(ip, recentFailures);
  }

  private checkAutoBlock(ip: string, now: number) {
    const failures = this.failureRecords.get(ip);
    if (!failures) {
      return;
    }

    if (failures.length >= this.autoBlockConfig.failureThreshold) {
      const record = this.getOrCreateRecord(this.ipRecords, ip);
      record.blockedUntil = now + this.autoBlockConfig.blockDurationMs;

      this.logger.warn(
        `Auto-blocked IP due to excessive failures: ip=${ip} failureCount=${failures.length} blockedUntil=${new Date(record.blockedUntil).toISOString()}`,
      );

      this.failureRecords.delete(ip);
    }
  }

  private sendRateLimitResponse(
    res: Response,
    req: Request,
    retryAfterSeconds: number
  ) {
    sendErrorResponse(res, req, {
      statusCode: 429,
      apiCode: ApiCode.RATE_LIMIT_EXCEEDED,
      message: 'Too many requests, please try again later',
      data: { retryAfter: retryAfterSeconds },
    });
  }

  private cleanup(now: number) {
    if (now - this.lastCleanupTime < 300000) {
      return;
    }

    this.lastCleanupTime = now;

    for (const [ip, record] of this.ipRecords.entries()) {
      if (!record.blockedUntil && record.timestamps.length === 0) {
        this.ipRecords.delete(ip);
      }
    }

    for (const [path, pathMap] of this.pathRecords.entries()) {
      for (const [ip, record] of pathMap.entries()) {
        if (record.timestamps.length === 0) {
          pathMap.delete(ip);
        }
      }

      if (pathMap.size === 0) {
        this.pathRecords.delete(path);
      }
    }

    for (const [ip, failures] of this.failureRecords.entries()) {
      if (failures.length === 0) {
        this.failureRecords.delete(ip);
      }
    }

    const windowStart = now - this.configs.global.windowMs;
    this.globalTimestamps = this.globalTimestamps.filter(t => t > windowStart);
  }

  /**
   * 获取当前统计信息（用于监控）
   */
  getStats() {
    return {
      ipRecords: this.ipRecords.size,
      pathRecords: this.pathRecords.size,
      failureRecords: this.failureRecords.size,
      globalTimestamps: this.globalTimestamps.length,
      blockedIps: Array.from(this.ipRecords.entries())
        .filter(([_, record]) => record.blockedUntil && record.blockedUntil > Date.now())
        .map(([ip, record]) => ({
          ip,
          blockedUntil: new Date(record.blockedUntil!).toISOString(),
        })),
    };
  }
}
