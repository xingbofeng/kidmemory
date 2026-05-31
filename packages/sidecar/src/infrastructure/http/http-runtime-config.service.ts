import { Logger } from '@nestjs/common';

import { parseEnvBoolean } from "../config/env-parsing.ts";

export interface HttpRuntimeConfig {
  cors: {
    allowedOrigins: string[];
    credentials: boolean;
  };
  bodyLimits: {
    json: string;
    urlencoded: string;
  };
  security: {
    enableHelmet: boolean;
    contentSecurityPolicy: boolean;
  };
  logging: {
    enableRequestLogging: boolean;
    redactSecrets: boolean;
  };
}

/**
 * CORS 配置说明：
 * - allowedOrigins：精确匹配的白名单，通过 KIDMEMORY_HTTP_ALLOWED_ORIGINS 环境变量配置（逗号分隔）
 * - 局域网 IP（192.168.x.x、10.x.x.x、172.16-31.x.x）自动允许，无需配置
 * - 生产环境建议通过 KIDMEMORY_HTTP_ALLOWED_ORIGINS 明确指定允许的域名
 */
export const DEFAULT_HTTP_RUNTIME_CONFIG: HttpRuntimeConfig = {
  cors: {
    allowedOrigins: [
      'http://localhost:3000',
      'http://localhost:3001',
      'http://127.0.0.1:3000',
      'http://127.0.0.1:3001',
      // Web Companion local development
      'http://localhost:5173',
      'http://127.0.0.1:5173',
    ],
    credentials: true,
  },
  bodyLimits: {
    json: '5mb',
    urlencoded: '5mb',
  },
  security: {
    enableHelmet: true,
    contentSecurityPolicy: false, // Disabled for local development
  },
  logging: {
    enableRequestLogging: true,
    redactSecrets: true,
  },
};

export class HttpRuntimeConfigService {
  private static readonly logger = new Logger(HttpRuntimeConfigService.name);

  private readonly config: HttpRuntimeConfig;

  static fromEnv(
    env: Record<string, string | undefined> = process.env,
  ): HttpRuntimeConfigService {
    const allowedOrigins = parseCsv(
      env.KIDMEMORY_HTTP_ALLOWED_ORIGINS
      || env.WEB_COMPANION_ALLOWED_ORIGINS,
    );
    const overrides: Partial<HttpRuntimeConfig> = {
      security: {
        enableHelmet: parseEnvBoolean(
          env.KIDMEMORY_HTTP_HELMET_ENABLED,
          DEFAULT_HTTP_RUNTIME_CONFIG.security.enableHelmet,
        ),
        contentSecurityPolicy: parseEnvBoolean(
          env.KIDMEMORY_HTTP_CSP_ENABLED,
          DEFAULT_HTTP_RUNTIME_CONFIG.security.contentSecurityPolicy,
        ),
      },
      logging: {
        enableRequestLogging: parseEnvBoolean(
          env.KIDMEMORY_HTTP_REQUEST_LOGGING_ENABLED,
          DEFAULT_HTTP_RUNTIME_CONFIG.logging.enableRequestLogging,
        ),
        redactSecrets: parseEnvBoolean(
          env.KIDMEMORY_HTTP_REDACT_SECRETS,
          DEFAULT_HTTP_RUNTIME_CONFIG.logging.redactSecrets,
        ),
      },
    };
    if (allowedOrigins.length > 0) {
      overrides.cors = { allowedOrigins, credentials: true };
    }

    if (allowedOrigins.length === 0 && env.NODE_ENV !== 'test') {
      this.logger.log('[CORS] 未配置 KIDMEMORY_HTTP_ALLOWED_ORIGINS，局域网 IP 已自动允许。如需限制，请设置该环境变量。');
    }

    return new HttpRuntimeConfigService(overrides);
  }

  constructor(overrides: Partial<HttpRuntimeConfig> = {}) {
    this.config = {
      ...DEFAULT_HTTP_RUNTIME_CONFIG,
      ...overrides,
      cors: {
        ...DEFAULT_HTTP_RUNTIME_CONFIG.cors,
        ...overrides.cors,
      },
      bodyLimits: {
        ...DEFAULT_HTTP_RUNTIME_CONFIG.bodyLimits,
        ...overrides.bodyLimits,
      },
      security: {
        ...DEFAULT_HTTP_RUNTIME_CONFIG.security,
        ...overrides.security,
      },
      logging: {
        ...DEFAULT_HTTP_RUNTIME_CONFIG.logging,
        ...overrides.logging,
      },
    };
  }

  getConfig(): HttpRuntimeConfig {
    return this.config;
  }

  getCorsOptions() {
    return {
      origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
        // 无 origin（同源请求、curl 等）直接放行
        if (!origin) {
          callback(null, true);
          return;
        }
        if (this.config.cors.allowedOrigins.includes(origin)) {
          callback(null, true);
          return;
        }
        if (isLanOrigin(origin)) {
          callback(null, true);
          return;
        }
        callback(new Error(`CORS: origin not allowed: ${origin}`));
      },
      credentials: this.config.cors.credentials,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    };
  }

  getHelmetOptions() {
    return {
      contentSecurityPolicy: this.config.security.contentSecurityPolicy,
      crossOriginEmbedderPolicy: false, // Disabled for local development
    };
  }
}

function parseCsv(value: string | undefined): string[] {
  return (value || "")
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);
}

/**
 * 判断 origin 是否来自局域网 IP
 * 支持：192.168.x.x、10.x.x.x、172.16-31.x.x
 * 端口范围：任意端口（局域网设备端口不固定）
 */
export function isLanOrigin(origin: string): boolean {
  try {
    const url = new URL(origin);
    if (url.protocol !== 'http:' && url.protocol !== 'https:') return false;
    const hostname = url.hostname;
    if (hostname === 'localhost' || hostname === '127.0.0.1' || hostname === '::1') return true;
    if (/^192\.168\.\d{1,3}\.\d{1,3}$/.test(hostname)) return true;
    if (/^10\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.test(hostname)) return true;
    const match = hostname.match(/^172\.(\d{1,3})\.\d{1,3}\.\d{1,3}$/);
    if (match) {
      const second = parseInt(match[1], 10);
      if (second >= 16 && second <= 31) return true;
    }
    return false;
  } catch {
    return false;
  }
}
