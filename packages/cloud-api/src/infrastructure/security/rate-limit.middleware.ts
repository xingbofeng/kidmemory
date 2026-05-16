import { Injectable, NestMiddleware, HttpException, HttpStatus } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

interface RateLimitEntry {
  count: number;
  resetAt: number;
}

@Injectable()
export class RateLimitMiddleware implements NestMiddleware {
  private readonly limits = new Map<string, RateLimitEntry>();
  private readonly windowMs: number;
  private readonly maxRequests: number;
  private cleanupInterval: NodeJS.Timeout | null = null;

  constructor() {
    this.windowMs = parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10);
    this.maxRequests = parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10);
    
    // Cleanup old entries every minute
    this.cleanupInterval = setInterval(() => {
      this.cleanup();
    }, 60000);
  }

  use(req: Request, res: Response, next: NextFunction) {
    const ip = this.getClientIp(req);
    const now = Date.now();
    
    let entry = this.limits.get(ip);
    
    if (!entry || now > entry.resetAt) {
      entry = {
        count: 1,
        resetAt: now + this.windowMs,
      };
      this.limits.set(ip, entry);
      return next();
    }
    
    entry.count++;
    
    if (entry.count > this.maxRequests) {
      throw new HttpException(
        {
          code: 15000,
          msg: 'Rate limit exceeded',
          data: {
            limit: this.maxRequests,
            windowMs: this.windowMs,
            resetAt: new Date(entry.resetAt).toISOString(),
          },
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }
    
    next();
  }

  private getClientIp(req: Request): string {
    return (
      (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() ||
      (req.headers['x-real-ip'] as string) ||
      req.socket.remoteAddress ||
      'unknown'
    );
  }

  private cleanup() {
    const now = Date.now();
    for (const [ip, entry] of this.limits.entries()) {
      if (now > entry.resetAt) {
        this.limits.delete(ip);
      }
    }
  }

  onModuleDestroy() {
    if (this.cleanupInterval) {
      clearInterval(this.cleanupInterval);
    }
  }
}
