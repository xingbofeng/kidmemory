import { hostname, platform } from 'node:os';
import { promises as fs } from 'node:fs';
import * as path from 'node:path';
import * as os from 'node:os';
import { Inject, Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { AppConfigService } from '../../infrastructure/config/app-config.service.ts';
import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import { delay } from '../../infrastructure/time/delay.ts';
import { DatasetService } from '../dataset/dataset.service.ts';
import { CloudApiClient } from './cloud-api.client.ts';
import { MachineIdService } from './machine-id.service.ts';
import type { UploadItemResponseDto } from './dto/cloud-api.dto.ts';

@Injectable()
export class SyncService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(SyncService.name);

  private deviceId: string | null = null;
  private heartbeatInterval: NodeJS.Timeout | null = null;
  private syncInterval: NodeJS.Timeout | null = null;

  private readonly heartbeatIntervalMs: number;

  constructor(
    @Inject(CloudApiClient) private readonly cloudApiClient: CloudApiClient,
    @Inject(MachineIdService) private readonly machineIdService: MachineIdService,
    @Inject(AppConfigService) private readonly configService: AppConfigService,
    @Inject(PrismaService) private readonly prisma: PrismaService,
    @Inject(DatasetService) private readonly datasetService: DatasetService
  ) {
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
    if (this.isCloudSyncDisabled()) {
      this.logger.log('Cloud sync disabled for this launch; skipping Cloud-API registration');
      return;
    }

    await this.registerDevice();

    if (this.deviceId) {
      this.startHeartbeat();
      this.startUploadSync();
    }
  }

  getDeviceId(): string | null {
    return this.deviceId;
  }

  private async registerDevice() {
    if (!this.machineIdService || typeof this.machineIdService.getMachineId !== 'function') {
      this.logger.warn('MachineIdService is unavailable, continuing in offline mode');
      return;
    }

    const machineId = this.machineIdService.getMachineId();
    const hostName = hostname();
    const runtimePlatform = platform();
    const platformName: 'linux' | 'macos' | 'windows' =
      runtimePlatform === 'darwin'
        ? 'macos'
        : runtimePlatform === 'win32'
          ? 'windows'
          : 'linux';

    this.logger.log(
      `Registering device: machineId=${machineId}, platform=${platformName}, hostname=${hostName}`
    );

    try {
      const response = await this.retryWithBackoff(
        () =>
          this.cloudApiClient.registerDevice({
            machineId,
            platform: platformName,
            deviceName: hostName,
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

  private startHeartbeat() {
    if (this.heartbeatInterval) {
      return;
    }

    this.logger.log(`Starting heartbeat with interval ${this.heartbeatIntervalMs}ms`);

    this.heartbeatInterval = setInterval(() => {
      this.sendHeartbeat();
    }, this.heartbeatIntervalMs);
  }

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
    }
  }

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
  }

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
          await delay(delayMs);
        }
      }
    }

    throw lastError || new Error('Retry failed with unknown error');
  }

  private isCloudSyncDisabled(): boolean {
    const raw = process.env.KIDMEMORY_DISABLE_CLOUD_SYNC?.trim().toLowerCase();
    return raw === '1' || raw === 'true' || raw === 'yes' || raw === 'on';
  }

  private startUploadSync() {
    if (this.syncInterval) {
      return;
    }

    this.logger.log(`Starting upload sync with interval ${this.heartbeatIntervalMs}ms`);

    this.syncInterval = setInterval(() => {
      this.syncUploadItems();
    }, this.heartbeatIntervalMs);
  }

  private async syncUploadItems() {
    if (!this.deviceId) {
      this.logger.warn('Cannot sync upload items: deviceId is null');
      return;
    }

    try {
      const items = await this.cloudApiClient.getPendingUploadItems(this.deviceId, 10);

      if (items.length === 0) {
        this.logger.debug('No pending upload items to sync');
        return;
      }

      this.logger.log(`Found ${items.length} pending upload items to sync`);

      for (const item of items) {
        await this.syncUploadItem(item);
      }
    } catch (error) {
      this.logger.warn(
        `Upload sync failed: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  private async syncUploadItem(item: UploadItemResponseDto) {
    try {
      this.logger.log(`Syncing upload item ${item.id}: ${item.fileName}`);

      const existing = await this.checkIfAlreadySynced(item.id);
      if (existing) {
        this.logger.log(`Upload item ${item.id} already synced, skipping`);
        await this.cloudApiClient.updateUploadItemSyncStatus(item.id, {
          status: 'synced',
          syncedAt: new Date().toISOString(),
        });
        return;
      }

      const tempFilePath = await this.downloadFile(item);

      try {
        const assetId = await this.importAsset(item, tempFilePath);

        await this.linkCloudUploadItem(assetId, item.id);

        await this.cloudApiClient.updateUploadItemSyncStatus(item.id, {
          status: 'synced',
          syncedAt: new Date().toISOString(),
        });

        this.logger.log(`Successfully synced upload item ${item.id} to asset ${assetId}`);
      } finally {
        await this.cleanupTempFile(tempFilePath);
      }
    } catch (error) {
      this.logger.error(
        `Failed to sync upload item ${item.id}: ${error instanceof Error ? error.message : String(error)}`
      );

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

  private async checkIfAlreadySynced(cloudUploadItemId: string): Promise<boolean> {
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

  private async downloadFile(item: UploadItemResponseDto): Promise<string> {
    const supabaseUrl = this.configService.config.supabaseStorage.url;
    const bucket = this.configService.config.supabaseStorage.bucket;
    const serviceRoleKey = this.configService.config.supabaseStorage.serviceRoleKey;
    const anonKey = this.configService.config.supabaseStorage.anonKey;

    const privateDownloadUrl = `${supabaseUrl}/storage/v1/object/${bucket}/${item.objectKey}`;
    const publicDownloadUrl = `${supabaseUrl}/storage/v1/object/public/${bucket}/${item.objectKey}`;

    this.logger.debug(`Downloading file from private endpoint: ${privateDownloadUrl}`);

    let response = await fetch(privateDownloadUrl, {
      headers: {
        ...(serviceRoleKey ? { apikey: serviceRoleKey } : {}),
        Authorization: `Bearer ${serviceRoleKey || anonKey}`,
      },
    });

    if (!response.ok) {
      this.logger.warn(
        `Private download failed (${response.status}), falling back to public endpoint for ${item.objectKey}`
      );
      response = await fetch(publicDownloadUrl, {
        headers: {
          Authorization: `Bearer ${anonKey}`,
        },
      });
    }

    if (!response.ok) {
      throw new Error(`Failed to download file: ${response.status} ${response.statusText}`);
    }

    const tempDir = await fs.mkdtemp(path.join(os.tmpdir(), 'kidmemory-sync-'));
    const tempFilePath = path.join(tempDir, item.fileName);

    const buffer = Buffer.from(await response.arrayBuffer());
    await fs.writeFile(tempFilePath, buffer);

    this.logger.debug(`File downloaded to ${tempFilePath}`);

    return tempFilePath;
  }

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

  private async linkCloudUploadItem(assetId: string, cloudUploadItemId: string) {
    const asset = await this.prisma.asset.findUnique({
      where: { id: assetId },
      select: { metadata: true },
    });

    const existingMetadata = (asset?.metadata as Record<string, unknown>) || {};

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

}
