/**
 * Global Exception Filter
 *
 * Returns all errors in { code, msg, data } format
 */

import {
  HttpException,
  HttpStatus,
} from "@nestjs/common";
import type { ArgumentsHost, ExceptionFilter } from "@nestjs/common";
import type { Response, Request } from 'express';
import { ApiCode, ApiResponse } from '@kidmemory/protocol';

export interface ErrorDetails {
  issues?: Array<{
    path: (string | number)[];
    message: string;
    code: string;
  }>;
  timestamp: string;
  path: string;
}

export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let apiCode: number = ApiCode.INTERNAL_ERROR;
    let message = 'An unexpected error occurred';
    let issues: ErrorDetails['issues'] = undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
        apiCode = this.getApiCodeFromStatus(status);
      } else if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
        const responseObj = exceptionResponse as any;
        message = responseObj.message || message;
        apiCode = responseObj.apiCode || this.getApiCodeFromStatus(status);

        // Preserve Zod validation issues
        if (responseObj.issues) {
          issues = responseObj.issues;
        }
      }
    } else if (exception && typeof exception === 'object' && 'errors' in exception) {
      // Handle Zod-like validation errors
      status = HttpStatus.BAD_REQUEST;
      apiCode = ApiCode.INVALID_PARAMS;
      message = 'Request validation failed';
      const zodError = exception as any;
      if (Array.isArray(zodError.errors)) {
        issues = zodError.errors.map((error: any) => ({
          path: error.path || [],
          message: error.message || 'Validation error',
          code: error.code || 'invalid',
        }));
      }
    } else if (exception instanceof Error) {
      message = exception.message;

      // Handle specific error types
      if (exception.message.includes('request entity too large')) {
        status = HttpStatus.PAYLOAD_TOO_LARGE;
        apiCode = ApiCode.INVALID_PARAMS;
        message = 'Request payload is too large';
      }
    }

    // New format: { code, msg, data }
    const errorDetails: ErrorDetails = {
      timestamp: new Date().toISOString(),
      path: request.url,
    };

    if (issues) {
      errorDetails.issues = issues;
    }

    const errorResponse: ApiResponse<ErrorDetails> = {
      code: apiCode,
      msg: message,
      data: errorDetails,
    };

    // Log error for debugging
    console.error(`HTTP ${status} ${apiCode}:`, {
      path: request.url,
      method: request.method,
      message,
      ...(issues && { issueCount: issues.length }),
    });

    response.status(status).json(errorResponse);
  }

  private getApiCodeFromStatus(status: number): number {
    switch (status) {
      case HttpStatus.BAD_REQUEST:
        return ApiCode.INVALID_PARAMS;
      case HttpStatus.UNAUTHORIZED:
        return ApiCode.UNAUTHORIZED;
      case HttpStatus.FORBIDDEN:
        return ApiCode.FORBIDDEN;
      case HttpStatus.NOT_FOUND:
        return ApiCode.NOT_FOUND;
      case HttpStatus.METHOD_NOT_ALLOWED:
        return ApiCode.METHOD_NOT_ALLOWED;
      case HttpStatus.CONFLICT:
        return ApiCode.UNKNOWN_ERROR;
      case HttpStatus.PAYLOAD_TOO_LARGE:
        return ApiCode.INVALID_PARAMS;
      case HttpStatus.UNPROCESSABLE_ENTITY:
        return ApiCode.INVALID_PARAMS;
      case HttpStatus.INTERNAL_SERVER_ERROR:
        return ApiCode.INTERNAL_ERROR;
      case HttpStatus.SERVICE_UNAVAILABLE:
        return ApiCode.SERVICE_UNAVAILABLE;
      default:
        return ApiCode.UNKNOWN_ERROR;
    }
  }
}
