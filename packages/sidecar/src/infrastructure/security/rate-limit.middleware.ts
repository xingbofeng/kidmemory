/**
 * 多维度速率限制中间件（纯内存实现，零依赖）
 *
 * 防护层级：
 * 1. IP 级别 - 防止单点爆破
 * 2. 全局级别 - 防止分布式攻击
 * 3. 路径级别 - 针对敏感端点的额外限制
 */

import type { NestMiddleware } from '@nestjs/common';
import type { Request, Response, NextFunction } from 'express';
import { ApiCode } from '@kidmemory/protocol';
import { sendErrorResponse } from '../http/response-format.util.js';

interface RateLimitConfig {
  windowMs: number;  // 时间窗口（毫秒）
  maxRequests: number;  // 最大请求数
}

interface RequestRecord {
  timestamps: number[];  // 请求时间戳数组
  blockedUntil?: number;  // 封禁截止时间
}

export class RateLimitMiddleware implements NestMiddleware {
  // 定时清理器
  private cleanupTimer: NodeJS.Timeout | null = null;

  // IP 级别的请求记录
  private readonly ipRecords = new Map<string, RequestRecord>();

  // 全局请求记录
  private globalTimestamps: number[] = [];

  // 路径级别的请求记录
  private readonly pathRecords = new Map<string, Map<string, RequestRecord>>();

  // 配置
  private readonly configs = {
    // IP 级别：每分钟最多 100 次
    ip: { windowMs: 60000, maxRequests: 100 },

    // 全局级别：每分钟最多 1000 次
    global: { windowMs: 60000, maxRequests: 1000 },

    // 敏感路径：创建会话每分钟最多 20 次
    createSession: { windowMs: 60000, maxRequests: 20 },
  };

  // 自动封禁配置
  private readonly autoBlockConfig = {
    // 1 分钟内超过 50 次失败 → 封禁 1 小时
    failureThreshold: 50,
    failureWindowMs: 60000,
    blockDurationMs: 3600000,
  };

  // 失败记录（用于自动封禁）
  private readonly failureRecords = new Map<string, number[]>();

  // 上次清理时间
  private lastCleanupTime = Date.now();

