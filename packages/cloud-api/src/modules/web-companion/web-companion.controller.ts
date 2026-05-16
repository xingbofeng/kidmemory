import { Body, Controller, Get, Inject, Param, Post, Put, Query } from '@nestjs/common';
import { ApiBody, ApiOperation, ApiQuery, ApiResponse, ApiTags } from '@nestjs/swagger';

import {
  CommitUploadItemRequestDto,
  CommitUploadItemResponseDto,
  CreateUploadItemsRequestDto,
  CreateUploadItemsResponseDto,
  DirectUploadConfigResponseDto,
  SessionSummaryResponseDto,
  ShareTokenValidationResponseDto,
  SharedAssetDto,
  SharedBookDto,
} from './web-companion.dto.ts';
import { WebCompanionService } from './web-companion.service.ts';

@ApiTags('web-companion')
@Controller('/api/web-companion')
export class WebCompanionController {
  constructor(@Inject(WebCompanionService) private readonly service: WebCompanionService) {}

  @Get('/direct-upload/sessions/:sessionId/config')
  @ApiOperation({ summary: 'Get direct upload config for trusted upload session' })
  @ApiResponse({ status: 200, type: DirectUploadConfigResponseDto })
  async getDirectUploadConfig(@Param('sessionId') sessionId: string): Promise<DirectUploadConfigResponseDto> {
    return this.service.getDirectUploadConfig(sessionId);
  }

  @Get('/sessions/:sessionId')
  @ApiOperation({ summary: 'Get trusted upload session summary' })
  @ApiResponse({ status: 200, type: SessionSummaryResponseDto })
  async getSessionSummary(
    @Param('sessionId') sessionId: string,
    // token kept for compatibility with existing web clients.
    @Query('token') _token?: string,
  ): Promise<SessionSummaryResponseDto> {
    return this.service.getSessionSummary(sessionId);
  }

  @Post('/sessions/:sessionId/items')
  @ApiOperation({ summary: 'Create upload items for trusted upload session' })
  @ApiBody({ type: CreateUploadItemsRequestDto })
  @ApiResponse({ status: 200, type: CreateUploadItemsResponseDto })
  async createUploadItems(
    @Param('sessionId') sessionId: string,
    @Body() body: CreateUploadItemsRequestDto,
  ): Promise<CreateUploadItemsResponseDto> {
    return this.service.createUploadItems(sessionId, body);
  }

  @Put('/sessions/:sessionId/items/:uploadItemId/commit')
  @ApiOperation({ summary: 'Commit upload item' })
  @ApiBody({ type: CommitUploadItemRequestDto })
  @ApiResponse({ status: 200, type: CommitUploadItemResponseDto })
  async commitUploadItem(
    @Param('sessionId') sessionId: string,
    @Param('uploadItemId') uploadItemId: string,
    @Body() body: CommitUploadItemRequestDto,
  ): Promise<CommitUploadItemResponseDto> {
    return this.service.commitUploadItem(sessionId, uploadItemId, body);
  }

  @Get('/share/:shareToken/access')
  @ApiOperation({ summary: 'Validate public share token' })
  @ApiQuery({ name: 'clientIp', required: false })
  @ApiQuery({ name: 'userAgent', required: false })
  @ApiResponse({ status: 200, type: ShareTokenValidationResponseDto })
  async validateShareToken(
    @Param('shareToken') shareToken: string,
    @Query('clientIp') clientIp?: string,
    @Query('userAgent') userAgent?: string,
  ): Promise<ShareTokenValidationResponseDto> {
    return this.service.validateShareToken({ token: shareToken, clientIp, userAgent });
  }

  @Get('/share/:shareToken/assets')
  @ApiOperation({ summary: 'Get public shared assets' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, type: [SharedAssetDto] })
  async getSharedAssets(
    @Param('shareToken') shareToken: string,
    @Query('limit') limit?: string,
  ): Promise<SharedAssetDto[]> {
    const parsedLimit = limit ? Number(limit) : undefined;
    return this.service.getSharedAssets(shareToken, Number.isFinite(parsedLimit) ? parsedLimit : undefined);
  }

  @Get('/share/:shareToken/book')
  @ApiOperation({ summary: 'Get public shared book metadata' })
  @ApiQuery({ name: 'bookId', required: false, type: String })
  @ApiResponse({ status: 200, type: SharedBookDto })
  async getSharedBook(
    @Param('shareToken') shareToken: string,
    @Query('bookId') bookId?: string,
  ): Promise<SharedBookDto> {
    return this.service.getSharedBook(shareToken, bookId);
  }
}
