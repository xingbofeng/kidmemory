/**
 * Response Format Utility
 *
 * Helper functions for unified API response format
 */

import type { Request, Response } from 'express';
import { type ApiResponse, type Locale } from '@kidmemory/protocol';
import { messageService } from './message.service.js';

/**
 * Send error response in { code, msg, data } format
 */
export function sendErrorResponse(
  res: Response,
  req: Request,
  options: {
    statusCode: number;
    apiCode: number;
    message?: string;
    data?: any;
  }
) {
  const { statusCode, apiCode, message, data } = options;
  const locale = (req as Request & { locale?: Locale }).locale ?? 'zh-CN';
  const localizedMessage = messageService.getMessage(apiCode, locale);

  const response: ApiResponse<any> = {
    code: apiCode,
    msg: localizedMessage,
    data: data || {
      timestamp: new Date().toISOString(),
      path: req.url,
      ...(message ? { detailMessage: message } : {}),
    },
  };

  res.status(statusCode).json(response);
}
