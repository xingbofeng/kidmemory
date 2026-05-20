import { Controller, Get, Put, Query, Param, Body, HttpCode, HttpStatus, Inject } from '@nestjs/common';
import { ApiBody, ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { UploadItemsService } from './upload-items.service.ts';
import { UpdateSyncStatusRequestDto, UploadItemResponseDto } from './upload-items.dto.ts';
import type { PendingSyncQueryDto, UpdateSyncStatusDto } from './upload-items.dto.ts';

@ApiTags('upload-items')
@Controller('/upload-items')
export class UploadItemsController {
  constructor(@Inject(UploadItemsService) private readonly uploadItemsService: UploadItemsService) {}

  @Get('/pending-sync')
  @ApiOperation({ summary: 'Get pending sync upload items' })
  @ApiQuery({ name: 'deviceId', required: false, description: 'Filter by device ID' })
  @ApiQuery({ name: 'limit', required: false, description: 'Maximum items to return', type: Number })
  @ApiQuery({ name: 'offset', required: false, description: 'Number of items to skip', type: Number })
  @ApiResponse({ status: 200, description: 'Pending items retrieved', type: UploadItemResponseDto, isArray: true })
  async getPendingSync(@Query() query: PendingSyncQueryDto): Promise<UploadItemResponseDto[]> {
    return this.uploadItemsService.getPendingSync(query);
  }

  @Put('/:id/sync-status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update upload item sync status' })
  @ApiBody({ type: UpdateSyncStatusRequestDto })
  @ApiResponse({ status: 200, description: 'Status updated', type: UploadItemResponseDto })
  @ApiResponse({ status: 400, description: 'Invalid status transition' })
  @ApiResponse({ status: 404, description: 'Item not found' })
  async updateSyncStatus(
    @Param('id') id: string,
    @Body() dto: UpdateSyncStatusDto,
  ): Promise<UploadItemResponseDto> {
    return this.uploadItemsService.updateSyncStatus(id, dto);
  }
}
