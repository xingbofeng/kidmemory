import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { ApiCode, type ApiResponse } from '@kidmemory/protocol';

@Injectable()
export class ApiResponseInterceptor<T> implements NestInterceptor<T, ApiResponse<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<ApiResponse<T>> {
    const request = context.switchToHttp().getRequest();
    
    // Skip wrapping for file streams
    if (request.url?.includes('/preview') || request.url?.includes('/download')) {
      return next.handle();
    }

    return next.handle().pipe(
      map(data => ({
        code: ApiCode.SUCCESS,
        msg: 'success',
        data,
      })),
    );
  }
}
