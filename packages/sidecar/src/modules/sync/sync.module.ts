import { Module } from '@nestjs/common';
import { InfrastructureModule } from '../../infrastructure/infrastructure.module.ts';
import { DatasetModule } from '../dataset/dataset.module.ts';
import { CloudApiClient } from './cloud-api.client.ts';
import { MachineIdService } from './machine-id.service.ts';
import { SyncService } from './sync.service.ts';

/**
 * SyncModule 提供与 Cloud-API 的同步功能。
 *
 * 包含：
 * - MachineIdService: 生成稳定的机器标识符
 * - CloudApiClient: Cloud-API HTTP 客户端
 * - SyncService: 核心同步服务（设备注册、心跳、上传同步、任务同步）
 */
@Module({
  imports: [InfrastructureModule, DatasetModule],
  providers: [MachineIdService, CloudApiClient, SyncService],
  exports: [SyncService, MachineIdService, CloudApiClient],
})
export class SyncModule {}
