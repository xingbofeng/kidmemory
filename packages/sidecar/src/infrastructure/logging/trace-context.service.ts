import { Injectable } from "@nestjs/common";
import { AsyncLocalStorage } from "node:async_hooks";

export const TRACE_HEADER = "x-kidmemory-trace-id";
export const REQUEST_HEADER = "x-kidmemory-request-id";

type TraceContext = {
  traceId: string;
  requestId: string;
};

@Injectable()
export class TraceContextService {
  private readonly storage = new AsyncLocalStorage<TraceContext>();

  normalizeTraceId(value: unknown) {
    if (typeof value !== "string") {
      return this.generateTraceId();
    }

    const trimmed = value.trim();
    if (trimmed.length === 0) {
      return this.generateTraceId();
    }

    return trimmed.slice(0, 128);
  }

  normalizeRequestId(value: unknown) {
    if (typeof value !== "string") {
      return `req_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    }

    const trimmed = value.trim();
    if (trimmed.length === 0) {
      return `req_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    }

    return trimmed.slice(0, 128);
  }

  runWithContext<T>(context: TraceContext, callback: () => T) {
    return this.storage.run(context, callback);
  }

  getContext() {
    return this.storage.getStore();
  }

  getTraceId() {
    return this.getContext()?.traceId;
  }

  getRequestId() {
    return this.getContext()?.requestId;
  }

  private generateTraceId() {
    return `trace_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`;
  }
}
