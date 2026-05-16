import { Controller, Post, Put, Get, Body, Param, HttpCode, HttpStatus, Inject } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { DevicesService } from './devices.service.ts';
import { RegisterDeviceDto, DeviceResponseDto } from './devices.dto.ts';

@ApiTags('devices')
@Controller('/devices')
export class DevicesController {
  constructor(@Inject(DevicesService) private readonly devicesService: DevicesService) {}

  @Post('/register')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Register a device (idempotent by machineId)' })
  @ApiResponse({ status: 200, description: 'Device registered successfully', type: DeviceResponseDto })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async register(@Body() dto: RegisterDeviceDto): Promise<DeviceResponseDto> {
    return this.devicesService.register(dto);
  }

  @Put('/:id/heartbeat')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update device heartbeat' })
  @ApiResponse({ status: 200, description: 'Heartbeat updated', type: DeviceResponseDto })
  @ApiResponse({ status: 404, description: 'Device not found' })
  async heartbeat(@Param('id') id: string): Promise<DeviceResponseDto> {
    return this.devicesService.heartbeat(id);
  }

  @Get('/:id')
  @ApiOperation({ summary: 'Get device by ID' })
  @ApiResponse({ status: 200, description: 'Device found', type: DeviceResponseDto })
  @ApiResponse({ status: 404, description: 'Device not found' })
  async getDevice(@Param('id') id: string): Promise<DeviceResponseDto | null> {
    return this.devicesService.findById(id);
  }
}