  constructor() {
    // 每 60 秒定时清理，防止内存泄漏
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
      // 1. 检查 IP 是否被封禁
      if (this.isBlocked(ip, now)) {
        this.sendRateLimitResponse(res, req, 'IP_BLOCKED', 3600);
        return;
      }

      // 2. 检查全局速率限制
      if (!this.checkRateLimit(this.globalTimestamps, this.configs.global, now)) {
        this.recordFailure(ip, now);
        this.sendRateLimitResponse(res, req, 'GLOBAL_RATE_LIMIT_EXCEEDED', 60);
        return;
      }

      // 3. 检查 IP 级别速率限制
      const ipRecord = this.getOrCreateRecord(this.ipRecords, ip);
      if (!this.checkRateLimit(ipRecord.timestamps, this.configs.ip, now)) {
        this.recordFailure(ip, now);
        this.sendRateLimitResponse(res, req, 'IP_RATE_LIMIT_EXCEEDED', 60);
        return;
      }

      // 4. 检查路径级别速率限制（针对敏感端点）
      if (this.isSensitivePath(path)) {
        const pathMap = this.getOrCreatePathMap(path);
        const pathRecord = this.getOrCreateRecord(pathMap, ip);
        const config = this.getPathConfig(path);

        if (!this.checkRateLimit(pathRecord.timestamps, config, now)) {
          this.recordFailure(ip, now);
          this.sendRateLimitResponse(res, req, 'PATH_RATE_LIMIT_EXCEEDED', 60);
          return;
        }

        // 记录路径级别的请求
        pathRecord.timestamps.push(now);
      }

      // 5. 记录请求
      this.globalTimestamps.push(now);
      ipRecord.timestamps.push(now);

      // 6. 检查是否需要自动封禁
      this.checkAutoBlock(ip, now);

      next();
    } catch (error) {
      console.error('Rate limit middleware error:', error);
      // 出错时放行，避免影响正常请求
      next();
    }
  }

  /**
   * 获取客户端 IP
   */
  private getClientIp(req: Request): string {
    // 优先从代理头获取真实 IP
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

  /**
   * 检查 IP 是否被封禁
   */
  private isBlocked(ip: string, now: number): boolean {
    const record = this.ipRecords.get(ip);
    if (!record || !record.blockedUntil) {
      return false;
    }

    if (now < record.blockedUntil) {
      return true;
    }

    // 封禁已过期，清除标记
    delete record.blockedUntil;
    return false;
  }

  /**
   * 检查速率限制
   */
  private checkRateLimit(
    timestamps: number[],
    config: RateLimitConfig,
    now: number
  ): boolean {
    // 过滤出时间窗口内的请求
    const windowStart = now - config.windowMs;
    const recentRequests = timestamps.filter(t => t > windowStart);

    // 更新时间戳数组（移除过期的）
    timestamps.length = 0;
    timestamps.push(...recentRequests);

    return recentRequests.length < config.maxRequests;
  }

  /**
   * 获取或创建请求记录
   */
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

  /**
   * 获取或创建路径级别的记录 Map
   */
  private getOrCreatePathMap(path: string): Map<string, RequestRecord> {
    let pathMap = this.pathRecords.get(path);
    if (!pathMap) {
      pathMap = new Map();
      this.pathRecords.set(path, pathMap);
    }
    return pathMap;
  }

  /**
   * 判断是否为敏感路径
   */
  private isSensitivePath(path: string): boolean {
    return path.includes('/sessions') && !path.includes('/sessions/');
  }

  /**
   * 获取路径对应的配置
   */
  private getPathConfig(path: string): RateLimitConfig {
    if (path.includes('/sessions') && !path.includes('/sessions/')) {
      return this.configs.createSession;
    }
    return this.configs.ip;
  }

  /**
   * 记录失败请求
   */
  private recordFailure(ip: string, now: number) {
    let failures = this.failureRecords.get(ip);
    if (!failures) {
      failures = [];
      this.failureRecords.set(ip, failures);
    }

    // 只保留时间窗口内的失败记录
    const windowStart = now - this.autoBlockConfig.failureWindowMs;
    const recentFailures = failures.filter(t => t > windowStart);
    recentFailures.push(now);

    this.failureRecords.set(ip, recentFailures);
  }

  /**
   * 检查是否需要自动封禁
   */
  private checkAutoBlock(ip: string, now: number) {
    const failures = this.failureRecords.get(ip);
    if (!failures) {
      return;
    }

    // 如果失败次数超过阈值，自动封禁
    if (failures.length >= this.autoBlockConfig.failureThreshold) {
      const record = this.getOrCreateRecord(this.ipRecords, ip);
      record.blockedUntil = now + this.autoBlockConfig.blockDurationMs;

      console.warn('Auto-blocked IP due to excessive failures:', {
        ip,
        failureCount: failures.length,
        blockedUntil: new Date(record.blockedUntil).toISOString(),
      });

      // 清空失败记录
      this.failureRecords.delete(ip);
    }
  }

  /**
   * 发送速率限制响应
   */
  private sendRateLimitResponse(
    res: Response,
    req: Request,
    code: string,
    retryAfterSeconds: number
  ) {
    sendErrorResponse(res, req, {
      statusCode: 429,
      apiCode: ApiCode.RATE_LIMIT_EXCEEDED,
      message: 'Too many requests, please try again later',
      data: { retryAfter: retryAfterSeconds },
    });
  }

  /**
   * 定期清理过期数据
   */
  private cleanup(now: number) {
    // 每 5 分钟清理一次
    if (now - this.lastCleanupTime < 300000) {
      return;
    }

    this.lastCleanupTime = now;

    // 清理 IP 记录
    for (const [ip, record] of this.ipRecords.entries()) {
      // 如果没有封禁且最近 10 分钟没有请求，删除记录
      if (!record.blockedUntil && record.timestamps.length === 0) {
        this.ipRecords.delete(ip);
      }
    }

    // 清理路径记录
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

    // 清理失败记录
    for (const [ip, failures] of this.failureRecords.entries()) {
      if (failures.length === 0) {
        this.failureRecords.delete(ip);
      }
    }

    // 清理全局时间戳（只保留最近 1 分钟的）
    const windowStart = now - this.configs.global.windowMs;
    this.globalTimestamps = this.globalTimestamps.filter(t => t > windowStart);

    console.log('Rate limit cleanup completed:', {
      ipRecords: this.ipRecords.size,
      pathRecords: this.pathRecords.size,
      failureRecords: this.failureRecords.size,
      globalTimestamps: this.globalTimestamps.length,
    });
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
