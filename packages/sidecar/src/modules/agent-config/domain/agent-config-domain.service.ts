/**
 * Agent Configuration Domain Service
 *
 * Contains business logic that doesn't naturally fit within a single entity.
 * Orchestrates operations involving multiple entities or complex business rules.
 */

import { AgentConfig } from './agent-config.entity.ts';
import type { CreateAgentConfigProps, UpdateAgentConfigProps } from './agent-config.entity.ts';

export interface TestConfigInput {
  configId: string;
  testPrompt?: string;
}

export interface TestConfigResult {
  success: boolean;
  responseTime?: number;
  errorMessage?: string;
  modelUsed?: string;
  tokensUsed?: number;
}

export class AgentConfigDomainService {
  /**
   * Validates that a new configuration can be created with the given properties
   */
  validateCreateRequest(props: CreateAgentConfigProps): void {
    if (!props.name || props.name.trim().length === 0) {
      throw new Error('Name is required');
    }

    if (!props.provider) {
      throw new Error('Provider is required');
    }

    if (!['openai', 'anthropic', 'custom'].includes(props.provider)) {
      throw new Error('Provider must be one of: openai, anthropic, custom');
    }

    if (!props.model || props.model.trim().length === 0) {
      throw new Error('Model is required');
    }

    if (!props.apiKey || props.apiKey.trim().length === 0) {
      throw new Error('API key is required');
    }

    if (props.temperature !== undefined && (props.temperature < 0 || props.temperature > 2)) {
      throw new Error('Temperature must be between 0 and 2');
    }

    if (props.maxTokens !== undefined && props.maxTokens <= 0) {
      throw new Error('Max tokens must be greater than 0');
    }

    if (props.provider === 'custom' && (!props.baseUrl || props.baseUrl.trim().length === 0)) {
      throw new Error('Base URL is required for custom provider');
    }
  }

  /**
   * Validates that an existing configuration can be updated with the given properties
   */
  validateUpdateRequest(props: UpdateAgentConfigProps): void {
    if (props.name !== undefined && props.name.trim().length === 0) {
      throw new Error('Name cannot be empty');
    }

    if (props.provider !== undefined && !['openai', 'anthropic', 'custom'].includes(props.provider)) {
      throw new Error('Provider must be one of: openai, anthropic, custom');
    }

    if (props.model !== undefined && props.model.trim().length === 0) {
      throw new Error('Model cannot be empty');
    }

    if (props.apiKey !== undefined && props.apiKey.trim().length === 0) {
      throw new Error('API key cannot be empty');
    }

    if (props.temperature !== undefined && (props.temperature < 0 || props.temperature > 2)) {
      throw new Error('Temperature must be between 0 and 2');
    }

    if (props.maxTokens !== undefined && props.maxTokens <= 0) {
      throw new Error('Max tokens must be greater than 0');
    }

    if (props.provider === 'custom' && props.baseUrl !== undefined && props.baseUrl.trim().length === 0) {
      throw new Error('Base URL cannot be empty for custom provider');
    }
  }

  /**
   * Determines if a configuration can be safely deleted
   */
  canDeleteConfig(config: AgentConfig): { canDelete: boolean; reason?: string } {
    if (config.isDefault) {
      return {
        canDelete: false,
        reason: 'Cannot delete the default agent configuration. Set another configuration as default first.'
      };
    }

    return { canDelete: true };
  }

  /**
   * Prepares configurations for setting a new default
   * Returns the list of configs that need to be updated
   */
  prepareDefaultConfigChange(
    currentConfigs: AgentConfig[],
    newDefaultId: string
  ): { configsToUpdate: AgentConfig[]; newDefault: AgentConfig } {
    const newDefault = currentConfigs.find(c => c.id === newDefaultId);
    if (!newDefault) {
      throw new Error('Agent configuration not found');
    }

    if (newDefault.isDefault) {
      return { configsToUpdate: [], newDefault };
    }

    const configsToUpdate: AgentConfig[] = [];

    for (const config of currentConfigs) {
      if (config.isDefault && config.id !== newDefaultId) {
        configsToUpdate.push(config.markAsNonDefault());
      }
    }

    const updatedNewDefault = newDefault.markAsDefault();
    configsToUpdate.push(updatedNewDefault);

    return { configsToUpdate, newDefault: updatedNewDefault };
  }

  /**
   * Validates test configuration request
   */
  validateTestRequest(request: TestConfigInput): void {
    if (!request.configId || request.configId.trim().length === 0) {
      throw new Error('Config ID is required for testing');
    }
  }

  /**
   * Creates a default test prompt if none provided
   */
  getTestPrompt(customPrompt?: string): string {
    return customPrompt || 'Hello, this is a test message. Please respond with "Test successful".';
  }
}
