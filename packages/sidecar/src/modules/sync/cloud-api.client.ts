import { Injectable, Logger } from '@nestjs/common';
import type {
  RegisterDeviceDto,
  DeviceResponseDto,
  UploadItemResponseDto,
  UpdateSyncStatusDto,
} from './dto/cloud-api.dto.ts';

@Injectable()
export class CloudApiClient {
  private readonly logger = new Logger(CloudApiClient.name);
  private readonly baseUrl: string;
  private readonly timeout: number;

  constructor() {
    this.baseUrl = process.env.CLOUD_API_URL || 'http://localhost:3002';
    this.timeout = Number(process.env.CLOUD_API_TIMEOUT) || 10000;
  }

  async registerDevice(dto: RegisterDeviceDto): Promise<DeviceResponseDto> {
    return this.request<DeviceResponseDto>('POST', '/devices/register', dto);
  }

  async heartbeat(deviceId: string): Promise<DeviceResponseDto> {
    return this.request<DeviceResponseDto>('PUT', `/devices/${deviceId}/heartbeat`);
  }

  async getPendingUploadItems(deviceId: string, limit = 10): Promise<UploadItemResponseDto[]> {
    const encodedDeviceId = encodeURIComponent(deviceId);
    const url = `/upload-items/pending-sync?deviceId=${encodedDeviceId}&limit=${limit}&offset=0`;
    return this.request<UploadItemResponseDto[]>('GET', url);
  }

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
