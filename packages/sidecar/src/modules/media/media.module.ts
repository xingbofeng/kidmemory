import { Module } from "@nestjs/common";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { ImageGenerationService } from "./image-generation.service.ts";
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
    ImageGenerationService,
  ],
  exports: [
    PollinationsImageProvider,
    ImageGenerationService,
  ],
})
export class MediaModule {}
