import { Module } from "@nestjs/common";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { HyperframesRenderService } from "./hyperframes-render.service.ts";
import { ImageGenerationService } from "./image-generation.service.ts";
import { CloudflareWorkersAiImageProvider } from "./providers/cloudflare-workers-ai-image.provider.ts";
import { OpenAiCompatibleImageProvider } from "./providers/openai-compatible-image.provider.ts";
import {
  POLLINATIONS_IMAGE_PROVIDER_OPTIONS,
  PollinationsImageProvider,
} from "./providers/pollinations-image.provider.ts";

@Module({
  imports: [InfrastructureModule],
  providers: [
    {
      provide: POLLINATIONS_IMAGE_PROVIDER_OPTIONS,
      useValue: {},
    },
    PollinationsImageProvider,
    CloudflareWorkersAiImageProvider,
    OpenAiCompatibleImageProvider,
    ImageGenerationService,
    HyperframesRenderService,
  ],
  exports: [
    PollinationsImageProvider,
    CloudflareWorkersAiImageProvider,
    OpenAiCompatibleImageProvider,
    ImageGenerationService,
    HyperframesRenderService,
  ],
})
export class MediaModule {}
