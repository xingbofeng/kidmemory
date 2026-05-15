/**
 * HTTP Runtime Configuration
 *
 * Provides configuration for CORS, body limits, security headers, and logging
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
      origin: this.config.cors.allowedOrigins,
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
