/**
 * 输入验证中间件（纯内存实现，零依赖）
 *
 * 防护目标：
 * 1. 验证 childId 格式（防止注入攻击）
 * 2. 验证请求体大小（防止内存耗尽）
 * 3. 验证 User-Agent（阻止已知的恶意爬虫）
 * 4. 验证请求频率模式（检测自动化攻击）
 */

import { Logger, type NestMiddleware } from '@nestjs/common';
import type { Request, Response, NextFunction } from 'express';
import { ApiCode } from '@kidmemory/protocol';
import { sendErrorResponse } from '../http/response-format.util.js';

interface SuspiciousPattern {
  ip: string;
  reason: string;
  timestamp: number;
}

export class InputValidationMiddleware implements NestMiddleware {
  private readonly logger = new Logger(InputValidationMiddleware.name);

  private readonly suspiciousPatterns: SuspiciousPattern[] = [];

  private readonly maliciousUserAgents = [
    /scrapy/i,
    /nikto/i,
    /sqlmap/i,
    /nmap/i,
  ];

  // childId 支持 UUID v4（推荐）以及后端现有的安全字符 ID。
  private readonly childIdUuidV4Regex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  private readonly childIdSafeSlugRegex = /^[a-zA-Z0-9_-]{1,128}$/;

  private readonly maxBodySize = 10 * 1024 * 1024;

  use(req: Request, res: Response, next: NextFunction) {
    const ip = this.getClientIp(req);

    try {
      if (!this.validateUserAgent(req, ip)) {
        this.recordSuspicious(ip, 'MALICIOUS_USER_AGENT');
        sendErrorResponse(res, req, {
          statusCode: 403,
          apiCode: ApiCode.FORBIDDEN,
          message: 'Suspicious User-Agent detected',
        });
        return;
      }

      if (!this.validateBodySize(req, ip)) {
        this.recordSuspicious(ip, 'BODY_TOO_LARGE');
        sendErrorResponse(res, req, {
          statusCode: 413,
          apiCode: ApiCode.INVALID_PARAMS,
          message: 'Request body exceeds maximum size',
        });
        return;
      }

      if (req.method === 'POST' && req.path.endsWith('/sessions')) {
        if (!this.validateChildId(req, ip)) {
          this.recordSuspicious(ip, 'INVALID_CHILD_ID');
          sendErrorResponse(res, req, {
            statusCode: 400,
            apiCode: ApiCode.INVALID_FORMAT,
            message: 'childId format is invalid',
          });
          return;
        }
      }

      if (req.method === 'POST' && req.path.endsWith('/sessions')) {
        if (this.detectSequentialAttack(req, ip)) {
          this.recordSuspicious(ip, 'SEQUENTIAL_ENUMERATION');
          sendErrorResponse(res, req, {
            statusCode: 429,
            apiCode: ApiCode.TOO_MANY_REQUESTS,
            message: 'Sequential enumeration detected',
          });
          return;
        }
      }

      next();
    } catch (error) {
      this.logger.error(
        'Input validation middleware error',
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

  private validateUserAgent(req: Request, ip: string): boolean {
    const userAgent = req.headers['user-agent'];

    // 缺少 User-Agent 可疑但不直接拒绝（某些合法客户端可能不发送）
    if (!userAgent) {
      this.logger.warn(`Request without User-Agent: ip=${ip} path=${req.path}`);
      return true;
    }

    for (const pattern of this.maliciousUserAgents) {
      if (pattern.test(userAgent)) {
        this.logger.warn(
          `Malicious User-Agent detected: ip=${ip} userAgent=${userAgent} path=${req.path}`,
        );
        return false;
      }
    }

    return true;
  }

  private validateBodySize(req: Request, ip: string): boolean {
    const contentLength = req.headers['content-length'];

    if (!contentLength) {
      return true;
    }

    const size = parseInt(contentLength, 10);

    if (size > this.maxBodySize) {
      this.logger.warn(
        `Request body too large: ip=${ip} size=${size} maxSize=${this.maxBodySize} path=${req.path}`,
      );
      return false;
    }

    return true;
  }

  private validateChildId(req: Request, ip: string): boolean {
    const body = req.body as { childId?: string };

    if (!body || typeof body !== 'object') {
      return true;
    }

    const childId = body.childId;

    // Body parsing may be deferred in some contexts; fall through to
    // downstream request validation instead of hard-failing here.
    if (typeof childId !== 'string' || childId.trim().length === 0) {
      return true;
    }

    const isValid =
      this.childIdUuidV4Regex.test(childId)
      || this.childIdSafeSlugRegex.test(childId);

    if (!isValid || childId === "." || childId === "..") {
      this.logger.warn(
        `Invalid childId format: ip=${ip} childId=${childId} path=${req.path}`,
      );
      return false;
    }

    return true;
  }

  private detectSequentialAttack(req: Request, ip: string): boolean {
    const body = req.body as { childId?: string };
    const childId = body?.childId;

    if (!childId) {
      return false;
    }

    const sequentialPatterns = [
      /^child-\d+$/i,
      /test-\d+$/i,
      /user-\d+$/i,
      /00000000-0000-4000-8000-0000000000\d{2}$/i,
    ];

    for (const pattern of sequentialPatterns) {
      if (pattern.test(childId)) {
        this.logger.warn(
          `Sequential childId detected: ip=${ip} childId=${childId} path=${req.path}`,
        );
        return true;
      }
    }

    return false;
  }

  private recordSuspicious(ip: string, reason: string) {
    this.suspiciousPatterns.push({
      ip,
      reason,
      timestamp: Date.now(),
    });

    const oneHourAgo = Date.now() - 3600000;
    while (
      this.suspiciousPatterns.length > 0 &&
      this.suspiciousPatterns[0].timestamp < oneHourAgo
    ) {
      this.suspiciousPatterns.shift();
    }

    const ipCount = this.suspiciousPatterns.filter(p => p.ip === ip).length;
    if (ipCount >= 10) {
      const reasons = this.suspiciousPatterns
          .filter(p => p.ip === ip)
          .map(p => p.reason)
          .join(',');
      this.logger.error(
        `High suspicious activity from IP: ip=${ip} count=${ipCount} reasons=${reasons}`,
      );
    }
  }

  getStats() {
    const ipCounts = new Map<string, number>();

    for (const pattern of this.suspiciousPatterns) {
      ipCounts.set(pattern.ip, (ipCounts.get(pattern.ip) || 0) + 1);
    }

    return {
      totalSuspicious: this.suspiciousPatterns.length,
      uniqueIps: ipCounts.size,
      topOffenders: Array.from(ipCounts.entries())
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10)
        .map(([ip, count]) => ({ ip, count })),
    };
  }
}
