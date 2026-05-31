/**
 * Global Exception Filter
 *
 * Returns all errors in { code, msg, data } format
 */

import {
  HttpException,
  HttpStatus,
  Logger,
} from "@nestjs/common";
import type { ArgumentsHost, ExceptionFilter } from "@nestjs/common";
import type { Response, Request } from 'express';
import { ApiCode, type ApiResponse, type Locale } from '@kidmemory/protocol';
import { messageService } from './message.service.js';

export interface ErrorDetails {
  issues?: Array<{
    path: (string | number)[];
    message: string;
    code: string;
  }>;
  detail?: unknown;
  timestamp: string;
  path: string;
}

type HttpExceptionResponseObject = {
  message?: string | string[];
  apiCode?: number;
  issues?: ErrorDetails["issues"];
  data?: unknown;
};

type ValidationIssue = {
  path?: (string | number)[];
  message?: string;
  code?: string;
};

type ValidationErrorLike = {
  errors?: ValidationIssue[];
};

function isHttpExceptionResponseObject(value: unknown): value is HttpExceptionResponseObject {
  return typeof value === "object" && value !== null;
}

function getResponseMessage(value: HttpExceptionResponseObject["message"], fallback: string): string {
  if (typeof value === "string" && value) return value;
  if (Array.isArray(value) && value.length > 0) return value.join(", ");
  return fallback;
}

function isValidationErrorLike(value: unknown): value is ValidationErrorLike {
  return typeof value === "object" && value !== null && "errors" in value;
}

export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let apiCode: number = ApiCode.INTERNAL_ERROR;
    let message = 'An unexpected error occurred';
    let issues: ErrorDetails['issues'] = undefined;
    let detail: unknown = undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
        apiCode = this.getApiCodeFromStatus(status);
      } else if (isHttpExceptionResponseObject(exceptionResponse)) {
        message = getResponseMessage(exceptionResponse.message, message);
        apiCode = exceptionResponse.apiCode || this.getApiCodeFromStatus(status);

        // Preserve Zod validation issues
        if (exceptionResponse.issues) {
          issues = exceptionResponse.issues;
        }
        if ('data' in exceptionResponse) {
          detail = exceptionResponse.data;
        }
      }
    } else if (isValidationErrorLike(exception)) {
      status = HttpStatus.BAD_REQUEST;
      apiCode = ApiCode.INVALID_PARAMS;
      message = 'Request validation failed';
      if (Array.isArray(exception.errors)) {
        issues = exception.errors.map((error) => ({
          path: error.path || [],
          message: error.message || 'Validation error',
          code: error.code || 'invalid',
        }));
      }
    } else if (exception instanceof Error) {
      message = exception.message;

      if (exception.message.includes('request entity too large')) {
        status = HttpStatus.PAYLOAD_TOO_LARGE;
        apiCode = ApiCode.INVALID_PARAMS;
        message = 'Request payload is too large';
      }
    } else if (exception && typeof exception === "object") {
      const maybe = exception as Record<string, unknown>;
      const candidate =
        (typeof maybe.message === "string" && maybe.message) ||
        (typeof maybe.msg === "string" && maybe.msg) ||
        (typeof maybe.error === "string" && maybe.error);
      if (candidate) {
        message = candidate;
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
    if (detail !== undefined) {
      errorDetails.detail = detail;
    }

    const errorResponse: ApiResponse<ErrorDetails> = {
      code: apiCode,
      msg: messageService.getMessage(apiCode, (request as Request & { locale?: Locale }).locale ?? 'zh-CN'),
      data: errorDetails,
    };

    this.logger.error(
      `HTTP ${status} ${apiCode}: method=${request.method} path=${request.url} message=${message}${issues ? ` issueCount=${issues.length}` : ""}`,
    );

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
