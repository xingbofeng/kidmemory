import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

function fallbackConnectionString(): string {
  const host = process.env.POSTGRES_HOST || '127.0.0.1';
  const port = process.env.POSTGRES_PORT || '5432';
  const database = process.env.POSTGRES_DATABASE || 'kidmemory_cloud';
  const user = process.env.POSTGRES_USER || process.env.USER || 'postgres';
  const password = process.env.POSTGRES_PASSWORD;
  const credentials = password
    ? `${encodeURIComponent(user)}:${encodeURIComponent(password)}`
    : encodeURIComponent(user);
  return `postgresql://${credentials}@${host}:${port}/${database}`;
}

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    super({
      adapter: new PrismaPg({
        connectionString: process.env.DATABASE_URL ?? process.env.POSTGRES_URL ?? fallbackConnectionString(),
      }),
    });
  }

  async onModuleInit() {
    if (!process.env.DATABASE_URL && !process.env.POSTGRES_URL) {
      this.logger.warn('DATABASE_URL not set, skipping database connection');
      return;
    }

    try {
      await this.$connect();
      this.logger.log('Database connected');
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      this.logger.warn(`Database connection failed: ${message}`);
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
    this.logger.log('Database disconnected');
  }
}
