/**
 * Share IP Rate Limiter
 * 
 * Implements IP-based rate limiting for share token access
 * to prevent abuse and protect shared content.
 */

export interface ShareIpLimiterConfig {
  /**
   * Maximum requests per IP per window
   */
  maxRequestsPerWindow: number;
  
  /**
   * Time window in milliseconds
   */
  windowMs: number;
  
  /**
   * How long to block an IP after exceeding limit (milliseconds)
   */
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
      maxRequestsPerWindow: config?.maxRequestsPerWindow ?? 100, // 100 requests per window
      windowMs: config?.windowMs ?? 60 * 1000, // 1 minute window
      blockDurationMs: config?.blockDurationMs ?? 5 * 60 * 1000, // 5 minutes block
    };

    // Start cleanup interval to prevent memory leaks
    this.startCleanup();
  }

  /**
   * Check if an IP is allowed to access
   * Returns true if allowed, false if rate limited
   */
  checkLimit(ip: string): boolean {
    if (!ip) {
      // If no IP provided, allow (for testing or localhost)
      return true;
    }

    const now = Date.now();
    const record = this.getOrCreateRecord(ip);

    // Check if IP is currently blocked
    if (record.blockedUntil && now < record.blockedUntil) {
      return false;
    }

    // Remove blocked status if expired
    if (record.blockedUntil && now >= record.blockedUntil) {
      delete record.blockedUntil;
      record.timestamps = [];
    }

    // Remove timestamps outside the window
    const windowStart = now - this.config.windowMs;
    record.timestamps = record.timestamps.filter(ts => ts > windowStart);

    // Check if limit exceeded
    if (record.timestamps.length >= this.config.maxRequestsPerWindow) {
      // Block the IP
      record.blockedUntil = now + this.config.blockDurationMs;
      return false;
    }

    // Record this access
    record.timestamps.push(now);
    return true;
  }

  /**
   * Get remaining requests for an IP
   */
  getRemainingRequests(ip: string): number {
    if (!ip) {
      return this.config.maxRequestsPerWindow;
    }

    const now = Date.now();
    const record = this.ipRecords.get(ip);

    if (!record) {
      return this.config.maxRequestsPerWindow;
    }

    // If blocked, return 0
    if (record.blockedUntil && now < record.blockedUntil) {
      return 0;
    }

    // Count requests in current window
    const windowStart = now - this.config.windowMs;
    const recentRequests = record.timestamps.filter(ts => ts > windowStart).length;

    return Math.max(0, this.config.maxRequestsPerWindow - recentRequests);
  }

  /**
   * Get time until IP is unblocked (in seconds)
   * Returns 0 if not blocked
   */
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

  /**
   * Reset limits for an IP (for testing or admin purposes)
   */
  resetIp(ip: string): void {
    this.ipRecords.delete(ip);
  }

  /**
   * Get statistics
   */
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

  /**
   * Cleanup old records to prevent memory leaks
   */
  private cleanup(): void {
    const now = Date.now();
    const expiredThreshold = now - this.config.windowMs - this.config.blockDurationMs;

    for (const [ip, record] of this.ipRecords.entries()) {
      // Remove if no recent activity and not blocked
      const hasRecentActivity = record.timestamps.some(ts => ts > expiredThreshold);
      const isBlocked = record.blockedUntil && now < record.blockedUntil;

      if (!hasRecentActivity && !isBlocked) {
        this.ipRecords.delete(ip);
      }
    }
  }

  private startCleanup(): void {
    // Run cleanup every minute
    this.cleanupInterval = setInterval(() => {
      this.cleanup();
    }, 60 * 1000);

    // Ensure cleanup runs on process exit
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

  /**
   * Stop cleanup interval (for testing)
   */
  destroy(): void {
    if (this.cleanupInterval) {
      clearInterval(this.cleanupInterval);
      this.cleanupInterval = undefined;
    }
  }
}
