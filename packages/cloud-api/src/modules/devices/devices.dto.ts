import { ApiProperty } from '@nestjs/swagger';

export class RegisterDeviceRequestDto {
  @ApiProperty({ type: String })
  machineId: string;

  @ApiProperty({ type: String, required: false })
  deviceName?: string;

  @ApiProperty({ type: String, required: false })
  platform?: string;
}

export type RegisterDeviceDto = RegisterDeviceRequestDto;

export class DeviceResponseDto {
  @ApiProperty({ type: String })
  id: string;

  @ApiProperty({ type: String })
  machineId: string;

  @ApiProperty({ type: String, required: false })
  deviceName?: string;

  @ApiProperty({ type: String, required: false })
  platform?: string;

  @ApiProperty({ type: String })
  lastHeartbeat: string;

  @ApiProperty({ type: String })
  createdAt: string;

  @ApiProperty({ type: String })
  updatedAt: string;
}
