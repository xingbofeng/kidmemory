/**
 * Global Exception Filter
 *
 * Provides consistent error response format across all endpoints
 */

import {
  HttpException,
  HttpStatus,
} from "@nestjs/common";
import type { ArgumentsHost, ExceptionFilter } from "@nestjs/common";
import type { Response } from 'express';

export interface ErrorResponse {
  ok: false;
  code: string;
  message: string;
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
    const request = ctx.getRequest();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code = 'INTERNAL_SERVER_ERROR';
    let message = 'An unexpected error occurred';
    let issues: ErrorResponse['issues'] = undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
        code = this.getCodeFromStatus(status);
      } else if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
        const responseObj = exceptionResponse as any;
        message = responseObj.message || message;
        code = responseObj.code || this.getCodeFromStatus(status);

        // Preserve Zod validation issues
        if (responseObj.issues) {
          issues = responseObj.issues;
        }
      }
    } else if (exception && typeof exception === 'object' && 'errors' in exception) {
      // Handle Zod-like validation errors
      status = HttpStatus.BAD_REQUEST;
      code = 'VALIDATION_ERROR';
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
        code = 'PAYLOAD_TOO_LARGE';
        message = 'Request payload is too large';
      }
    }

    const errorResponse: ErrorResponse = {
      ok: false,
      code,
      message,
      timestamp: new Date().toISOString(),
      path: request.url,
    };

    if (issues) {
      errorResponse.issues = issues;
    }

    // Log error for debugging (but don't expose sensitive details)
    console.error(`HTTP ${status} ${code}:`, {
      path: request.url,
      method: request.method,
      message,
      ...(issues && { issueCount: issues.length }),
    });

    response.status(status).json(errorResponse);
  }

  private getCodeFromStatus(status: number): string {
    switch (status) {
      case HttpStatus.BAD_REQUEST:
        return 'BAD_REQUEST';
      case HttpStatus.UNAUTHORIZED:
        return 'UNAUTHORIZED';
      case HttpStatus.FORBIDDEN:
        return 'FORBIDDEN';
      case HttpStatus.NOT_FOUND:
        return 'NOT_FOUND';
      case HttpStatus.METHOD_NOT_ALLOWED:
        return 'METHOD_NOT_ALLOWED';
      case HttpStatus.CONFLICT:
        return 'CONFLICT';
      case HttpStatus.PAYLOAD_TOO_LARGE:
        return 'PAYLOAD_TOO_LARGE';
      case HttpStatus.UNPROCESSABLE_ENTITY:
        return 'UNPROCESSABLE_ENTITY';
      case HttpStatus.INTERNAL_SERVER_ERROR:
        return 'INTERNAL_SERVER_ERROR';
      case HttpStatus.SERVICE_UNAVAILABLE:
        return 'SERVICE_UNAVAILABLE';
      default:
        return 'HTTP_ERROR';
    }
  }
}
