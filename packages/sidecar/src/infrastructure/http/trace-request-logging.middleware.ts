import { Inject, Injectable, type NestMiddleware } from "@nestjs/common";
import type { NextFunction, Request, Response } from "express";

import { FileLoggerService } from "../logging/file-logger.service.ts";
import {
  REQUEST_HEADER,
  TRACE_HEADER,
  TraceContextService,
} from "../logging/trace-context.service.ts";

@Injectable()
export class TraceRequestLoggingMiddleware implements NestMiddleware {
  constructor(
    @Inject(FileLoggerService) private readonly fileLogger: FileLoggerService,
    @Inject(TraceContextService) private readonly traceContext: TraceContextService,
  ) {}

  use(req: Request, res: Response, next: NextFunction) {
    const startedAt = Date.now();
    const traceId = this.traceContext.normalizeTraceId(req.get(TRACE_HEADER));
    const requestId = this.traceContext.normalizeRequestId(
      req.get(REQUEST_HEADER) ?? (req as Request & { requestId?: string }).requestId,
    );

    (req as Request & { traceId?: string }).traceId = traceId;
    (req as Request & { requestId?: string }).requestId = requestId;
    res.setHeader(TRACE_HEADER, traceId);
    res.setHeader(REQUEST_HEADER, requestId);

    void this.fileLogger.append({
      timestamp: new Date().toISOString(),
      level: "info",
      event: "http.request.started",
      traceId,
      requestId,
      data: {
        method: req.method,
        path: req.path,
      },
    });

    res.on("finish", () => {
      void this.fileLogger.append({
        timestamp: new Date().toISOString(),
        level: res.statusCode >= 500 ? "error" : "info",
        event: "http.request.completed",
        traceId,
        requestId,
        data: {
          method: req.method,
          path: req.path,
          status: res.statusCode,
          durationMs: Date.now() - startedAt,
        },
      });
    });

    this.traceContext.runWithContext({ traceId, requestId }, () => next());
  }
}
