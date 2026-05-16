import { ApiProperty } from '@nestjs/swagger';

export class RegisterDeviceDto {
  @ApiProperty({
    description: 'Unique machine identifier',
    example: 'mac-12345-abcde',
  })
  machineId: string;

  @ApiProperty({
    description: 'Device name',
    example: 'MacBook Pro',
    required: false,
  })
  deviceName?: string;

  @ApiProperty({
    description: 'Platform type',
    example: 'macos',
    enum: ['macos', 'windows', 'linux'],
    required: false,
  })
  platform?: string;
}

export class DeviceResponseDto {
  @ApiProperty({ type: String })
  id: string;

  @ApiProperty({ type: String })
  machineId: string;

  @ApiProperty({ type: String, required: false })
  deviceName?: string;

  @ApiProperty({ type: String, required: false })
  platform?: string;

  @ApiProperty({ type: Date })
  lastHeartbeat: Date;

  @ApiProperty({ type: Date })
  createdAt: Date;

  @ApiProperty({ type: Date })
  updatedAt: Date;
}
