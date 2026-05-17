/**
 * HTTP Runtime Configuration
 *
 * Provides configuration for CORS, body limits, security headers, and logging
 */

/**
 * CORS 配置说明：
 * - allowedOrigins：精确匹配的白名单，通过 KIDMEMORY_HTTP_ALLOWED_ORIGINS 环境变量配置（逗号分隔）
 * - 局域网 IP（192.168.x.x、10.x.x.x、172.16-31.x.x）自动允许，无需配置
 * - 生产环境建议通过 KIDMEMORY_HTTP_ALLOWED_ORIGINS 明确指定允许的域名
 */

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
        enableHelmet: parseBoolean(
          env.KIDMEMORY_HTTP_HELMET_ENABLED,
          DEFAULT_HTTP_RUNTIME_CONFIG.security.enableHelmet,
        ),
        contentSecurityPolicy: parseBoolean(
          env.KIDMEMORY_HTTP_CSP_ENABLED,
          DEFAULT_HTTP_RUNTIME_CONFIG.security.contentSecurityPolicy,
        ),
      },
      logging: {
        enableRequestLogging: parseBoolean(
          env.KIDMEMORY_HTTP_REQUEST_LOGGING_ENABLED,
          DEFAULT_HTTP_RUNTIME_CONFIG.logging.enableRequestLogging,
        ),
        redactSecrets: parseBoolean(
          env.KIDMEMORY_HTTP_REDACT_SECRETS,
          DEFAULT_HTTP_RUNTIME_CONFIG.logging.redactSecrets,
        ),
      },
    };
    if (allowedOrigins.length > 0) {
      overrides.cors = { allowedOrigins, credentials: true };
    }

    // 如果没有配置自定义 origins，提示用户局域网 IP 已自动支持
    if (allowedOrigins.length === 0 && env.NODE_ENV !== 'test') {
      console.info('[CORS] 未配置 KIDMEMORY_HTTP_ALLOWED_ORIGINS，局域网 IP 已自动允许。如需限制，请设置该环境变量。');
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
        // 精确匹配白名单
        if (this.config.cors.allowedOrigins.includes(origin)) {
          callback(null, true);
          return;
        }
        // 动态匹配局域网 IP
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

function parseBoolean(value: string | undefined, fallback: boolean): boolean {
  if (value === undefined) return fallback;
  const normalized = value.trim().toLowerCase();
  if (!normalized) return fallback;
  if (["1", "true", "yes", "on"].includes(normalized)) return true;
  if (["0", "false", "no", "off"].includes(normalized)) return false;
  return fallback;
}

/**
 * 判断 origin 是否来自局域网 IP
 * 支持：192.168.x.x、10.x.x.x、172.16-31.x.x
 * 端口范围：任意端口（局域网设备端口不固定）
 */
export function isLanOrigin(origin: string): boolean {
  try {
    const url = new URL(origin);
    // 只允许 http/https
    if (url.protocol !== 'http:' && url.protocol !== 'https:') return false;
    const hostname = url.hostname;
    // localhost 变体
    if (hostname === 'localhost' || hostname === '127.0.0.1' || hostname === '::1') return true;
    // 192.168.x.x
    if (/^192\.168\.\d{1,3}\.\d{1,3}$/.test(hostname)) return true;
    // 10.x.x.x
    if (/^10\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.test(hostname)) return true;
    // 172.16.x.x - 172.31.x.x
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
