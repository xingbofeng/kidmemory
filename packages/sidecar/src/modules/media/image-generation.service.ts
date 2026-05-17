import { Inject, Injectable } from "@nestjs/common";

import { FileLoggerService } from "../../infrastructure/logging/file-logger.service.ts";
import { TraceContextService } from "../../infrastructure/logging/trace-context.service.ts";
import type { GenerateImageInput, GenerateImageResult, ImageProvider } from "./providers/image-provider.ts";
import { PollinationsImageProvider } from "./providers/pollinations-image.provider.ts";

@Injectable()
export class ImageGenerationService {
  private readonly providers: Record<string, ImageProvider>;

  constructor(
    @Inject(PollinationsImageProvider) pollinations: PollinationsImageProvider,
    @Inject(FileLoggerService) private readonly logger: FileLoggerService,
    @Inject(TraceContextService) private readonly traceContext: TraceContextService,
  ) {
    this.providers = {
      pollinations,
    };
  }

  async generateCoverPreview(input: GenerateImageInput & { provider?: string }) {
    const traceId = input.traceId?.trim() || this.traceContext.getTraceId();
    const provider = this.resolveProvider(input.provider);
    const result = await provider.generate(input);

    await this.logger.append({
      timestamp: new Date().toISOString(),
      level: result.ok ? "info" : "warn",
      event: "image.generate_cover_preview",
      traceId,
      data: {
        provider: provider.providerName,
        ok: result.ok,
        promptLength: input.prompt.length,
        recoverable: result.error?.recoverable ?? false,
      },
    });

    return result;
  }

  private resolveProvider(provider: string | undefined): ImageProvider {
    const normalized = provider?.trim().toLowerCase() || process.env.KIDMEMORY_IMAGE_PROVIDER?.trim().toLowerCase() || "pollinations";
    return this.providers[normalized] ?? this.providers.pollinations;
  }
}

export function isRecoverableImageFailure(result: GenerateImageResult) {
  return result.ok === false && Boolean(result.error?.recoverable);
}
