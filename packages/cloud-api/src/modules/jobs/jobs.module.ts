import { Module } from '@nestjs/common';
import { JobsController } from './jobs.controller.ts';
import { JobsService } from './jobs.service.ts';

@Module({
  controllers: [JobsController],
  providers: [JobsService],
  exports: [JobsService],
})
export class JobsModule {}
