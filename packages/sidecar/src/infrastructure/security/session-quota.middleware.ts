/**
 * 会话配额限制中间件（纯内存实现，零依赖）
 *
 * 防护目标：
 * 1. 限制单个 childId 的活跃会话数量
 * 2. 限制单个 childId 每天创建的会话总数
 * 3. 防止针对特定 childId 的资源耗尽攻击
 */

import type { NestMiddleware } from '@nestjs/common';
import type { Request, Response, NextFunction } from 'express';
import { ApiCode } from '@kidmemory/protocol';
import { sendErrorResponse } from '../http/response-format.util.js';

interface SessionQuotaRecord {
  activeCount: number;  // 当前活跃会话数
  dailyCount: number;   // 今天创建的会话总数
  lastResetDate: string; // 上次重置日期（YYYY-MM-DD）
  sessions: Set<string>; // 活跃会话 ID 集合
}

export class SessionQuotaMiddleware implements NestMiddleware {
  // childId -> 配额记录
  private readonly quotaRecords = new Map<string, SessionQuotaRecord>();

  // 配额配置
  private readonly config = {
    maxActiveSessions: 5,    // 每个 childId 最多 5 个活跃会话
    maxDailySessions: 20,    // 每个 childId 每天最多创建 20 个会话
  };

  // 会话过期时间（毫秒）
  private readonly sessionExpiryMs = 3600000; // 1 小时

  // 会话创建时间记录（用于自动清理过期会话）
  private readonly sessionTimestamps = new Map<string, number>();

  // 上次清理时间
  private lastCleanupTime = Date.now();

  private readonly db?: any;

  constructor(db?: any) {
    this.db = db;
  }

  async use(req: Request, res: Response, next: NextFunction) {
    // 只拦截创建会话的请求
    if (req.method !== 'POST' || !req.path.endsWith('/sessions')) {
      next();
      return;
    }

    const now = Date.now();

    // 定期清理过期数据（5% 概率）
    if (Math.random() < 0.05) {
      this.cleanup(now);
    }

    try {
      const body = req.body as { childId?: string };
      const childId = body?.childId;

      if (!childId || String(childId).trim() === '') {
        sendErrorResponse(res, req, {
          statusCode: 400,
          apiCode: ApiCode.MISSING_REQUIRED_FIELD,
          message: 'childId is required',
        });
        return;
      }

      // 获取或创建配额记录
      const record = this.getOrCreateRecord(childId, now);

      // 检查活跃会话配额
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

      // 检查每日会话配额
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

      // 生成临时会话 ID 用于预留配额
      const tempSessionId = `temp_${now}_${Math.random().toString(36).substring(7)}`;
      
      // 预先占用配额（乐观锁定）
      record.sessions.add(tempSessionId);
      record.activeCount = record.sessions.size;
      record.dailyCount++;
      this.sessionTimestamps.set(tempSessionId, now);

      // 标记是否已处理响应
      let responseHandled = false;

      // 拦截响应以更新实际会话 ID
      const originalJson = res.json?.bind(res);
      const originalSend = res.send?.bind(res);
      
      if (originalJson) {
        res.json = (body: any) => {
          if (!responseHandled) {
            responseHandled = true;
            // 如果成功创建会话，用实际 sessionId 替换临时 ID
            if (res.statusCode === 201) {
              const actualSessionId = body?.data?.sessionId || body?.sessionId;
              if (actualSessionId) {
                // 移除临时 ID
                record.sessions.delete(tempSessionId);
                this.sessionTimestamps.delete(tempSessionId);
                
                // 添加实际 ID
                record.sessions.add(actualSessionId);
                record.activeCount = record.sessions.size;
                this.sessionTimestamps.set(actualSessionId, now);
                
                console.log('Session created:', {
                  childId,
                  sessionId: actualSessionId,
                  activeCount: record.activeCount,
                  dailyCount: record.dailyCount,
                });
              }
            } else {
              // 如果创建失败，回滚配额
              record.sessions.delete(tempSessionId);
              record.activeCount = record.sessions.size;
              record.dailyCount--;
              this.sessionTimestamps.delete(tempSessionId);
            }
          }
          return originalJson(body);
        };
      }

      if (originalSend) {
        res.send = (body: any) => {
          if (!responseHandled) {
            responseHandled = true;
            // 处理 send 方法
            if (res.statusCode === 201 && typeof body === 'string') {
              try {
                const parsed = JSON.parse(body);
                const actualSessionId = parsed?.data?.sessionId || parsed?.sessionId;
                if (actualSessionId) {
                  // 移除临时 ID
                  record.sessions.delete(tempSessionId);
                  this.sessionTimestamps.delete(tempSessionId);
                  
                  // 添加实际 ID
                  record.sessions.add(actualSessionId);
                  record.activeCount = record.sessions.size;
                  this.sessionTimestamps.set(actualSessionId, now);
                }
              } catch {
                // 解析失败，回滚配额
                record.sessions.delete(tempSessionId);
                record.activeCount = record.sessions.size;
                record.dailyCount--;
                this.sessionTimestamps.delete(tempSessionId);
              }
            } else if (res.statusCode !== 201) {
              // 如果创建失败，回滚配额
              record.sessions.delete(tempSessionId);
              record.activeCount = record.sessions.size;
              record.dailyCount--;
              this.sessionTimestamps.delete(tempSessionId);
            }
          }
          return originalSend(body);
        };
      }

      next();
    } catch (error) {
      console.error('Session quota middleware error:', error);
      // 出错时放行，避免影响正常请求
      next();
    }
  }

