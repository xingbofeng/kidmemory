/**
 * Agent Configuration Controller
 *
 * HTTP API controller for agent configuration management.
 * Handles request validation, error mapping, and response formatting.
 */

import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpException,
  HttpStatus,
  Inject,
  Param,
  Post,
  Put,
} from "@nestjs/common";

import { AgentConfigApplicationService } from '../application/agent-config-application.service.ts';
import { AgentConfig } from '../domain/agent-config.entity.ts';
import {
  CreateAgentConfigDtoSchema,
  UpdateAgentConfigDtoSchema,
  TestAgentConfigDtoSchema
} from './agent-config.dto.ts';
import type {
  AgentConfigDto,
  CreateAgentConfigDto,
  UpdateAgentConfigDto,
  TestAgentConfigDto,
  TestAgentConfigResultDto,
  SuccessResponseDto,
} from './agent-config.dto.ts';
import { parseDto } from '../../../infrastructure/validation/parse-dto.ts';
import {
  ApplicationError,
  NotFoundError,
} from '../../../common/errors/application-errors.ts';

export class AgentConfigController {
  private readonly applicationService: AgentConfigApplicationService;

  constructor(applicationService: AgentConfigApplicationService) {
    this.applicationService = applicationService;
  }

  async listConfigs(): Promise<AgentConfigDto[]> {
    try {
      const configs = await this.applicationService.listConfigs();
      return configs.map(config => this.toDto(config));
    } catch (error) {
      this.handleError(error);
    }
  }

  async getConfig(id: string): Promise<AgentConfigDto> {
    try {
      const config = await this.applicationService.getConfig(id);
      if (!config) {
        throw new NotFoundError('Agent configuration', id);
      }
      return this.toDto(config);
    } catch (error) {
      this.handleError(error);
    }
  }

  async getDefaultConfig(): Promise<AgentConfigDto> {
    try {
      const config = await this.applicationService.getDefaultConfig();
      if (!config) {
        throw new NotFoundError('Default agent configuration');
      }
      return this.toDto(config);
    } catch (error) {
      this.handleError(error);
    }
  }

  async createConfig(request: unknown): Promise<AgentConfigDto> {
    try {
      // Validate request using Zod
      const validatedRequest = parseDto(CreateAgentConfigDtoSchema, request, "agent-config");

      const config = await this.applicationService.createConfig(validatedRequest);
      return this.toDto(config);
    } catch (error) {
      this.handleError(error);
    }
  }

  async updateConfig(id: string, request: unknown): Promise<AgentConfigDto> {
    try {
      // Validate request using Zod
      const validatedRequest = parseDto(UpdateAgentConfigDtoSchema, request, "agent-config");

      const config = await this.applicationService.updateConfig(id, validatedRequest);
      return this.toDto(config);
    } catch (error) {
      this.handleError(error);
    }
  }

  async deleteConfig(id: string): Promise<SuccessResponseDto> {
    try {
      await this.applicationService.deleteConfig(id);
      return { success: true };
    } catch (error) {
      this.handleError(error);
    }
  }

  async setDefaultConfig(id: string): Promise<SuccessResponseDto> {
    try {
      await this.applicationService.setDefaultConfig(id);
      return { success: true };
    } catch (error) {
      this.handleError(error);
    }
  }

  async testConfig(id: string, request: unknown): Promise<TestAgentConfigResultDto> {
    try {
      const validatedRequest = parseDto(TestAgentConfigDtoSchema, request, "agent-config/test");

      const result = await this.applicationService.testConfig({
        configId: id,
        testPrompt: validatedRequest.testPrompt
      });

      return result;
    } catch (error) {
      this.handleError(error);
    }
  }

  private toDto(config: AgentConfig): AgentConfigDto {
    return {
      id: config.id,
      name: config.name,
      description: config.description,
      provider: config.provider,
      model: config.model,
      baseUrl: config.baseUrl,
      apiKeyConfigured: config.apiKeyConfigured,
      temperature: config.temperature,
      maxTokens: config.maxTokens,
      systemPrompt: config.systemPrompt,
      toolsEnabled: config.toolsEnabled,
      workspaceConfig: config.workspaceConfig,
      isDefault: config.isDefault,
      isActive: config.isActive,
      lastTestedAt: config.lastTestedAt?.toISOString(),
      testResult: config.testResult,
      createdAt: config.createdAt.toISOString(),
      updatedAt: config.updatedAt.toISOString()
    };
  }

