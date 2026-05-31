/**
 * In-Memory Audit Logger
 *
 * Implementation of AuditLoggerPort for testing purposes.
 * Stores audit logs in memory for verification during tests.
 */

import type { AuditLoggerPort } from '../ports/agent-config.ports.ts';

export interface AuditLogEntry {
  id: string;
  configId: string;
  action: 'CREATE' | 'UPDATE' | 'DELETE' | 'SET_DEFAULT' | 'TEST';
  oldValues: unknown;
  newValues: unknown;
  userId?: string;
  timestamp: Date;
}

export class InMemoryAuditLogger implements AuditLoggerPort {
  private logs: AuditLogEntry[] = [];
  private nextId = 1;

  async logConfigChange(
    configId: string,
    action: 'CREATE' | 'UPDATE' | 'DELETE' | 'SET_DEFAULT' | 'TEST',
    oldValues: unknown,
    newValues: unknown,
    userId?: string
  ): Promise<void> {
    const entry: AuditLogEntry = {
      id: `audit_${this.nextId++}`,
      configId,
      action,
      oldValues: this.deepClone(oldValues),
      newValues: this.deepClone(newValues),
      userId: userId || 'system',
      timestamp: new Date()
    };

    this.logs.push(entry);
  }

  // Test helpers
  getLogs(): AuditLogEntry[] {
    return [...this.logs];
  }

  getLogsForConfig(configId: string): AuditLogEntry[] {
    return this.logs.filter(log => log.configId === configId);
  }

  getLogsByAction(action: AuditLogEntry['action']): AuditLogEntry[] {
    return this.logs.filter(log => log.action === action);
  }

  clear(): void {
    this.logs = [];
    this.nextId = 1;
  }

  private deepClone(obj: unknown): unknown {
    if (obj === null || typeof obj !== 'object') {
      return obj;
    }

    if (obj instanceof Date) {
      return new Date(obj.getTime());
    }

    if (Array.isArray(obj)) {
      return obj.map(item => this.deepClone(item));
    }

    const cloned: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(obj)) {
      cloned[key] = this.deepClone(value);
    }

    return cloned;
  }
}
