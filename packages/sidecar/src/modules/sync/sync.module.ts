import { Module } from '@nestjs/common';
import { InfrastructureModule } from '../../infrastructure/infrastructure.module.ts';
import { DatasetModule } from '../dataset/dataset.module.ts';
import { CloudApiClient } from './cloud-api.client.ts';
import { MachineIdService } from './machine-id.service.ts';
import { SyncService } from './sync.service.ts';

@Module({
  imports: [InfrastructureModule, DatasetModule],
  providers: [MachineIdService, CloudApiClient, SyncService],
  exports: [SyncService, MachineIdService, CloudApiClient],
})
export class SyncModule {}
