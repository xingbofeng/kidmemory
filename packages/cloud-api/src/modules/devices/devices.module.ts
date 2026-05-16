import { Module } from '@nestjs/common';
import { DevicesController } from './devices.controller.ts';
import { DevicesService } from './devices.service.ts';

@Module({
  controllers: [DevicesController],
  providers: [DevicesService],
  exports: [DevicesService],
})
export class DevicesModule {}
