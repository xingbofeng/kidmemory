import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code = 10000; // Generic error code
    let message = 'Internal server error';
    let data: unknown = null;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      
      if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
        const resp = exceptionResponse as {
          message?: string;
          code?: number;
          data?: unknown;
        };
        message = resp.message || exception.message;
        code = resp.code || this.getCodeFromStatus(status);
        data = resp.data || null;
      } else {
        message = exceptionResponse as string;
        code = this.getCodeFromStatus(status);
      }
    } else if (exception instanceof Error) {
      message = exception.message;
      console.error('Unhandled exception:', exception);
    }

    response.status(status).json({
      code,
      msg: message,
      data,
    });
  }

  private getCodeFromStatus(status: number): number {
    switch (status) {
      case 400: return 12000; // Bad request
      case 401: return 13000; // Unauthorized
      case 403: return 13001; // Forbidden
      case 404: return 14000; // Not found
      case 429: return 15000; // Rate limit
      case 500: return 10000; // Internal error
      default: return 10000;
    }
  }
}