  /**
   * 获取或创建配额记录
   */
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
      // 检查是否需要重置每日计数
      const currentDate = this.getCurrentDate(now);
      if (record.lastResetDate !== currentDate) {
        record.dailyCount = 0;
        record.lastResetDate = currentDate;
      }
    }

    return record;
  }

  /**
   * 记录会话创建
   */
  private recordSessionCreation(childId: string, sessionId: string, now: number) {
    const record = this.quotaRecords.get(childId);
    if (!record) {
      return;
    }

    // 更新活跃会话
    record.sessions.add(sessionId);
    record.activeCount = record.sessions.size;

    // 更新每日计数
    record.dailyCount++;

    // 记录会话创建时间
    this.sessionTimestamps.set(sessionId, now);

    console.log('Session created:', {
      childId,
      sessionId,
      activeCount: record.activeCount,
      dailyCount: record.dailyCount,
    });
  }

  /**
   * 记录会话关闭（供外部调用）
   */
  recordSessionClosure(childId: string, sessionId: string) {
    const record = this.quotaRecords.get(childId);
    if (!record) {
      return;
    }

    // 只删除非临时 ID
    if (!sessionId.startsWith('temp_')) {
      record.sessions.delete(sessionId);
      record.activeCount = record.sessions.size;
      this.sessionTimestamps.delete(sessionId);

      console.log('Session closed:', {
        childId,
        sessionId,
        activeCount: record.activeCount,
      });
    }
  }

  /**
   * 获取当前日期（YYYY-MM-DD）
   */
  private getCurrentDate(timestamp: number): string {
    const date = new Date(timestamp);
    return date.toISOString().split('T')[0];
  }

  /**
   * 清理过期数据
   */
  private cleanup(now: number) {
    // 每 5 分钟清理一次
    if (now - this.lastCleanupTime < 300000) {
      return;
    }

    this.lastCleanupTime = now;

    // 清理过期会话
    const expiredSessions: string[] = [];
    for (const [sessionId, timestamp] of this.sessionTimestamps.entries()) {
      if (now - timestamp > this.sessionExpiryMs) {
        expiredSessions.push(sessionId);
      }
    }

    // 从配额记录中移除过期会话
    for (const sessionId of expiredSessions) {
      this.sessionTimestamps.delete(sessionId);

      for (const [childId, record] of this.quotaRecords.entries()) {
        if (record.sessions.has(sessionId)) {
          record.sessions.delete(sessionId);
          record.activeCount = record.sessions.size;
        }
      }
    }

    // 清理空的配额记录
    for (const [childId, record] of this.quotaRecords.entries()) {
      if (record.activeCount === 0 && record.dailyCount === 0) {
        this.quotaRecords.delete(childId);
      }
    }

    console.log('Session quota cleanup completed:', {
      expiredSessions: expiredSessions.length,
      quotaRecords: this.quotaRecords.size,
      activeSessions: this.sessionTimestamps.size,
    });
  }

  /**
   * 获取配额统计信息（用于监控）
   */
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

  /**
   * 手动清理特定 childId 的所有会话（管理员功能）
   */
  clearChildSessions(childId: string) {
    const record = this.quotaRecords.get(childId);
    if (!record) {
      return;
    }

    // 删除所有会话时间戳
    for (const sessionId of record.sessions) {
      this.sessionTimestamps.delete(sessionId);
    }

    // 重置配额记录
    record.sessions.clear();
    record.activeCount = 0;

    console.log('Cleared all sessions for child:', { childId });
  }
}
