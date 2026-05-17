/**
 * Agent Configuration Application Service
 *
 * Orchestrates use cases and coordinates between domain services, repositories, and external services.
 * This is the application layer that implements the business use cases.
 */

import { AgentConfig } from '../domain/agent-config.entity.ts';
import { AgentConfigDomainService } from '../domain/agent-config-domain.service.ts';
import type { CreateAgentConfigProps, UpdateAgentConfigProps } from '../domain/agent-config.entity.ts';
import type { TestConfigInput, TestConfigResult } from '../domain/agent-config-domain.service.ts';
import type {
  AgentConfigRepository,
  EncryptionPort,
  AgentTestingPort,
  AuditLoggerPort
} from '../ports/agent-config.ports.ts';

export class AgentConfigApplicationService {
  private readonly repository: AgentConfigRepository;
  private readonly encryption: EncryptionPort;
  private readonly agentTesting: AgentTestingPort;
  private readonly auditLogger: AuditLoggerPort;
  private readonly domainService: AgentConfigDomainService;

  constructor(
    repository: AgentConfigRepository,
    encryption: EncryptionPort,
    agentTesting: AgentTestingPort,
    auditLogger: AuditLoggerPort,
    domainService: AgentConfigDomainService
  ) {
    this.repository = repository;
    this.encryption = encryption;
    this.agentTesting = agentTesting;
    this.auditLogger = auditLogger;
    this.domainService = domainService;
  }

  /**
   * List all active agent configurations
   */
  async listConfigs(): Promise<AgentConfig[]> {
    return await this.repository.findAll();
  }

  /**
   * Get a specific agent configuration by ID
   */
  async getConfig(id: string): Promise<AgentConfig | null> {
    return await this.repository.findById(id);
  }

  /**
   * Get the current default agent configuration
   */
  async getDefaultConfig(): Promise<AgentConfig | null> {
    return await this.repository.findDefault();
  }

  /**
   * Create a new agent configuration
   */
  async createConfig(input: CreateAgentConfigProps): Promise<AgentConfig> {
    // Validate business rules
    this.domainService.validateCreateRequest(input);

    // Check encryption availability
    if (!this.encryption.isEncryptionAvailable()) {
      throw new Error('Encryption not available. Cannot create agent configuration.');
    }

    // Check for duplicate names
    const nameExists = await this.repository.existsByName(input.name);
    if (nameExists) {
      throw new Error('A configuration with this name already exists');
    }

    // Create domain entity
    const config = AgentConfig.create(input);

    // Encrypt API key
    const encryptedApiKey = this.encryption.encryptForStorage(input.apiKey);

    // Handle default configuration logic
    if (input.isDefault) {
      const currentConfigs = await this.repository.findAll();
      const configsToUpdate = currentConfigs
        .filter((currentConfig) => currentConfig.isDefault)
        .map((currentConfig) => currentConfig.markAsNonDefault());

      // Clear existing defaults
      if (configsToUpdate.length > 0) {
        await this.repository.saveMany(configsToUpdate);
      }
    }

    // Save the new configuration
    const savedConfig = await this.repository.save(config, encryptedApiKey);

    // Log audit event
    await this.auditLogger.logConfigChange(
      savedConfig.id,
      'CREATE',
      {},
      savedConfig.toPlainObject()
    );

    return savedConfig;
  }

  /**
   * Update an existing agent configuration
   */
  async updateConfig(id: string, input: UpdateAgentConfigProps): Promise<AgentConfig> {
    // Validate business rules
    this.domainService.validateUpdateRequest(input);

    // Get current configuration
    const currentConfig = await this.repository.findById(id);
    if (!currentConfig) {
      throw new Error('Agent configuration not found');
    }

    // Check for duplicate names (excluding current config)
    if (input.name && input.name !== currentConfig.name) {
      const nameExists = await this.repository.existsByName(input.name, id);
      if (nameExists) {
        throw new Error('A configuration with this name already exists');
      }
    }

    // Handle API key encryption if provided
    let encryptedApiKey: string | undefined;
    if (input.apiKey) {
      if (!this.encryption.isEncryptionAvailable()) {
        throw new Error('Encryption not available. Cannot update API key.');
      }
      encryptedApiKey = this.encryption.encryptForStorage(input.apiKey);
    }

    // Update domain entity
    const updatedConfig = currentConfig.update(input);

    // Save updated configuration
    const savedConfig = await this.repository.update(updatedConfig, encryptedApiKey);

    // Log audit event
    await this.auditLogger.logConfigChange(
      savedConfig.id,
      'UPDATE',
      currentConfig.toPlainObject(),
      savedConfig.toPlainObject()
    );

    return savedConfig;
  }