  private handleError(error: unknown): never {
    if (error instanceof ApplicationError) {
      throw new HttpException(
        { code: error.code, message: error.message },
        error.statusCode
      );
    }

    if (error instanceof HttpException) {
      throw error;
    }

    const message = error instanceof Error ? error.message : "An unexpected error occurred";

    // Map common error patterns to appropriate HTTP status codes
    if (message.includes('not found') || message.includes('Agent configuration not found')) {
      throw new HttpException(
        { code: 'CONFIG_NOT_FOUND', message },
        HttpStatus.NOT_FOUND
      );
    }

    if (message.includes('Encryption not available')) {
      throw new HttpException(
        { code: 'ENCRYPTION_UNAVAILABLE', message },
        HttpStatus.SERVICE_UNAVAILABLE
      );
    }

    if (message.includes('Cannot delete the default')) {
      throw new HttpException(
        { code: 'CANNOT_DELETE_DEFAULT', message },
        HttpStatus.BAD_REQUEST
      );
    }

    if (message.includes('API key not available')) {
      throw new HttpException(
        { code: 'API_KEY_UNAVAILABLE', message },
        HttpStatus.BAD_REQUEST
      );
    }

    if (message.includes('Failed to decrypt')) {
      throw new HttpException(
        { code: 'DECRYPTION_ERROR', message },
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }

    if (message.includes('duplicate') || message.includes('already exists')) {
      throw new HttpException(
        { code: 'DUPLICATE_CONFIG', message },
        HttpStatus.CONFLICT
      );
    }

    if (message.includes('constraint') || message.includes('validation')) {
      throw new HttpException(
        { code: 'VALIDATION_ERROR', message },
        HttpStatus.BAD_REQUEST
      );
    }

    throw new HttpException(
      { code: 'INTERNAL_ERROR', message },
      HttpStatus.INTERNAL_SERVER_ERROR
    );
  }
}

// ---- Manual NestJS decorator registration (avoiding @ syntax) ----

Inject(AgentConfigApplicationService)(AgentConfigController, undefined, 0);
Controller("api/config")(AgentConfigController);

const proto = AgentConfigController.prototype;
const desc = (m: string) => Object.getOwnPropertyDescriptor(proto, m)!;

// GET /api/config/agent-configs
Get("agent-configs")(proto, "listConfigs", desc("listConfigs"));

// GET /api/config/agent-configs/default (must be before :id route)
Get("agent-configs/default")(proto, "getDefaultConfig", desc("getDefaultConfig"));

// GET /api/config/agent-configs/:id
Get("agent-configs/:id")(proto, "getConfig", desc("getConfig"));
Param("id")(proto, "getConfig", 0);

// POST /api/config/agent-configs
Post("agent-configs")(proto, "createConfig", desc("createConfig"));
HttpCode(HttpStatus.CREATED)(proto, "createConfig", desc("createConfig"));
Body()(proto, "createConfig", 0);

// PUT /api/config/agent-configs/:id
Put("agent-configs/:id")(proto, "updateConfig", desc("updateConfig"));
Param("id")(proto, "updateConfig", 0);
Body()(proto, "updateConfig", 1);

// DELETE /api/config/agent-configs/:id
Delete("agent-configs/:id")(proto, "deleteConfig", desc("deleteConfig"));
Param("id")(proto, "deleteConfig", 0);

// POST /api/config/agent-configs/:id/set-default
Post("agent-configs/:id/set-default")(proto, "setDefaultConfig", desc("setDefaultConfig"));
Param("id")(proto, "setDefaultConfig", 0);

// POST /api/config/agent-configs/:id/test
Post("agent-configs/:id/test")(proto, "testConfig", desc("testConfig"));
Param("id")(proto, "testConfig", 0);
Body()(proto, "testConfig", 1);
