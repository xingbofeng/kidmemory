/**
 * 会话配额限制中间件（纯内存实现，零依赖）
 *
 * 防护目标：
 * 1. 限制单个 childId 的活跃会话数量
 * 2. 限制单个 childId 每天创建的会话总数
 * 3. 防止针对特定 childId 的资源耗尽攻击
 */

import { Logger, type NestMiddleware } from '@nestjs/common';
import type { Request, Response, NextFunction } from 'express';
import { ApiCode } from '@kidmemory/protocol';
import { sendErrorResponse } from '../http/response-format.util.js';

interface SessionQuotaRecord {
  activeCount: number;
  dailyCount: number;
  lastResetDate: string;
  sessions: Set<string>;
}

function getCreatedSessionId(body: unknown): string | undefined {
  if (!body || typeof body !== "object") return undefined;

  const responseBody = body as Record<string, unknown>;
  const data = responseBody.data;
  const nestedSessionId =
    data && typeof data === "object"
      ? (data as Record<string, unknown>).sessionId
      : undefined;
  const sessionId = nestedSessionId ?? responseBody.sessionId;

  return typeof sessionId === "string" ? sessionId : undefined;
}

export class SessionQuotaMiddleware implements NestMiddleware {
  private readonly logger = new Logger(SessionQuotaMiddleware.name);

  private readonly quotaRecords = new Map<string, SessionQuotaRecord>();

  private readonly config = {
    maxActiveSessions: 5,
    maxDailySessions: 20,
  };

  private readonly sessionExpiryMs = 3600000;

  private readonly sessionTimestamps = new Map<string, number>();

  private lastCleanupTime = Date.now();

  async use(req: Request, res: Response, next: NextFunction) {
    if (req.method !== 'POST' || !req.path.endsWith('/sessions')) {
      next();
      return;
    }

    const now = Date.now();

    if (Math.random() < 0.05) {
      this.cleanup(now);
    }

    try {
      const body = req.body as { childId?: string } | undefined;
      // 在部分执行顺序下，req.body 可能尚未被解析；此时放行到控制器层做 DTO 校验，
      // 避免把合法请求误判为缺少 childId。
      if (!body || typeof body !== 'object') {
        next();
        return;
      }

      const childId = body.childId;

      if (!childId || String(childId).trim() === '') {
        sendErrorResponse(res, req, {
          statusCode: 400,
          apiCode: ApiCode.MISSING_REQUIRED_FIELD,
          message: 'childId is required',
        });
        return;
      }

      const record = this.getOrCreateRecord(childId, now);

      if (record.activeCount >= this.config.maxActiveSessions) {
        sendErrorResponse(res, req, {
          statusCode: 429,
          apiCode: ApiCode.SESSION_QUOTA_EXCEEDED,
          message: `Maximum ${this.config.maxActiveSessions} active sessions allowed per child`,
          data: {
            quota: {
              active: record.activeCount,
              maxActive: this.config.maxActiveSessions,
            },
          },
        });
        return;
      }

      if (record.dailyCount >= this.config.maxDailySessions) {
        sendErrorResponse(res, req, {
          statusCode: 429,
          apiCode: ApiCode.DAILY_SESSION_QUOTA_EXCEEDED,
          message: `Maximum ${this.config.maxDailySessions} sessions per day allowed per child`,
          data: {
            quota: {
              daily: record.dailyCount,
              maxDaily: this.config.maxDailySessions,
            },
          },
        });
        return;
      }

      const tempSessionId = `temp_${now}_${Math.random().toString(36).substring(7)}`;

      record.sessions.add(tempSessionId);
      record.activeCount = record.sessions.size;
      record.dailyCount++;
      this.sessionTimestamps.set(tempSessionId, now);

      let responseHandled = false;

      const originalJson = res.json?.bind(res);
      const originalSend = res.send?.bind(res);

      if (originalJson) {
        res.json = (body: unknown) => {
          if (!responseHandled) {
            responseHandled = true;
            if (res.statusCode === 201) {
              this.commitReservedSessionFromBody(record, tempSessionId, body, now);
            } else {
              this.rollbackReservedSession(record, tempSessionId);
            }
          }
          return originalJson(body);
        };
      }

      if (originalSend) {
        res.send = (body: unknown) => {
          if (!responseHandled) {
            responseHandled = true;
            if (res.statusCode === 201 && typeof body === 'string') {
              try {
                const parsed: unknown = JSON.parse(body);
                this.commitReservedSessionFromBody(record, tempSessionId, parsed, now);
              } catch {
                this.rollbackReservedSession(record, tempSessionId);
              }
            } else if (res.statusCode !== 201) {
              this.rollbackReservedSession(record, tempSessionId);
            }
          }
          return originalSend(body);
        };
      }

      next();
    } catch (error) {
      this.logger.error(
        'Session quota middleware error',
        error instanceof Error ? error.stack : String(error),
      );
      next();
    }
  }

