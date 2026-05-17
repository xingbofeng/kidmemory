import { Inject, Injectable, Logger } from '@nestjs/common';
import { AppConfigService } from '../../infrastructure/config/app-config.service.ts';
import type {
  RegisterDeviceDto,
  DeviceResponseDto,
  UploadItemResponseDto,
  UpdateSyncStatusDto,
  JobResponseDto,
  UpdateJobStatusDto,
} from './dto/cloud-api.dto.ts';

/**
 * CloudApiClient 负责与 Cloud-API 进行 HTTP 通信。
 *
 * 功能：
 * - 设备注册和心跳
 * - 获取待上传项目
 * - 更新上传项目同步状态
 * - 获取待处理任务
 * - 更新任务状态
 *
 * 错误处理：
 * - 网络错误
 * - 超时
 * - 非 2xx 响应
 */
@Injectable()
export class CloudApiClient {
  private readonly logger = new Logger(CloudApiClient.name);
  private readonly baseUrl: string;
  private readonly timeout: number;

  constructor(@Inject(AppConfigService) private readonly configService: AppConfigService) {
    // 从环境变量读取配置
    this.baseUrl = process.env.CLOUD_API_URL || 'http://localhost:3002';
    this.timeout = Number(process.env.CLOUD_API_TIMEOUT) || 10000;
  }

  /**
   * 注册设备
   */
  async registerDevice(dto: RegisterDeviceDto): Promise<DeviceResponseDto> {
    return this.request<DeviceResponseDto>('POST', '/devices/register', dto);
  }

  /**
   * 发送心跳
   */
  async heartbeat(deviceId: string): Promise<DeviceResponseDto> {
    return this.request<DeviceResponseDto>('PUT', `/devices/${deviceId}/heartbeat`);
  }

  /**
   * 获取待上传项目
   */
  async getPendingUploadItems(deviceId: string, limit = 10): Promise<UploadItemResponseDto[]> {
    const encodedDeviceId = encodeURIComponent(deviceId);
    const url = `/upload-items/pending-sync?deviceId=${encodedDeviceId}&limit=${limit}&offset=0`;
    return this.request<UploadItemResponseDto[]>('GET', url);
  }

  /**
   * 更新上传项目同步状态
   */
  async updateUploadItemSyncStatus(
    itemId: string,
    dto: UpdateSyncStatusDto
  ): Promise<UploadItemResponseDto> {
    return this.request<UploadItemResponseDto>(
      'PUT',
      `/upload-items/${itemId}/sync-status`,
      dto
    );
  }

  /**
   * 获取待处理任务
   */
  async getPendingJobs(deviceId: string, limit = 10): Promise<JobResponseDto[]> {
    const encodedDeviceId = encodeURIComponent(deviceId);
    const url = `/jobs/pending?deviceId=${encodedDeviceId}&limit=${limit}`;
    return this.request<JobResponseDto[]>('GET', url);
  }

  /**
   * 更新任务状态
   */
  async updateJobStatus(jobId: string, dto: UpdateJobStatusDto): Promise<JobResponseDto> {
    return this.request<JobResponseDto>('PUT', `/jobs/${jobId}/status`, dto);
  }

  /**
   * 通用 HTTP 请求方法
   */
  private async request<T>(method: string, path: string, body?: unknown): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    try {
      const options: RequestInit = {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
        signal: controller.signal,
      };

      if (body) {
        options.body = JSON.stringify(body);
      }

      this.logger.debug(`${method} ${url}`);

      const response = await fetch(url, options);

      clearTimeout(timeoutId);

      const contentType = response.headers.get('content-type') ?? '';
      const isJson = contentType.includes('application/json');
      const payload = isJson ? await response.json() : null;

      if (!response.ok) {
        if (this.isApiEnvelope(payload)) {
          throw new Error(payload.msg || `Cloud-API request failed: ${response.status}`);
        }
        const rawText =
          payload == null
            ? await response.text().catch(() => 'Unknown error')
            : JSON.stringify(payload);
        throw new Error(
          `Cloud-API request failed: ${response.status} ${response.statusText} - ${rawText}`
        );
      }

      if (this.isApiEnvelope(payload)) {
        if (payload.code !== 0) {
          throw new Error(payload.msg || `Cloud-API returned error code ${payload.code}`);
        }
        return payload.data as T;
      }

      if (payload != null) {
        return payload as T;
      }

      return {} as T;
    } catch (error) {
      clearTimeout(timeoutId);

      if (error instanceof Error) {
        if (error.name === 'AbortError') {
          throw new Error(`Cloud-API request timeout after ${this.timeout}ms: ${url}`);
        }
        throw new Error(`Cloud-API request failed: ${error.message}`);
      }

      throw new Error(`Cloud-API request failed: ${String(error)}`);
    }
  }

  private isApiEnvelope(
    value: unknown
  ): value is { code: number; msg: string; data: unknown } {
    return Boolean(
      value &&
      typeof value === 'object' &&
      'code' in value &&
      'msg' in value &&
      'data' in value
    );
  }
}
