import "reflect-metadata";
import { Logger } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { SwaggerModule, DocumentBuilder } from "@nestjs/swagger";
import helmet from "helmet";
import cors from "cors";
import type { NextFunction, Request, Response } from "express";
import { ApiCode } from "@kidmemory/protocol";

import { AppModule } from "./app.module.ts";
import { loadConfigFromEnv } from "./infrastructure/config/app-config.service.ts";
import { HttpRuntimeConfigService } from "./infrastructure/http/http-runtime-config.service.ts";
import { GlobalExceptionFilter } from "./infrastructure/http/global-exception.filter.ts";
import { ApiResponseInterceptor } from "./infrastructure/http/api-response.interceptor.ts";
import { createLocaleMiddleware } from "./infrastructure/http/locale.middleware.ts";
import { RateLimitMiddleware } from "./infrastructure/security/rate-limit.middleware.ts";
import { SessionQuotaMiddleware } from "./infrastructure/security/session-quota.middleware.ts";
import { InputValidationMiddleware } from "./infrastructure/security/input-validation.middleware.ts";

async function bootstrap() {
  const logger = new Logger("SidecarBootstrap");
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log'],
  });

  const config = loadConfigFromEnv();
  const httpConfig = HttpRuntimeConfigService.fromEnv();

  app.enableShutdownHooks();

  app.use(cors(httpConfig.getCorsOptions()));

  if (httpConfig.getConfig().security.enableHelmet) {
    app.use(helmet(httpConfig.getHelmetOptions()));
  }

  const localeMiddleware = createLocaleMiddleware();
  app.use(localeMiddleware.use.bind(localeMiddleware));

  app.use('/api', (req: Request, res: Response, next: NextFunction) => {
    if (req.get('content-type')?.includes('application/json')) {
      const limit = httpConfig.getConfig().bodyLimits.json;
      if (req.get('content-length')) {
        const size = Number.parseInt(req.get('content-length') || '0', 10);
        const limitBytes = parseSize(limit);
        if (size > limitBytes) {
          return res.status(413).json({
            code: ApiCode.INVALID_PARAMS,
            msg: `Request payload exceeds limit of ${limit}`,
            data: {
              timestamp: new Date().toISOString(),
              path: req.url,
            },
          });
        }
      }
    }
    next();
  });

  app.useGlobalFilters(new GlobalExceptionFilter());

  app.useGlobalInterceptors(new ApiResponseInterceptor());

  const inputValidationMiddleware = app.get(InputValidationMiddleware);
  const rateLimitMiddleware = app.get(RateLimitMiddleware);
  const sessionQuotaMiddleware = app.get(SessionQuotaMiddleware);

  app.use(inputValidationMiddleware.use.bind(inputValidationMiddleware));

  app.use(rateLimitMiddleware.use.bind(rateLimitMiddleware));

  app.use(sessionQuotaMiddleware.use.bind(sessionQuotaMiddleware));

  const swaggerConfig = new DocumentBuilder()
    .setTitle('KidMemory Sidecar API')
    .setDescription('Local sidecar API for KidMemory desktop application')
    .setVersion('1.0.0')
    .addServer(`http://${config.sidecar.host}:${config.sidecar.port}`, 'Local server')
    .addTag('config', 'Configuration endpoints')
    .addTag('dataset', 'Dataset management')
    .addTag('books', 'Book generation')
    .addTag('web-companion', 'Web companion endpoints')
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('docs', app, document, {
    customSiteTitle: 'KidMemory Sidecar API',
    customCss: '.swagger-ui .topbar { display: none }',
    jsonDocumentUrl: 'docs/openapi.json',
  });

  process.on('SIGTERM', async () => {
    logger.log('SIGTERM received, shutting down gracefully');
    await app.close();
    process.exit(0);
  });

  process.on('SIGINT', async () => {
    logger.log('SIGINT received, shutting down gracefully');
    await app.close();
    process.exit(0);
  });

  await app.listen(config.sidecar.port, config.sidecar.host);
  logger.log(`Sidecar HTTP server listening on ${config.sidecar.host}:${config.sidecar.port}`);
}

function parseSize(size: string): number {
  const units: Record<string, number> = {
    b: 1,
    kb: 1024,
    mb: 1024 * 1024,
    gb: 1024 * 1024 * 1024,
  };

  const match = size.toLowerCase().match(/^(\d+(?:\.\d+)?)(b|kb|mb|gb)?$/);
  if (!match) {
    throw new Error(`Invalid size format: ${size}`);
  }

  const value = parseFloat(match[1]);
  const unit = match[2] || 'b';
  return Math.floor(value * units[unit]);
}

void bootstrap();
