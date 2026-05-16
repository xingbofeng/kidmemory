/**
 * In-Memory Agent Configuration Repository
 *
 * Implementation of AgentConfigRepository for testing purposes.
 * Stores configurations in memory with simulated persistence behavior.
 */

import { AgentConfig } from '../domain/agent-config.entity.ts';
import type { AgentConfigProps } from '../domain/agent-config.entity.ts';
import type { AgentConfigRepository } from '../ports/agent-config.ports.ts';

interface StoredConfig {
  config: AgentConfigProps;
  encryptedApiKey: string;
}

export class InMemoryAgentConfigRepository implements AgentConfigRepository {
  private configs = new Map<string, StoredConfig>();
  private nextId = 1;

  async findAll(): Promise<AgentConfig[]> {
    const activeConfigs = Array.from(this.configs.values())
      .filter(stored => stored.config.isActive)
      .map(stored => AgentConfig.fromPersistence(stored.config))
      .sort((a, b) => {
        // Sort by default first, then by creation date
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return b.createdAt.getTime() - a.createdAt.getTime();
      });

    return activeConfigs;
  }

  async findById(id: string): Promise<AgentConfig | null> {
    const stored = this.configs.get(id);
    if (!stored || !stored.config.isActive) {
      return null;
    }

    return AgentConfig.fromPersistence(stored.config);
  }

  async findDefault(): Promise<AgentConfig | null> {
    const defaultConfig = Array.from(this.configs.values())
      .find(stored => stored.config.isDefault && stored.config.isActive);

    if (!defaultConfig) {
      return null;
    }

    return AgentConfig.fromPersistence(defaultConfig.config);
  }

  async save(config: AgentConfig, encryptedApiKey: string): Promise<AgentConfig> {
    const props = config.toPlainObject();

    // Simulate database ID generation if needed
    if (!props.id || props.id.startsWith('temp_')) {
      props.id = `config_${this.nextId++}_${Date.now()}`;
    }

    const stored: StoredConfig = {
      config: props,
      encryptedApiKey
    };

    this.configs.set(props.id, stored);

    return AgentConfig.fromPersistence(props);
  }

  async update(config: AgentConfig, encryptedApiKey?: string): Promise<AgentConfig> {
    const props = config.toPlainObject();
    const existing = this.configs.get(props.id);

    if (!existing) {
      throw new Error('Configuration not found for update');
    }

    const stored: StoredConfig = {
      config: props,
      encryptedApiKey: encryptedApiKey || existing.encryptedApiKey
    };

    this.configs.set(props.id, stored);

    return AgentConfig.fromPersistence(props);
  }

  async saveMany(configs: AgentConfig[]): Promise<AgentConfig[]> {
    const results: AgentConfig[] = [];

    for (const config of configs) {
      const existing = this.configs.get(config.id);
      if (!existing) {
        throw new Error(`Configuration ${config.id} not found for batch update`);
      }

      const updated = await this.update(config);
      results.push(updated);
    }

    return results;
  }

  async getEncryptedApiKey(configId: string): Promise<string | null> {
    const stored = this.configs.get(configId);
    if (!stored || !stored.config.isActive) {
      return null;
    }

    return stored.encryptedApiKey;
  }

  async existsByName(name: string, excludeId?: string): Promise<boolean> {
    const existing = Array.from(this.configs.values())
      .find(stored =>
        stored.config.isActive &&
        stored.config.name === name &&
        (!excludeId || stored.config.id !== excludeId)
      );

    return !!existing;
  }

  // Test helpers
  clear(): void {
    this.configs.clear();
    this.nextId = 1;
  }

  getStoredConfigs(): StoredConfig[] {
    return Array.from(this.configs.values());
  }

  setConfig(config: AgentConfig, encryptedApiKey: string): void {
    const props = config.toPlainObject();
    this.configs.set(props.id, {
      config: props,
      encryptedApiKey
    });
  }
}
