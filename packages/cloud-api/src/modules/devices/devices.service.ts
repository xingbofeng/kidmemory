import { Injectable, NotFoundException, Inject } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import { RegisterDeviceDto, DeviceResponseDto } from './devices.dto.ts';

@Injectable()
export class DevicesService {
  constructor(@Inject(PrismaService) private readonly prisma: PrismaService) {}

  /**
   * Register a device (idempotent by machineId)
   */
  async register(dto: RegisterDeviceDto): Promise<DeviceResponseDto> {
    // Validate machineId
    if (!dto.machineId || dto.machineId.trim().length === 0) {
      throw new Error('machineId is required');
    }

    // Upsert device (idempotent)
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

    return device;
  }

  /**
   * Update device heartbeat
   */
  async heartbeat(deviceId: string): Promise<DeviceResponseDto> {
    try {
      const device = await this.prisma.device.update({
        where: { id: deviceId },
        data: {
          lastHeartbeat: new Date(),
        },
      });

      return device;
    } catch {
      throw new NotFoundException(`Device ${deviceId} not found`);
    }
  }

  /**
   * Get device by ID
   */
  async findById(deviceId: string): Promise<DeviceResponseDto | null> {
    return this.prisma.device.findUnique({
      where: { id: deviceId },
    });
  }

  /**
   * Get device by machineId
   */
  async findByMachineId(machineId: string): Promise<DeviceResponseDto | null> {
    return this.prisma.device.findUnique({
      where: { machineId },
    });
  }

  /**
   * Check if device is online (heartbeat within last 60 seconds)
   */
  isDeviceOnline(device: DeviceResponseDto): boolean {
    const now = new Date();
    const timeSinceHeartbeat = now.getTime() - device.lastHeartbeat.getTime();
    const heartbeatTimeout = 60000; // 60 seconds
    return timeSinceHeartbeat < heartbeatTimeout;
  }
}
