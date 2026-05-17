import { Module, Global } from '@nestjs/common';
import { PrismaService } from './database/prisma.service.ts';
import { RateLimitMiddleware } from './security/rate-limit.middleware.ts';

@Global()
@Module({
  providers: [
    PrismaService,
    RateLimitMiddleware,
  ],
  exports: [
    PrismaService,
    RateLimitMiddleware,
  ],
})
export class InfrastructureModule {}