  /**
   * Delete an agent configuration
   */
  async deleteConfig(id: string): Promise<void> {
    const config = await this.repository.findById(id);
    if (!config) {
      throw new Error('Agent configuration not found');
    }

    // Check if config can be deleted
    const { canDelete, reason } = this.domainService.canDeleteConfig(config);
    if (!canDelete) {
      throw new Error(reason!);
    }

    // Soft delete by deactivating
    const deactivatedConfig = config.deactivate();
    await this.repository.update(deactivatedConfig);

    // Log audit event
    await this.auditLogger.logConfigChange(
      config.id,
      'DELETE',
      config.toPlainObject(),
      {}
    );
  }

  /**
   * Set a configuration as the default
   */
  async setDefaultConfig(id: string): Promise<void> {
    const currentConfigs = await this.repository.findAll();
    const { configsToUpdate, newDefault } = this.domainService.prepareDefaultConfigChange(
      currentConfigs,
      id
    );

    if (configsToUpdate.length === 0) {
      return; // Already default
    }

    // Save all updated configurations
    await this.repository.saveMany(configsToUpdate);

    // Log audit event
    await this.auditLogger.logConfigChange(
      newDefault.id,
      'SET_DEFAULT',
      { isDefault: false },
      { isDefault: true }
    );
  }

  /**
   * Test an agent configuration
   */
  async testConfig(request: TestConfigInput): Promise<TestConfigResult> {
    // Validate request
    this.domainService.validateTestRequest(request);

    // Get configuration
    const config = await this.repository.findById(request.configId);
    if (!config) {
      throw new Error('Agent configuration not found');
    }

    // Get decrypted API key
    const encryptedApiKey = await this.repository.getEncryptedApiKey(request.configId);
    if (!encryptedApiKey) {
      throw new Error('API key not available for testing');
    }

    if (!this.encryption.isEncryptionAvailable()) {
      throw new Error('Encryption not available. Cannot decrypt API key.');
    }

    let apiKey: string;
    try {
      apiKey = this.encryption.decryptFromStorage(encryptedApiKey);
    } catch (error) {
      throw new Error(`Failed to decrypt API key: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }

    // Prepare test prompt
    const testPrompt = this.domainService.getTestPrompt(request.testPrompt);

    // Perform the test
    const startTime = Date.now();
    let testResult: TestConfigResult;

    try {
      const result = await this.agentTesting.testConfiguration(config, apiKey, testPrompt);

      testResult = {
        success: result.success,
        responseTime: result.responseTime,
        modelUsed: result.modelUsed,
        tokensUsed: result.tokensUsed,
        errorMessage: result.errorMessage
      };

      // Update config with test result
      const updatedConfig = config.updateTestResult('success');
      await this.repository.update(updatedConfig);

    } catch (error) {
      const responseTime = Date.now() - startTime;
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';

      testResult = {
        success: false,
        responseTime,
        errorMessage
      };

      // Update config with failed test result
      const updatedConfig = config.updateTestResult('failed');
      await this.repository.update(updatedConfig);
    }

    // Log audit event
    await this.auditLogger.logConfigChange(
      request.configId,
      'TEST',
      {},
      { testResult: testResult.success ? 'success' : 'failed', responseTime: testResult.responseTime }
    );

    return testResult;
  }

  /**
   * Get decrypted API key for authorized operations
   */
  async getDecryptedApiKey(configId: string): Promise<string | null> {
    if (!this.encryption.isEncryptionAvailable()) {
      throw new Error('Encryption not available. Cannot decrypt API key.');
    }

    const encryptedApiKey = await this.repository.getEncryptedApiKey(configId);
    if (!encryptedApiKey) {
      return null;
    }

    try {
      return this.encryption.decryptFromStorage(encryptedApiKey);
    } catch (error) {
      throw new Error(`Failed to decrypt API key: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }
}
