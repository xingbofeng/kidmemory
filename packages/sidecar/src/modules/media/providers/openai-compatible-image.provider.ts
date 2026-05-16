import { Injectable } from "@nestjs/common";

import type { GenerateImageInput, GenerateImageResult, ImageProvider } from "./image-provider.ts";

@Injectable()
export class OpenAiCompatibleImageProvider implements ImageProvider {
  readonly providerName = "openai-compatible";

  async generate(input: GenerateImageInput): Promise<GenerateImageResult> {
    return {
      ok: false,
      provider: this.providerName,
      prompt: input.prompt,
      error: {
        code: "PROVIDER_NOT_IMPLEMENTED",
        message: "OpenAI-compatible image provider is reserved for a later phase.",
        recoverable: true,
      },
      privacyBoundary: {
        textOnly: true,
        childPhotoUpload: false,
      },
    };
  }
}
