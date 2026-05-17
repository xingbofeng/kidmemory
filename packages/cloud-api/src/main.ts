import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import cors from 'cors';

import { AppModule } from './app.module.ts';
import { GlobalExceptionFilter } from './infrastructure/http/global-exception.filter.ts';
import { ApiResponseInterceptor } from './infrastructure/http/api-response.interceptor.ts';
import { RateLimitMiddleware } from './infrastructure/security/rate-limit.middleware.ts';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log'],
  });

  const port = process.env.CLOUD_API_PORT || 3002;
  const host = process.env.CLOUD_API_HOST || '0.0.0.0';

  // Enable shutdown hooks
  app.enableShutdownHooks();

  // Configure CORS
  const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:5173'];
  app.use(cors({
    origin: allowedOrigins,
    credentials: true,
  }));

  // Configure security headers
  app.use(helmet());

  // Configure global exception filter
  app.useGlobalFilters(new GlobalExceptionFilter());

  // Configure global response interceptor
  app.useGlobalInterceptors(new ApiResponseInterceptor());

  // Configure rate limiting
  const rateLimitMiddleware = app.get(RateLimitMiddleware);
  app.use(rateLimitMiddleware.use.bind(rateLimitMiddleware));

  // Configure Swagger/OpenAPI documentation
  const swaggerConfig = new DocumentBuilder()
    .setTitle('KidMemory Cloud API')
    .setDescription('Cloud API for KidMemory - handles uploads, sharing, and device sync')
    .setVersion('1.0.0')
    .addServer(`http://${host}:${port}`, 'Local server')
    .addServer('https://api.kidmemory.baby', 'Production server')
    .addTag('health', 'Health check endpoints')
    .addTag('devices', 'Device registration and sync')
    .addTag('uploads', 'Upload management')
    .addTag('shares', 'Share token management')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('docs', app, document, {
    customSiteTitle: 'KidMemory Cloud API',
    customCss: '.swagger-ui .topbar { display: none }',
    jsonDocumentUrl: 'docs/openapi.json',
  });
  // Graceful shutdown handling
  process.on('SIGTERM', async () => {
    console.warn('SIGTERM received, shutting down gracefully');
    await app.close();
    process.exit(0);
  });

  process.on('SIGINT', async () => {
    console.warn('SIGINT received, shutting down gracefully');
    await app.close();
    process.exit(0);
  });

  await app.listen(port, host);
  console.warn(`Cloud API server listening on ${host}:${port}`);
  console.warn(`API Documentation: http://${host}:${port}/docs`);
}

void bootstrap();