  private getOrCreateRecord(childId: string, now: number): SessionQuotaRecord {
    let record = this.quotaRecords.get(childId);

    if (!record) {
      record = {
        activeCount: 0,
        dailyCount: 0,
        lastResetDate: this.getCurrentDate(now),
        sessions: new Set(),
      };
      this.quotaRecords.set(childId, record);
    } else {
      const currentDate = this.getCurrentDate(now);
      if (record.lastResetDate !== currentDate) {
        record.dailyCount = 0;
        record.lastResetDate = currentDate;
      }
    }

    return record;
  }

  recordSessionClosure(childId: string, sessionId: string) {
    const record = this.quotaRecords.get(childId);
    if (!record) {
      return;
    }

    if (!sessionId.startsWith('temp_')) {
      record.sessions.delete(sessionId);
      record.activeCount = record.sessions.size;
      this.sessionTimestamps.delete(sessionId);
    }
  }

  private getCurrentDate(timestamp: number): string {
    const date = new Date(timestamp);
    return date.toISOString().split('T')[0];
  }

  private cleanup(now: number) {
    if (now - this.lastCleanupTime < 300000) {
      return;
    }

    this.lastCleanupTime = now;

    const expiredSessions: string[] = [];
    for (const [sessionId, timestamp] of this.sessionTimestamps.entries()) {
      if (now - timestamp > this.sessionExpiryMs) {
        expiredSessions.push(sessionId);
      }
    }

    for (const sessionId of expiredSessions) {
      this.sessionTimestamps.delete(sessionId);

      for (const [childId, record] of this.quotaRecords.entries()) {
        if (record.sessions.has(sessionId)) {
          record.sessions.delete(sessionId);
          record.activeCount = record.sessions.size;
        }
      }
    }

    for (const [childId, record] of this.quotaRecords.entries()) {
      if (record.activeCount === 0 && record.dailyCount === 0) {
        this.quotaRecords.delete(childId);
      }
    }
  }

  getStats() {
    const stats = {
      totalChildren: this.quotaRecords.size,
      totalActiveSessions: this.sessionTimestamps.size,
      children: [] as Array<{
        childId: string;
        activeCount: number;
        dailyCount: number;
        lastResetDate: string;
      }>,
    };

    for (const [childId, record] of this.quotaRecords.entries()) {
      stats.children.push({
        childId,
        activeCount: record.activeCount,
        dailyCount: record.dailyCount,
        lastResetDate: record.lastResetDate,
      });
    }

    return stats;
  }

  clearChildSessions(childId: string) {
    const record = this.quotaRecords.get(childId);
    if (!record) {
      return;
    }

    for (const sessionId of record.sessions) {
      this.sessionTimestamps.delete(sessionId);
    }

    record.sessions.clear();
    record.activeCount = 0;
  }

  private commitReservedSessionFromBody(
    record: SessionQuotaRecord,
    tempSessionId: string,
    body: unknown,
    now: number,
  ) {
    const actualSessionId = getCreatedSessionId(body);
    if (actualSessionId) {
      this.commitReservedSession(record, tempSessionId, actualSessionId, now);
    }
  }

  private commitReservedSession(
    record: SessionQuotaRecord,
    tempSessionId: string,
    actualSessionId: string,
    now: number,
  ) {
    record.sessions.delete(tempSessionId);
    this.sessionTimestamps.delete(tempSessionId);
    record.sessions.add(actualSessionId);
    record.activeCount = record.sessions.size;
    this.sessionTimestamps.set(actualSessionId, now);
  }

  private rollbackReservedSession(record: SessionQuotaRecord, tempSessionId: string) {
    record.sessions.delete(tempSessionId);
    record.activeCount = record.sessions.size;
    record.dailyCount--;
    this.sessionTimestamps.delete(tempSessionId);
  }
}
