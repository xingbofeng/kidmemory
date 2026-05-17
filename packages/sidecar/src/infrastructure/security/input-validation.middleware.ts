/**
 * 输入验证中间件（纯内存实现，零依赖）
 *
 * 防护目标：
 * 1. 验证 childId 格式（防止注入攻击）
 * 2. 验证请求体大小（防止内存耗尽）
 * 3. 验证 User-Agent（阻止已知的恶意爬虫）
 * 4. 验证请求频率模式（检测自动化攻击）
 */

import type { NestMiddleware } from '@nestjs/common';
import type { Request, Response, NextFunction } from 'express';
import { ApiCode } from '@kidmemory/protocol';
import { sendErrorResponse } from '../http/response-format.util.js';

interface SuspiciousPattern {
  ip: string;
  reason: string;
  timestamp: number;
}

export class InputValidationMiddleware implements NestMiddleware {
  // 可疑请求记录
  private readonly suspiciousPatterns: SuspiciousPattern[] = [];

  // 恶意 User-Agent 模式
  private readonly maliciousUserAgents = [
    /scrapy/i,
    /nikto/i,
    /sqlmap/i,
    /nmap/i,
  ];

  // childId 支持 UUID v4（推荐）以及历史兼容的安全字符 ID。
  private readonly childIdUuidV4Regex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  private readonly childIdLegacySafeRegex = /^[a-zA-Z0-9_-]{1,128}$/;

  // 最大请求体大小（10MB）
  private readonly maxBodySize = 10 * 1024 * 1024;

  use(req: Request, res: Response, next: NextFunction) {
    const ip = this.getClientIp(req);

    try {
      // 1. 验证 User-Agent
      if (!this.validateUserAgent(req, ip)) {
        this.recordSuspicious(ip, 'MALICIOUS_USER_AGENT');
        sendErrorResponse(res, req, {
          statusCode: 403,
          apiCode: ApiCode.FORBIDDEN,
          message: 'Suspicious User-Agent detected',
        });
        return;
      }

      // 2. 验证请求体大小
      if (!this.validateBodySize(req, ip)) {
        this.recordSuspicious(ip, 'BODY_TOO_LARGE');
        sendErrorResponse(res, req, {
          statusCode: 413,
          apiCode: ApiCode.INVALID_PARAMS,
          message: 'Request body exceeds maximum size',
        });
        return;
      }

      // 3. 验证 childId（仅针对创建会话的请求）
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

      // 4. 检测顺序枚举攻击
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
      console.error('Input validation middleware error:', error);
      // 出错时放行，避免影响正常请求
      next();
    }
  }

  /**
   * 获取客户端 IP
   */
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

  /**
   * 验证 User-Agent
   */
  private validateUserAgent(req: Request, ip: string): boolean {
    const userAgent = req.headers['user-agent'];

    // 缺少 User-Agent 可疑但不直接拒绝（某些合法客户端可能不发送）
    if (!userAgent) {
      console.warn('Request without User-Agent:', { ip, path: req.path });
      return true;
    }

    // 检查是否匹配恶意模式
    for (const pattern of this.maliciousUserAgents) {
      if (pattern.test(userAgent)) {
        console.warn('Malicious User-Agent detected:', {
          ip,
          userAgent,
          path: req.path,
        });
        return false;
      }
    }

    return true;
  }

  /**
   * 验证请求体大小
   */
  private validateBodySize(req: Request, ip: string): boolean {
    const contentLength = req.headers['content-length'];

    if (!contentLength) {
      return true;
    }

    const size = parseInt(contentLength, 10);

    if (size > this.maxBodySize) {
      console.warn('Request body too large:', {
        ip,
        size,
        maxSize: this.maxBodySize,
        path: req.path,
      });
      return false;
    }

    return true;
  }

  /**
   * 验证 childId 格式
   */
  private validateChildId(req: Request, ip: string): boolean {
    const body = req.body as { childId?: string };
    // 某些中间件执行顺序下，body 可能尚未被 JSON parser 挂载。
    // 此时放行到控制器层，由 DTO 校验兜底，避免误拒合法请求。
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
      || this.childIdLegacySafeRegex.test(childId);

    if (!isValid || childId === "." || childId === "..") {
      console.warn('Invalid childId format:', {
        ip,
        childId,
        path: req.path,
      });
      return false;
    }

    return true;
  }

  /**
   * 检测顺序枚举攻击
   *
   * 攻击者可能尝试：
   * - child-1, child-2, child-3...
   * - 00000000-0000-4000-8000-000000000001, 00000000-0000-4000-8000-000000000002...
   */
  private detectSequentialAttack(req: Request, ip: string): boolean {
    const body = req.body as { childId?: string };
    const childId = body?.childId;

    if (!childId) {
      return false;
    }

    // 检查是否为明显的顺序 ID
    const sequentialPatterns = [
      /^child-\d+$/i,
      /test-\d+$/i,
      /user-\d+$/i,
      /00000000-0000-4000-8000-0000000000\d{2}$/i,
    ];

    for (const pattern of sequentialPatterns) {
      if (pattern.test(childId)) {
        console.warn('Sequential childId detected:', {
          ip,
          childId,
          path: req.path,
        });
        return true;
      }
    }

    return false;
  }

  /**
   * 记录可疑行为
   */
  private recordSuspicious(ip: string, reason: string) {
    this.suspiciousPatterns.push({
      ip,
      reason,
      timestamp: Date.now(),
    });

    // 只保留最近 1 小时的记录
    const oneHourAgo = Date.now() - 3600000;
    while (
      this.suspiciousPatterns.length > 0 &&
      this.suspiciousPatterns[0].timestamp < oneHourAgo
    ) {
      this.suspiciousPatterns.shift();
    }

    // 如果同一 IP 在 1 小时内有超过 10 次可疑行为，记录警告
    const ipCount = this.suspiciousPatterns.filter(p => p.ip === ip).length;
    if (ipCount >= 10) {
      console.error('High suspicious activity from IP:', {
        ip,
        count: ipCount,
        reasons: this.suspiciousPatterns
          .filter(p => p.ip === ip)
          .map(p => p.reason),
      });
    }
  }

  /**
   * 获取可疑行为统计（用于监控）
   */
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
