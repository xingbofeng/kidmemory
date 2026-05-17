import { Module } from '@nestjs/common';
import { HealthController } from './health.controller.ts';

@Module({
  controllers: [HealthController],
})
export class HealthModule {}
