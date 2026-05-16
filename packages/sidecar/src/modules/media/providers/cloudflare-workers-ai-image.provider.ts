import { Injectable } from "@nestjs/common";

import type { GenerateImageInput, GenerateImageResult, ImageProvider } from "./image-provider.ts";

@Injectable()
export class CloudflareWorkersAiImageProvider implements ImageProvider {
  readonly providerName = "cloudflare-workers-ai";

  async generate(input: GenerateImageInput): Promise<GenerateImageResult> {
    return {
      ok: false,
      provider: this.providerName,
      prompt: input.prompt,
      error: {
        code: "PROVIDER_NOT_IMPLEMENTED",
        message: "Cloudflare Workers AI image provider is reserved for a later phase.",
        recoverable: true,
      },
      privacyBoundary: {
        textOnly: true,
        childPhotoUpload: false,
      },
    };
  }
}
