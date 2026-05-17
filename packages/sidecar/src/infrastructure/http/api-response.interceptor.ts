/**
 * API Response Interceptor
 *
 * Wraps all successful responses in { code, msg, data } format
 */

import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  StreamableFile,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import type { Response } from 'express';
import { ApiCode, type Locale } from '@kidmemory/protocol';
import { messageService } from './message.service.js';

@Injectable()
export class ApiResponseInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const ctx = context.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<{ locale?: Locale }>();

    return next.handle().pipe(
      map((data) => {
        // Don't wrap file streams
        if (data instanceof StreamableFile || response.getHeader('content-type')?.toString().startsWith('application/octet-stream')) {
          return data;
        }

        // Don't wrap HTML responses
        const contentType = response.getHeader('content-type')?.toString();
        if (contentType?.includes('text/html') || contentType?.includes('html')) {
          return data;
        }

        // Don't wrap if response is already sent (e.g., file download)
        if (response.headersSent) {
          return data;
        }

        // Don't wrap if data is already in new format
        if (this.isNewFormat(data)) {
          return data;
        }

        // Wrap in new format
        return {
          code: ApiCode.SUCCESS,
          msg: messageService.getMessage(ApiCode.SUCCESS, request.locale ?? 'zh-CN'),
          data,
        };
      })
    );
  }

  private isNewFormat(data: any): boolean {
    // Check if data already has the new format structure
    return (
      data &&
      typeof data === 'object' &&
      'code' in data &&
      'msg' in data &&
      'data' in data
    );
  }
}
