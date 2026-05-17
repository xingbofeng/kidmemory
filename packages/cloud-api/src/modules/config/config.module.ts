import { Module } from '@nestjs/common';
import { ConfigController } from './config.controller.ts';
import { ConfigService } from './config.service.ts';

@Module({
  controllers: [ConfigController],
  providers: [ConfigService],
  exports: [ConfigService],
})
export class ConfigModule {}
