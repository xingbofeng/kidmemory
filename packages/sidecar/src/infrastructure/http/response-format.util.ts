/**
 * Response Format Utility
 *
 * Helper functions for unified API response format
 */

import type { Request, Response } from 'express';
import { ApiCode, ApiResponse } from '@kidmemory/protocol';

/**
 * Send error response in { code, msg, data } format
 */
export function sendErrorResponse(
  res: Response,
  req: Request,
  options: {
    statusCode: number;
    apiCode: number;
    message: string;
    data?: any;
  }
) {
  const { statusCode, apiCode, message, data } = options;

  const response: ApiResponse<any> = {
    code: apiCode,
    msg: message,
    data: data || {
      timestamp: new Date().toISOString(),
      path: req.url,
    },
  };

  res.status(statusCode).json(response);
}
