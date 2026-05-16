import { Module } from '@nestjs/common';
import { UploadItemsController } from './upload-items.controller.ts';
import { UploadItemsService } from './upload-items.service.ts';

@Module({
  controllers: [UploadItemsController],
  providers: [UploadItemsService],
  exports: [UploadItemsService],
})
export class UploadItemsModule {}
