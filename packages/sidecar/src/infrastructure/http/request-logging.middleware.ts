/**
 * Request Logging Middleware
 *
 * Provides structured request logging with secret redaction
 */

import type { NestMiddleware } from '@nestjs/common';
import type { Request, Response, NextFunction } from 'express';
import { randomUUID } from 'node:crypto';

export interface RequestLogContext {
  requestId: string;
  method: string;
  path: string;
  userAgent?: string;
  startTime: number;
}

export class RequestLoggingMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const requestId = randomUUID();
    const startTime = Date.now();

    // Add request ID to request for downstream use
    (req as any).requestId = requestId;

    const logContext: RequestLogContext = {
      requestId,
      method: req.method,
      path: req.path,
      userAgent: req.get('User-Agent'),
      startTime,
    };

    // Log request start
    console.log('HTTP Request:', {
      ...logContext,
      query: this.redactSensitiveData(req.query),
      headers: this.redactSensitiveHeaders(req.headers),
    });

    // Override res.json to log response
    const originalJson = res.json;
    res.json = function(body: any) {
      const duration = Date.now() - startTime;

      console.log('HTTP Response:', {
        requestId,
        method: req.method,
        path: req.path,
        status: res.statusCode,
        duration,
        responseSize: JSON.stringify(body).length,
      });

      return originalJson.call(this, body);
    };

    next();
  }

  private redactSensitiveData(data: any): any {
    if (!data || typeof data !== 'object') {
      return data;
    }

    const redacted = { ...data };
    const sensitiveKeys = [
      'password', 'token', 'secret', 'key', 'auth', 'authorization',
      'api_key', 'apikey', 'service_role_key', 'connection_string',
      'database_url', 'postgres_url'
    ];

    for (const key of Object.keys(redacted)) {
      const lowerKey = key.toLowerCase();
      if (sensitiveKeys.some(sensitive => lowerKey.includes(sensitive))) {
        redacted[key] = '[REDACTED]';
      } else if (typeof redacted[key] === 'string') {
        // Redact common secret patterns
        redacted[key] = this.redactSecretPatterns(redacted[key]);
      }
    }

    return redacted;
  }

  private redactSensitiveHeaders(headers: any): any {
    const redacted = { ...headers };
    const sensitiveHeaders = [
      'authorization', 'cookie', 'x-api-key', 'x-auth-token'
    ];

    for (const header of sensitiveHeaders) {
      if (redacted[header]) {
        redacted[header] = '[REDACTED]';
      }
    }

    return redacted;
  }

  private redactSecretPatterns(value: string): string {
    return value
      // OpenAI API keys
      .replace(/sk-[a-zA-Z0-9]{48}/g, 'sk-[REDACTED]')
      // Supabase service role keys
      .replace(/eyJ[a-zA-Z0-9_-]{100,}/g, 'eyJ[REDACTED]')
      // PostgreSQL connection strings
      .replace(/postgresql:\/\/[^@]+@[^/]+\/\w+/g, 'postgresql://[REDACTED]@[REDACTED]/[REDACTED]')
      // Generic long tokens (32+ chars of base64-like characters)
      .replace(/[a-zA-Z0-9+/]{32,}={0,2}/g, '[REDACTED_TOKEN]');
  }
}
