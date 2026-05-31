import { Controller, Get, Inject } from '@nestjs/common';

import { InputValidationMiddleware } from "./input-validation.middleware.ts";
import { RateLimitMiddleware } from "./rate-limit.middleware.ts";
import { SessionQuotaMiddleware } from "./session-quota.middleware.ts";

export class SecurityMonitorController {
  private readonly rateLimitMiddleware?: RateLimitMiddleware;
  private readonly sessionQuotaMiddleware?: SessionQuotaMiddleware;
  private readonly inputValidationMiddleware?: InputValidationMiddleware;

  constructor(
    rateLimitMiddleware?: RateLimitMiddleware,
    sessionQuotaMiddleware?: SessionQuotaMiddleware,
    inputValidationMiddleware?: InputValidationMiddleware,
  ) {
    this.rateLimitMiddleware = rateLimitMiddleware;
    this.sessionQuotaMiddleware = sessionQuotaMiddleware;
    this.inputValidationMiddleware = inputValidationMiddleware;
  }

  getSecurityStats() {
    return {
      timestamp: new Date().toISOString(),
      rateLimit: this.rateLimitMiddleware?.getStats() || null,
      sessionQuota: this.sessionQuotaMiddleware?.getStats() || null,
      inputValidation: this.inputValidationMiddleware?.getStats() || null,
    };
  }

  getSecurityHealth() {
    const rateLimitStats = this.rateLimitMiddleware?.getStats();
    const sessionQuotaStats = this.sessionQuotaMiddleware?.getStats();

    const blockedIpsCount = rateLimitStats?.blockedIps?.length || 0;
    const totalActiveSessions = sessionQuotaStats?.totalActiveSessions || 0;

    let status = 'healthy';
    const warnings: string[] = [];

    if (blockedIpsCount > 10) {
      status = 'warning';
      warnings.push(`${blockedIpsCount} IPs are currently blocked`);
    }

    if (totalActiveSessions > 100) {
      status = 'warning';
      warnings.push(`${totalActiveSessions} active sessions (unusually high)`);
    }

    return {
      status,
      warnings,
      metrics: {
        blockedIps: blockedIpsCount,
        activeSessions: totalActiveSessions,
      },
    };
  }
}

Controller('api/monitor')(SecurityMonitorController);

Inject(RateLimitMiddleware)(SecurityMonitorController, undefined, 0);
Inject(SessionQuotaMiddleware)(SecurityMonitorController, undefined, 1);
Inject(InputValidationMiddleware)(SecurityMonitorController, undefined, 2);

const proto = SecurityMonitorController.prototype;
const desc = (m: string) => Object.getOwnPropertyDescriptor(proto, m)!;

Get('security/stats')(proto, 'getSecurityStats', desc('getSecurityStats'));
Get('security/health')(proto, 'getSecurityHealth', desc('getSecurityHealth'));
