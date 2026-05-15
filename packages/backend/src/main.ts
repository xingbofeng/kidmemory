import "reflect-metadata";
import { NestFactory } from "@nestjs/core";
import helmet from "helmet";
import cors from "cors";

import { AppModule } from "./app.module.ts";
import { loadConfigFromEnv } from "./infrastructure/config/app-config.service.ts";
import { HttpRuntimeConfigService } from "./infrastructure/http/http-runtime-config.service.ts";
import { GlobalExceptionFilter } from "./infrastructure/http/global-exception.filter.ts";
import { RequestLoggingMiddleware } from "./infrastructure/http/request-logging.middleware.ts";
import { RateLimitMiddleware } from "./infrastructure/security/rate-limit.middleware.ts";
import { SessionQuotaMiddleware } from "./infrastructure/security/session-quota.middleware.ts";
import { InputValidationMiddleware } from "./infrastructure/security/input-validation.middleware.ts";

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log'],
  });

  const config = loadConfigFromEnv();
  const httpConfig = HttpRuntimeConfigService.fromEnv();

  // Enable shutdown hooks
  app.enableShutdownHooks();

  // Configure CORS
  app.use(cors(httpConfig.getCorsOptions()));

  // Configure security headers
  if (httpConfig.getConfig().security.enableHelmet) {
    app.use(helmet(httpConfig.getHelmetOptions()));
  }

  // Configure body size limits
  app.use('/api', (req: any, res: any, next: any) => {
    // Express built-in body parser limits
    if (req.get('content-type')?.includes('application/json')) {
      const limit = httpConfig.getConfig().bodyLimits.json;
      if (req.get('content-length')) {
        const size = parseInt(req.get('content-length') || '0');
        const limitBytes = parseSize(limit);
        if (size > limitBytes) {
          return res.status(413).json({
            ok: false,
            code: 'PAYLOAD_TOO_LARGE',
            message: `Request payload exceeds limit of ${limit}`,
            timestamp: new Date().toISOString(),
            path: req.url,
          });
        }
      }
    }
    next();
  });

  // Configure global exception filter
  app.useGlobalFilters(new GlobalExceptionFilter());

  // Configure security middlewares (按顺序执行)
  const inputValidationMiddleware = app.get(InputValidationMiddleware);
  const rateLimitMiddleware = app.get(RateLimitMiddleware);
  const sessionQuotaMiddleware = app.get(SessionQuotaMiddleware);

  // 1. 输入验证（最快，阻止明显的恶意请求）
  app.use(inputValidationMiddleware.use.bind(inputValidationMiddleware));

  // 2. 速率限制（阻止高频攻击）
  app.use(rateLimitMiddleware.use.bind(rateLimitMiddleware));

  // 3. 会话配额限制（针对创建会话的特定保护）
  app.use(sessionQuotaMiddleware.use.bind(sessionQuotaMiddleware));

  // 将 sessionQuotaMiddleware 暴露给全局，供 WebCompanionService 使用
  (global as any).sessionQuotaMiddleware = sessionQuotaMiddleware;

  // Configure request logging
  if (httpConfig.getConfig().logging.enableRequestLogging) {
    app.use(new RequestLoggingMiddleware().use.bind(new RequestLoggingMiddleware()));
  }

  // Graceful shutdown handling
  process.on('SIGTERM', async () => {
    console.log('SIGTERM received, shutting down gracefully');
    await app.close();
    process.exit(0);
  });

  process.on('SIGINT', async () => {
    console.log('SIGINT received, shutting down gracefully');
    await app.close();
    process.exit(0);
  });

  await app.listen(config.sidecar.port, config.sidecar.host);
  console.log(`Sidecar HTTP server listening on ${config.sidecar.host}:${config.sidecar.port}`);
}

// Helper function to parse size strings like "5mb" to bytes
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
