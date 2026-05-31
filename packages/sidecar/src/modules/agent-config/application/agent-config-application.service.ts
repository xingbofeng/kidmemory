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

  async listConfigs(): Promise<AgentConfig[]> {
    return await this.repository.findAll();
  }

  async getConfig(id: string): Promise<AgentConfig | null> {
    return await this.repository.findById(id);
  }

  async getDefaultConfig(): Promise<AgentConfig | null> {
    return await this.repository.findDefault();
  }

  async getEncryptedApiKey(configId: string): Promise<string | null> {
    return await this.repository.getEncryptedApiKey(configId);
  }

  async createConfig(input: CreateAgentConfigProps): Promise<AgentConfig> {
    this.domainService.validateCreateRequest(input);

    if (!this.encryption.isEncryptionAvailable()) {
      throw new Error('Encryption not available. Cannot create agent configuration.');
    }

    const nameExists = await this.repository.existsByName(input.name);
    if (nameExists) {
      throw new Error('A configuration with this name already exists');
    }

    const config = AgentConfig.create(input);

    const encryptedApiKey = this.encryption.encryptForStorage(input.apiKey);

    if (input.isDefault) {
      const currentConfigs = await this.repository.findAll();
      const configsToUpdate = currentConfigs
        .filter((currentConfig) => currentConfig.isDefault)
        .map((currentConfig) => currentConfig.markAsNonDefault());

      if (configsToUpdate.length > 0) {
        await this.repository.saveMany(configsToUpdate);
      }
    }

    const savedConfig = await this.repository.save(config, encryptedApiKey);

    await this.auditLogger.logConfigChange(
      savedConfig.id,
      'CREATE',
      {},
      savedConfig.toPlainObject()
    );

    return savedConfig;
  }

  async updateConfig(id: string, input: UpdateAgentConfigProps): Promise<AgentConfig> {
    this.domainService.validateUpdateRequest(input);

    const currentConfig = await this.repository.findById(id);
    if (!currentConfig) {
      throw new Error('Agent configuration not found');
    }

    if (input.name && input.name !== currentConfig.name) {
      const nameExists = await this.repository.existsByName(input.name, id);
      if (nameExists) {
        throw new Error('A configuration with this name already exists');
      }
    }

    let encryptedApiKey: string | undefined;
    if (input.apiKey) {
      if (!this.encryption.isEncryptionAvailable()) {
        throw new Error('Encryption not available. Cannot update API key.');
      }
      encryptedApiKey = this.encryption.encryptForStorage(input.apiKey);
    }

    const updatedConfig = currentConfig.update(input);

    const savedConfig = await this.repository.update(updatedConfig, encryptedApiKey);

    await this.auditLogger.logConfigChange(
      savedConfig.id,
      'UPDATE',
      currentConfig.toPlainObject(),
      savedConfig.toPlainObject()
    );

    return savedConfig;
  }

  async deleteConfig(id: string): Promise<void> {
    const config = await this.repository.findById(id);
    if (!config) {
      throw new Error('Agent configuration not found');
    }

    const { canDelete, reason } = this.domainService.canDeleteConfig(config);
    if (!canDelete) {
      throw new Error(reason!);
    }

    const deactivatedConfig = config.deactivate();
    await this.repository.update(deactivatedConfig);

    await this.auditLogger.logConfigChange(
      config.id,
      'DELETE',
      config.toPlainObject(),
      {}
    );
  }

  async setDefaultConfig(id: string): Promise<void> {
    const currentConfigs = await this.repository.findAll();
    const { configsToUpdate, newDefault } = this.domainService.prepareDefaultConfigChange(
      currentConfigs,
      id
    );

    if (configsToUpdate.length === 0) {
      return;
    }

    await this.repository.saveMany(configsToUpdate);

    await this.auditLogger.logConfigChange(
      newDefault.id,
      'SET_DEFAULT',
      { isDefault: false },
      { isDefault: true }
    );
  }

  async testConfig(request: TestConfigInput): Promise<TestConfigResult> {
    this.domainService.validateTestRequest(request);

    const config = await this.repository.findById(request.configId);
    if (!config) {
      throw new Error('Agent configuration not found');
    }

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

    const testPrompt = this.domainService.getTestPrompt(request.testPrompt);

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

      const updatedConfig = config.updateTestResult('failed');
      await this.repository.update(updatedConfig);
    }

    await this.auditLogger.logConfigChange(
      request.configId,
      'TEST',
      {},
      { testResult: testResult.success ? 'success' : 'failed', responseTime: testResult.responseTime }
    );

    return testResult;
  }

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
