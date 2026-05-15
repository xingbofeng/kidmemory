/**
 * Agent Configuration Repository Port
 *
 * Defines the contract for persisting and retrieving agent configurations.
 * This is a port in the hexagonal architecture - the interface that the domain
 * layer uses to interact with persistence without knowing the implementation details.
 */

import { AgentConfig } from '../domain/agent-config.entity.ts';

export const AGENT_CONFIG_REPOSITORY = Symbol("AGENT_CONFIG_REPOSITORY");
export const ENCRYPTION_PORT = Symbol("ENCRYPTION_PORT");
export const AGENT_TESTING_PORT = Symbol("AGENT_TESTING_PORT");
export const AUDIT_LOGGER_PORT = Symbol("AUDIT_LOGGER_PORT");

export interface AgentConfigRepository {
  /**
   * Find all active agent configurations
   */
  findAll(): Promise<AgentConfig[]>;

  /**
   * Find a specific agent configuration by ID
   */
  findById(id: string): Promise<AgentConfig | null>;

  /**
   * Find the current default agent configuration
   */
  findDefault(): Promise<AgentConfig | null>;

  /**
   * Save a new agent configuration
   */
  save(config: AgentConfig, encryptedApiKey: string): Promise<AgentConfig>;

  /**
   * Update an existing agent configuration
   */
  update(config: AgentConfig, encryptedApiKey?: string): Promise<AgentConfig>;

  /**
   * Save multiple configurations (for batch operations like setting default)
   */
  saveMany(configs: AgentConfig[]): Promise<AgentConfig[]>;

  /**
   * Get the encrypted API key for a configuration
   */
  getEncryptedApiKey(configId: string): Promise<string | null>;

  /**
   * Check if a configuration name already exists (for uniqueness validation)
   */
  existsByName(name: string, excludeId?: string): Promise<boolean>;
}

/**
 * Encryption Service Port
 *
 * Defines the contract for encrypting and decrypting sensitive data.
 */
export interface EncryptionPort {
  /**
   * Check if encryption is available and properly configured
   */
  isEncryptionAvailable(): boolean;

  /**
   * Encrypt data for storage
   */
  encryptForStorage(plaintext: string): string;

  /**
   * Decrypt data from storage
   */
  decryptFromStorage(encrypted: string): string;
}

/**
 * Agent Testing Service Port
 *
 * Defines the contract for testing agent configurations against their respective APIs.
 */
export interface AgentTestingPort {
  /**
   * Test an agent configuration by making a real API call
   */
  testConfiguration(
    config: AgentConfig,
    apiKey: string,
    testPrompt: string
  ): Promise<{
    success: boolean;
    responseTime: number;
    modelUsed?: string;
    tokensUsed?: number;
    errorMessage?: string;
  }>;
}

/**
 * Audit Logger Port
 *
 * Defines the contract for logging configuration changes for audit purposes.
 */
export interface AuditLoggerPort {
  /**
   * Log a configuration change event
   */
  logConfigChange(
    configId: string,
    action: 'CREATE' | 'UPDATE' | 'DELETE' | 'SET_DEFAULT' | 'TEST',
    oldValues: any,
    newValues: any,
    userId?: string
  ): Promise<void>;
}
