import { BadRequestException } from "@nestjs/common";
import type { ZodType } from "zod";

// Strip-only TypeScript prevents class-validator decorators from working in
// the sidecar runtime, so feature DTOs export zod schemas instead. This helper
// keeps controllers thin: each route validates the incoming body once and
// surfaces any issue as a 400 with a stable JSON shape.
export function parseDto<T>(schema: ZodType<T>, body: unknown, label: string): T {
  const result = schema.safeParse(body);
  if (result.success) return result.data;
  throw new BadRequestException({
    message: `Invalid ${label} payload`,
    issues: result.error.issues.map((issue) => ({
      path: issue.path.join("."),
      code: issue.code,
      message: issue.message,
    })),
  });
}
