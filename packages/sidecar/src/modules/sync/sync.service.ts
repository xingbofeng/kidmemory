import { hostname, platform } from 'node:os';
import { promises as fs } from 'node:fs';
import * as path from 'node:path';
import * as os from 'node:os';
import { Inject, Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { AppConfigService } from '../../infrastructure/config/app-config.service.ts';
import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import { DatasetService } from '../dataset/dataset.service.ts';
import { BooksService } from '../books/books.service.ts';
import { CloudApiClient } from './cloud-api.client.ts';
import { MachineIdService } from './machine-id.service.ts';
import type { UploadItemResponseDto, JobResponseDto } from './dto/cloud-api.dto.ts';

/**
 * SyncService 负责与 Cloud-API 同步。
 *
 * 功能：
 * - 设备注册和心跳
 * - 上传项目同步（稍后实现）
 * - 任务同步（稍后实现）
 *
 * 离线降级：
 * - Cloud-API 不可达时，记录日志但不阻塞
 * - 使用指数退避重试（最大 3 次）
 * - 本地功能继续正常工作
 */
@Injectable()
export class SyncService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(SyncService.name);

  private deviceId: string | null = null;
  private heartbeatInterval: NodeJS.Timeout | null = null;
  private syncInterval: NodeJS.Timeout | null = null;
  private jobSyncInterval: NodeJS.Timeout | null = null;

  // 心跳间隔（毫秒）
  private readonly heartbeatIntervalMs: number;

  constructor(
    @Inject(CloudApiClient) private readonly cloudApiClient: CloudApiClient,
    @Inject(MachineIdService) private readonly machineIdService: MachineIdService,
    @Inject(AppConfigService) private readonly configService: AppConfigService,
    @Inject(PrismaService) private readonly prisma: PrismaService,
    @Inject(DatasetService) private readonly datasetService: DatasetService,
    @Inject(BooksService) private readonly booksService: BooksService
  ) {
    // 从环境变量读取同步间隔，默认 30 秒
    this.heartbeatIntervalMs = Number(process.env.SYNC_INTERVAL_MS) || 30000;
  }

  onModuleInit() {
    this.logger.log('SyncService initializing...');
    void this.initializeSync();
  }

  onModuleDestroy() {
    this.logger.log('SyncService shutting down...');
    this.stopAllIntervals();
  }

  private async initializeSync() {
    // 启动时注册设备（失败不阻塞应用启动）
    await this.registerDevice();

    // 注册成功后再启动同步循环
    if (this.deviceId) {
      this.startHeartbeat();
      this.startUploadSync();
      this.startJobSync();
    }
  }

  /**
   * 获取当前设备 ID
   */
  getDeviceId(): string | null {
    return this.deviceId;
  }

  /**
   * 注册设备
   */
  private async registerDevice() {
    if (!this.machineIdService || typeof this.machineIdService.getMachineId !== 'function') {
      this.logger.warn('MachineIdService is unavailable, continuing in offline mode');
      return;
    }

    const machineId = this.machineIdService.getMachineId();
    const hostName = hostname();
    const platformName = platform();

    this.logger.log(
      `Registering device: machineId=${machineId}, platform=${platformName}, hostname=${hostName}`
    );

    try {
      const response = await this.retryWithBackoff(
        () =>
          this.cloudApiClient.registerDevice({
            machineId,
            platform: platformName,
            hostname: hostName,
          }),
        3
      );

      this.deviceId = response.id;
      this.logger.log(`Device registered successfully: deviceId=${this.deviceId}`);
    } catch (error) {
      this.logger.error(
        `Failed to register device after retries: ${error instanceof Error ? error.message : String(error)}`
      );
      this.logger.warn('Continuing in offline mode - local features will work normally');
    }
  }

  /**
   * 启动心跳循环
   */
  private startHeartbeat() {
    if (this.heartbeatInterval) {
      return;
    }

    this.logger.log(`Starting heartbeat with interval ${this.heartbeatIntervalMs}ms`);

    this.heartbeatInterval = setInterval(() => {
      this.sendHeartbeat();
    }, this.heartbeatIntervalMs);
  }

  /**
   * 发送心跳
   */
  private async sendHeartbeat() {
    if (!this.deviceId) {
      this.logger.warn('Cannot send heartbeat: deviceId is null');
      return;
    }

    try {
      await this.cloudApiClient.heartbeat(this.deviceId);
      this.logger.debug(`Heartbeat sent successfully for device ${this.deviceId}`);
    } catch (error) {
      this.logger.warn(
        `Heartbeat failed: ${error instanceof Error ? error.message : String(error)}`
      );
      // 心跳失败不影响本地功能，只记录日志
    }
  }

  /**
   * 停止所有定时器
   */
  private stopAllIntervals() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
      this.heartbeatInterval = null;
      this.logger.log('Heartbeat interval stopped');
    }

    if (this.syncInterval) {
      clearInterval(this.syncInterval);
      this.syncInterval = null;
      this.logger.log('Sync interval stopped');
    }

    if (this.jobSyncInterval) {
      clearInterval(this.jobSyncInterval);
      this.jobSyncInterval = null;
      this.logger.log('Job sync interval stopped');
    }
  }

  /**
   * 使用指数退避重试
   *
   * @param fn 要执行的函数
   * @param maxRetries 最大重试次数
   * @param baseDelayMs 基础延迟（毫秒）
   */
  private async retryWithBackoff<T>(
    fn: () => Promise<T>,
    maxRetries: number,
    baseDelayMs = 1000
  ): Promise<T> {
    let lastError: Error | null = null;

    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await fn();
      } catch (error) {
        lastError = error instanceof Error ? error : new Error(String(error));

        if (attempt < maxRetries) {
          const delayMs = baseDelayMs * Math.pow(2, attempt);
          this.logger.warn(
            `Attempt ${attempt + 1}/${maxRetries + 1} failed: ${lastError.message}. Retrying in ${delayMs}ms...`
          );
          await this.sleep(delayMs);
        }
      }
    }

    throw lastError || new Error('Retry failed with unknown error');
  }

  /**
   * 睡眠指定毫秒数
   */
  private sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  /**
   * 启动上传同步循环
   */
  private startUploadSync() {
    if (this.syncInterval) {
      return;
    }

    this.logger.log(`Starting upload sync with interval ${this.heartbeatIntervalMs}ms`);

    this.syncInterval = setInterval(() => {
      this.syncUploadItems();
    }, this.heartbeatIntervalMs);
  }

  /**
   * 同步上传项目
   */
  private async syncUploadItems() {
    if (!this.deviceId) {
      this.logger.warn('Cannot sync upload items: deviceId is null');
      return;
    }

    try {
      // 1. 获取待同步项（最多 10 个）
      const items = await this.cloudApiClient.getPendingUploadItems(this.deviceId, 10);

      if (items.length === 0) {
        this.logger.debug('No pending upload items to sync');
        return;
      }

      this.logger.log(`Found ${items.length} pending upload items to sync`);

      // 2. 处理每个项
      for (const item of items) {
        await this.syncUploadItem(item);
      }
    } catch (error) {
      this.logger.warn(
        `Upload sync failed: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * 同步单个上传项目
   */
  private async syncUploadItem(item: UploadItemResponseDto) {
    try {
      this.logger.log(`Syncing upload item ${item.id}: ${item.fileName}`);

      // 1. 检查是否已同步（通过 cloudUploadItemId 去重）
      const existing = await this.checkIfAlreadySynced(item.id);
      if (existing) {
        this.logger.log(`Upload item ${item.id} already synced, skipping`);
        // 更新云端状态为 synced
        await this.cloudApiClient.updateUploadItemSyncStatus(item.id, {
          status: 'synced',
          syncedAt: new Date().toISOString(),
        });
        return;
      }

      // 2. 下载文件到临时目录
      const tempFilePath = await this.downloadFile(item);

      try {
        // 3. 使用 DatasetService 导入文件（创建 asset）
        const assetId = await this.importAsset(item, tempFilePath);

        // 4. 记录 cloudUploadItemId 到 asset metadata（用于去重）
        await this.linkCloudUploadItem(assetId, item.id);

        // 5. 更新云端状态为 synced
        await this.cloudApiClient.updateUploadItemSyncStatus(item.id, {
          status: 'synced',
          syncedAt: new Date().toISOString(),
        });

        this.logger.log(`Successfully synced upload item ${item.id} to asset ${assetId}`);
      } finally {
        // 清理临时文件
        await this.cleanupTempFile(tempFilePath);
      }
    } catch (error) {
      this.logger.error(
        `Failed to sync upload item ${item.id}: ${error instanceof Error ? error.message : String(error)}`
      );

      // 更新云端状态为 failed
      await this.cloudApiClient
        .updateUploadItemSyncStatus(item.id, {
          status: 'failed',
          errorMessage: error instanceof Error ? error.message : String(error),
        })
        .catch((err) => {
          this.logger.error(`Failed to update error status: ${err}`);
        });
    }
  }

  /**
   * 检查上传项是否已同步
   */
  private async checkIfAlreadySynced(cloudUploadItemId: string): Promise<boolean> {
    // 查询 assets 表，检查 metadata 中是否有 cloudUploadItemId
    const result = await this.prisma.asset.findFirst({
      where: {
        metadata: {
          path: ['cloudUploadItemId'],
          equals: cloudUploadItemId,
        },
      },
    });
    return result !== null;
  }

  /**
   * 从 Supabase 下载文件
   */
  private async downloadFile(item: UploadItemResponseDto): Promise<string> {
    const supabaseUrl = this.configService.config.supabaseStorage.url;
    const bucket = this.configService.config.supabaseStorage.bucket;
    const anonKey = this.configService.config.supabaseStorage.anonKey;

    const downloadUrl = `${supabaseUrl}/storage/v1/object/public/${bucket}/${item.objectKey}`;

    this.logger.debug(`Downloading file from ${downloadUrl}`);

    const response = await fetch(downloadUrl, {
      headers: {
        Authorization: `Bearer ${anonKey}`,
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to download file: ${response.status} ${response.statusText}`);
    }

    // 保存到临时目录
    const tempDir = await fs.mkdtemp(path.join(os.tmpdir(), 'kidmemory-sync-'));
    const tempFilePath = path.join(tempDir, item.fileName);

    const buffer = Buffer.from(await response.arrayBuffer());
    await fs.writeFile(tempFilePath, buffer);

    this.logger.debug(`File downloaded to ${tempFilePath}`);

    return tempFilePath;
  }

  /**
   * 导入 asset
   */
  private async importAsset(item: UploadItemResponseDto, tempFilePath: string): Promise<string> {
    const childId = (item as UploadItemResponseDto & { childId?: string }).childId;
    if (!childId || childId.trim().length === 0) {
      throw new Error('Upload item missing childId');
    }

    const result = await this.datasetService.importAssets({
      childId,
      paths: [tempFilePath],
    });

    if (!result.ok || result.imported.length === 0) {
      throw new Error('Failed to import asset');
    }

    const assetId = result.imported[0].id;
    if (!assetId) {
      throw new Error('Imported asset has no ID');
    }

    return assetId;
  }

  /**
   * 关联云端上传项 ID 到 asset
   */
  private async linkCloudUploadItem(assetId: string, cloudUploadItemId: string) {
    // 获取现有 metadata
    const asset = await this.prisma.asset.findUnique({
      where: { id: assetId },
      select: { metadata: true },
    });

    const existingMetadata = (asset?.metadata as Record<string, unknown>) || {};

    // 更新 asset metadata，添加 cloudUploadItemId
    await this.prisma.asset.update({
      where: { id: assetId },
      data: {
        metadata: {
          ...existingMetadata,
          cloudUploadItemId,
        },
      },
    });
  }

  /**
   * 清理临时文件
   */
  private async cleanupTempFile(tempFilePath: string) {
    try {
      const tempDir = path.dirname(tempFilePath);
      await fs.rm(tempDir, { recursive: true, force: true });
      this.logger.debug(`Cleaned up temp directory: ${tempDir}`);
    } catch (error) {
      this.logger.warn(
        `Failed to clean up temp file: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * 启动任务同步循环
   */
  private startJobSync() {
    if (this.jobSyncInterval) {
      return;
    }

    this.logger.log(`Starting job sync with interval ${this.heartbeatIntervalMs}ms`);

    this.jobSyncInterval = setInterval(() => {
      this.syncJobs();
    }, this.heartbeatIntervalMs);
  }

  /**
   * 同步任务
   */
  private async syncJobs() {
    if (!this.deviceId) {
      this.logger.warn('Cannot sync jobs: deviceId is null');
      return;
    }

    try {
      // 1. 获取待处理任务（最多 5 个）
      const jobs = await this.cloudApiClient.getPendingJobs(this.deviceId, 5);

      if (jobs.length === 0) {
        this.logger.debug('No pending jobs to sync');
        return;
      }

      this.logger.log(`Found ${jobs.length} pending jobs to sync`);

      // 2. 处理每个任务
      for (const job of jobs) {
        await this.syncJob(job);
      }
    } catch (error) {
      this.logger.warn(
        `Job sync failed: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * 同步单个任务
   */
  private async syncJob(job: JobResponseDto) {
    try {
      this.logger.log(`Syncing job ${job.id}: ${job.type}`);

      // 1. 更新云端状态为 processing
      await this.cloudApiClient.updateJobStatus(job.id, {
        status: 'processing',
      });

      // 2. 根据任务类型执行任务
      await this.executeJob(job);

      // 3. 更新云端状态为 completed
      await this.cloudApiClient.updateJobStatus(job.id, {
        status: 'completed',
        completedAt: new Date().toISOString(),
      });

      this.logger.log(`Successfully completed job ${job.id}`);
    } catch (error) {
      this.logger.error(
        `Failed to sync job ${job.id}: ${error instanceof Error ? error.message : String(error)}`
      );

      // 更新云端状态为 failed
      await this.cloudApiClient
        .updateJobStatus(job.id, {
          status: 'failed',
          errorMessage: error instanceof Error ? error.message : String(error),
        })
        .catch((err) => {
          this.logger.error(`Failed to update error status: ${err}`);
        });
    }
  }

  /**
   * 执行任务
   */
  private async executeJob(job: JobResponseDto): Promise<Record<string, unknown>> {
    // 根据任务类型执行不同的逻辑
    switch (job.type) {
      case 'book_generation':
        return await this.executeBookGenerationJob(job);
      case 'asset_processing':
        return await this.executeAssetProcessingJob(job);
      case 'export_pdf':
        return await this.executeExportPdfJob(job);
      case 'export_long_image':
        return await this.executeExportLongImageJob(job);
      default:
        throw new Error(`Unknown job type: ${job.type}`);
    }
  }

  /**
   * 执行书稿生成任务
   */
  private async executeBookGenerationJob(job: JobResponseDto): Promise<Record<string, unknown>> {
    // 调用 BooksService.createJob 创建书稿
    const payload = job.payload;
    if (!payload) {
      throw new Error('Invalid book generation job payload');
    }

    // 确保 payload 包含必要字段
    if (!payload.childId || !Array.isArray(payload.assetIds)) {
      throw new Error('Invalid book generation job payload');
    }

    const result = await this.booksService.createJob({
      childId: payload.childId,
      assetIds: payload.assetIds,
    });

    if (result.status !== 200 || !result.data) {
      throw new Error(`Book generation failed: ${JSON.stringify(result)}`);
    }

    // 类型安全地访问 data 属性
    const data = result.data as Record<string, unknown>;
    return {
      localJobId: data.id || null,
      bookId: data.bookId || null,
    };
  }

  /**
   * 执行资产处理任务
   */
  private async executeAssetProcessingJob(job: JobResponseDto): Promise<Record<string, unknown>> {
    // 资产处理任务（例如：向量生成）
    const payload = job.payload;
    if (!payload) {
      throw new Error('Invalid asset processing job payload');
    }

    if (!payload.assetId) {
      throw new Error('Invalid asset processing job payload');
    }

    // 调用 DatasetService.enqueueSearchIndexing
    await this.datasetService.enqueueSearchIndexing(payload.assetId as string);

    return {
      assetId: payload.assetId,
      status: 'queued',
    };
  }

  /**
   * 执行 PDF 导出任务
   */
  private async executeExportPdfJob(job: JobResponseDto): Promise<Record<string, unknown>> {
    // PDF 导出任务
    const payload = job.payload;
    if (!payload) {
      throw new Error('Invalid export PDF job payload');
    }

    if (!payload.jobId) {
      throw new Error('Invalid export PDF job payload');
    }

    const result = await this.booksService.exportPdf(payload.jobId as string, {
      targetPath: payload.targetPath,
    });

    if (result.status !== 200 || !result.data) {
      throw new Error(`PDF export failed: ${JSON.stringify(result)}`);
    }

    // 类型安全地访问 artifact 属性
    const data = result.data as Record<string, unknown>;
    const artifact = data.artifact as Record<string, unknown> | undefined;
    return {
      artifactId: artifact?.id,
      pdfPath: artifact?.localPath,
    };
  }

  /**
   * 执行长图导出任务
   */
  private async executeExportLongImageJob(job: JobResponseDto): Promise<Record<string, unknown>> {
    // 长图导出任务
    const payload = job.payload;
    if (!payload) {
      throw new Error('Invalid export long image job payload');
    }

    if (!payload.jobId) {
      throw new Error('Invalid export long image job payload');
    }

    const result = await this.booksService.exportLongImage(payload.jobId as string, {
      targetPath: payload.targetPath,
    });

    if (result.status !== 200 || !result.data) {
      throw new Error(`Long image export failed: ${JSON.stringify(result)}`);
    }

    // 类型安全地访问 artifact 属性
    const data = result.data as Record<string, unknown>;
    const artifact = data.artifact as Record<string, unknown> | undefined;
    return {
      artifactId: artifact?.id,
      imagePath: artifact?.localPath,
    };
  }
}
