import { Module } from '@nestjs/common';

import { WebCompanionController } from './web-companion.controller.ts';
import { WebCompanionService } from './web-companion.service.ts';

@Module({
  controllers: [WebCompanionController],
  providers: [WebCompanionService],
  exports: [WebCompanionService],
})
export class WebCompanionModule {}
