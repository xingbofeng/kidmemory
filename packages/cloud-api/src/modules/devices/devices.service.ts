import { Injectable, NotFoundException, Inject } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import { RegisterDeviceDto, DeviceResponseDto } from './devices.dto.ts';

interface DeviceRecord {
  id: string;
  machineId: string;
  deviceName: string | null;
  platform: string | null;
  lastHeartbeat: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface DevicesPrismaClient {
  device: {
    upsert(input: {
      where: { machineId: string };
      update: {
        deviceName?: string;
        platform?: string;
        lastHeartbeat: Date;
      };
      create: {
        machineId: string;
        deviceName?: string;
        platform?: string;
        lastHeartbeat: Date;
      };
    }): Promise<DeviceRecord>;
    update(input: {
      where: { id: string };
      data: { lastHeartbeat: Date };
    }): Promise<DeviceRecord>;
    findUnique(input: {
      where: { id?: string; machineId?: string };
    }): Promise<DeviceRecord | null>;
  };
}

@Injectable()
export class DevicesService {
  constructor(@Inject(PrismaService) private readonly prisma: DevicesPrismaClient) {}

  private toDeviceResponse(device: DeviceRecord): DeviceResponseDto {
    return {
      id: device.id,
      machineId: device.machineId,
      deviceName: device.deviceName ?? undefined,
      platform: device.platform ?? undefined,
      lastHeartbeat: device.lastHeartbeat.toISOString(),
      createdAt: device.createdAt.toISOString(),
      updatedAt: device.updatedAt.toISOString(),
    };
  }

  async register(dto: RegisterDeviceDto): Promise<DeviceResponseDto> {
    if (!dto.machineId || dto.machineId.trim().length === 0) {
      throw new Error('machineId is required');
    }

    const device = await this.prisma.device.upsert({
      where: { machineId: dto.machineId },
      update: {
        deviceName: dto.deviceName,
        platform: dto.platform,
        lastHeartbeat: new Date(),
      },
      create: {
        machineId: dto.machineId,
        deviceName: dto.deviceName,
        platform: dto.platform,
        lastHeartbeat: new Date(),
      },
    });

    return this.toDeviceResponse(device);
  }

  async heartbeat(deviceId: string): Promise<DeviceResponseDto> {
    try {
      const device = await this.prisma.device.update({
        where: { id: deviceId },
        data: {
          lastHeartbeat: new Date(),
        },
      });

      return this.toDeviceResponse(device);
    } catch {
      throw new NotFoundException(`Device ${deviceId} not found`);
    }
  }

  async findById(deviceId: string): Promise<DeviceResponseDto | null> {
    const device = await this.prisma.device.findUnique({
      where: { id: deviceId },
    });
    return device ? this.toDeviceResponse(device) : null;
  }

  async findByMachineId(machineId: string): Promise<DeviceResponseDto | null> {
    const device = await this.prisma.device.findUnique({
      where: { machineId },
    });
    return device ? this.toDeviceResponse(device) : null;
  }

  isDeviceOnline(device: DeviceResponseDto): boolean {
    const now = new Date();
    const timeSinceHeartbeat =
      now.getTime() - new Date(device.lastHeartbeat).getTime();
    const heartbeatTimeout = 60000; // 60 seconds
    return timeSinceHeartbeat < heartbeatTimeout;
  }
}
