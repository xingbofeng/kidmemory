import { Module } from '@nestjs/common';
import { InfrastructureModule } from './infrastructure/infrastructure.module.ts';
import { HealthModule } from './modules/health/health.module.ts';
import { ConfigModule } from './modules/config/config.module.ts';
import { DevicesModule } from './modules/devices/devices.module.ts';
import { UploadItemsModule } from './modules/upload-items/upload-items.module.ts';
import { JobsModule } from './modules/jobs/jobs.module.ts';
import { WebCompanionModule } from './modules/web-companion/web-companion.module.ts';

@Module({
  imports: [
    InfrastructureModule,
    HealthModule,
    ConfigModule,
    DevicesModule,
    UploadItemsModule,
    JobsModule,
    WebCompanionModule,
  ],
})
export class AppModule {}
