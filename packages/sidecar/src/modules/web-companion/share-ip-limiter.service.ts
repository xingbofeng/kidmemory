export interface ShareIpLimiterConfig {
  maxRequestsPerWindow: number;
  windowMs: number;
  blockDurationMs: number;
}

interface IpRecord {
  timestamps: number[];
  blockedUntil?: number;
}

export class ShareIpLimiterService {
  private readonly ipRecords = new Map<string, IpRecord>();
  private readonly config: ShareIpLimiterConfig;
  private cleanupInterval?: NodeJS.Timeout;

  constructor(config?: Partial<ShareIpLimiterConfig>) {
    this.config = {
      maxRequestsPerWindow: config?.maxRequestsPerWindow ?? 100,
      windowMs: config?.windowMs ?? 60 * 1000,
      blockDurationMs: config?.blockDurationMs ?? 5 * 60 * 1000,
    };

    this.startCleanup();
  }

  checkLimit(ip: string): boolean {
    if (!ip) {
      return true;
    }

    const now = Date.now();
    const record = this.getOrCreateRecord(ip);

    if (record.blockedUntil && now < record.blockedUntil) {
      return false;
    }

    if (record.blockedUntil && now >= record.blockedUntil) {
      delete record.blockedUntil;
      record.timestamps = [];
    }

    const windowStart = now - this.config.windowMs;
    record.timestamps = record.timestamps.filter(ts => ts > windowStart);

    if (record.timestamps.length >= this.config.maxRequestsPerWindow) {
      record.blockedUntil = now + this.config.blockDurationMs;
      return false;
    }

    record.timestamps.push(now);
    return true;
  }

  getRemainingRequests(ip: string): number {
    if (!ip) {
      return this.config.maxRequestsPerWindow;
    }

    const now = Date.now();
    const record = this.ipRecords.get(ip);

    if (!record) {
      return this.config.maxRequestsPerWindow;
    }

    if (record.blockedUntil && now < record.blockedUntil) {
      return 0;
    }

    const windowStart = now - this.config.windowMs;
    const recentRequests = record.timestamps.filter(ts => ts > windowStart).length;

    return Math.max(0, this.config.maxRequestsPerWindow - recentRequests);
  }

  getBlockedTimeRemaining(ip: string): number {
    if (!ip) {
      return 0;
    }

    const record = this.ipRecords.get(ip);
    if (!record || !record.blockedUntil) {
      return 0;
    }

    const now = Date.now();
    if (now >= record.blockedUntil) {
      return 0;
    }

    return Math.ceil((record.blockedUntil - now) / 1000);
  }

  resetIp(ip: string): void {
    this.ipRecords.delete(ip);
  }

  getStats() {
    const now = Date.now();
    const blockedIps: string[] = [];
    let totalTrackedIps = 0;

    for (const [ip, record] of this.ipRecords.entries()) {
      totalTrackedIps++;
      if (record.blockedUntil && now < record.blockedUntil) {
        blockedIps.push(ip);
      }
    }

    return {
      totalTrackedIps,
      blockedIps,
      blockedCount: blockedIps.length,
      config: this.config,
    };
  }

  private cleanup(): void {
    const now = Date.now();
    const expiredThreshold = now - this.config.windowMs - this.config.blockDurationMs;

    for (const [ip, record] of this.ipRecords.entries()) {
      const hasRecentActivity = record.timestamps.some(ts => ts > expiredThreshold);
      const isBlocked = record.blockedUntil && now < record.blockedUntil;

      if (!hasRecentActivity && !isBlocked) {
        this.ipRecords.delete(ip);
      }
    }
  }

  private startCleanup(): void {
    this.cleanupInterval = setInterval(() => {
      this.cleanup();
    }, 60 * 1000);

    if (this.cleanupInterval.unref) {
      this.cleanupInterval.unref();
    }
  }

  private getOrCreateRecord(ip: string): IpRecord {
    let record = this.ipRecords.get(ip);
    if (!record) {
      record = { timestamps: [] };
      this.ipRecords.set(ip, record);
    }
    return record;
  }

  destroy(): void {
    if (this.cleanupInterval) {
      clearInterval(this.cleanupInterval);
      this.cleanupInterval = undefined;
    }
  }
}
