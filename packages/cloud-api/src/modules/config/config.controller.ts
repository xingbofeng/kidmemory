import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';

@ApiTags('config')
@Controller('/config')
export class ConfigController {
  @Get('/status')
  @ApiOperation({ summary: 'Get configuration status' })
  @ApiResponse({ status: 200, description: 'Configuration status' })
  getStatus() {
    return {
      database: this.checkDatabase(),
      storage: this.checkStorage(),
      environment: process.env.NODE_ENV || 'development',
    };
  }

  private checkDatabase() {
    const hasUrl = !!process.env.DATABASE_URL;
    return {
      configured: hasUrl,
      status: hasUrl ? 'configured' : 'missing',
    };
  }

  private checkStorage() {
    const hasSupabase = !!(
      process.env.SUPABASE_URL &&
      process.env.SUPABASE_ANON_KEY
    );
    return {
      configured: hasSupabase,
      status: hasSupabase ? 'configured' : 'missing',
    };
  }
}
