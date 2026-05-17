/**
 * Agent Configuration Module Tests
 *
 * Comprehensive tests for the Agent Configuration module using Node.js test runner.
 * Tests the complete flow from domain entities to application services.
 */

import { strict as assert } from "node:assert";
import { test, describe, beforeEach } from "node:test";
import { BadRequestException } from "@nestjs/common";
import { z } from "zod";

// Domain
import { AgentConfig } from "../../../../src/modules/agent-config/domain/agent-config.entity.ts";
import type { CreateAgentConfigProps } from "../../../../src/modules/agent-config/domain/agent-config.entity.ts";
import { AgentConfigDomainService } from "../../../../src/modules/agent-config/domain/agent-config-domain.service.ts";

// Application
import { AgentConfigApplicationService } from "../../../../src/modules/agent-config/application/agent-config-application.service.ts";

// Adapters
import { InMemoryAgentConfigRepository } from "../../../../src/modules/agent-config/adapters/in-memory-agent-config.repository.ts";
import { InMemoryAuditLogger } from "../../../../src/modules/agent-config/adapters/in-memory-audit-logger.ts";
import type { AgentConfig as AgentConfigEntity } from "../../../../src/modules/agent-config/domain/agent-config.entity.ts";
import type { AgentTestingPort } from "../../../../src/modules/agent-config/ports/agent-config.ports.ts";

// Validation
import { parseDto } from "../../../../src/infrastructure/validation/parse-dto.ts";

// Mock encryption service for testing
class MockEncryptionService {
  private available = true;
  private encryptionKey = "test_key_32_bytes_long_for_testing";

  isEncryptionAvailable(): boolean {
    return this.available;
  }

  encryptForStorage(plaintext: string): string {
    if (!this.available) {
      throw new Error('Encryption not available');
    }
    // Simple mock encryption - just base64 encode with prefix
    return JSON.stringify({
      encrypted: Buffer.from(plaintext).toString('base64'),
      iv: 'mock_iv',
      tag: 'mock_tag'
    });
  }

  decryptFromStorage(encrypted: string): string {
    if (!this.available) {
      throw new Error('Encryption not available');
    }
    try {
      const parsed = JSON.parse(encrypted);
      return Buffer.from(parsed.encrypted, 'base64').toString();
    } catch (error) {
      throw new Error('Failed to decrypt');
    }
  }

  setAvailable(available: boolean): void {
    this.available = available;
  }
}

class MockAgentTestingService implements AgentTestingPort {
  private shouldFail = false;
  private customError?: string;

  async testConfiguration(config: AgentConfigEntity, _apiKey: string, testPrompt: string) {
    if (this.shouldFail) {
      return {
        success: false,
        responseTime: 1,
        errorMessage: this.customError || "Simulated API failure",
      };
    }
    return {
      success: true,
      responseTime: 1,
      modelUsed: config.model,
      tokensUsed: Math.max(1, Math.ceil(testPrompt.length / 4)),
    };
  }

  setShouldFail(shouldFail: boolean, errorMessage?: string): void {
    this.shouldFail = shouldFail;
    this.customError = errorMessage;
  }
}

describe("AgentConfig Domain Entity", () => {
  test("should create valid agent config", () => {
    const props: CreateAgentConfigProps = {
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    };

    const config = AgentConfig.create(props);

    assert.equal(config.name, "Test Config");
    assert.equal(config.provider, "openai");
    assert.equal(config.model, "gpt-4");
    assert.equal(config.temperature, 0.7); // default
    assert.equal(config.maxTokens, 4000); // default
    assert.equal(config.isActive, true);
    assert.equal(config.isDefault, false);
    assert(config.id.startsWith("config_"));
  });

  test("should validate required fields", () => {
    assert.throws(() => {
      AgentConfig.create({
        name: "",
        provider: "openai",
        model: "gpt-4",
        apiKey: "sk-test123"
      });
    }, /Agent config name is required/);

    assert.throws(() => {
      AgentConfig.create({
        name: "Test",
        provider: "invalid" as any,
        model: "gpt-4",
        apiKey: "sk-test123"
      });
    }, /Agent config provider must be one of/);
  });

  test("should validate custom provider requires baseUrl", () => {
    assert.throws(() => {
      AgentConfig.create({
        name: "Test",
        provider: "custom",
        model: "custom-model",
        apiKey: "sk-test123"
      });
    }, /Base URL is required for custom provider/);
  });

  test("should update config properties", () => {
    const config = AgentConfig.create({
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    });

    const updated = config.update({
      name: "Updated Config",
      temperature: 0.5
    });

    assert.equal(updated.name, "Updated Config");
    assert.equal(updated.temperature, 0.5);
    assert.equal(updated.model, "gpt-4"); // unchanged
    assert(updated.updatedAt > config.updatedAt);
  });

  test("should handle default config operations", () => {
    const config = AgentConfig.create({
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    });

    assert.equal(config.isDefault, false);
    assert.equal(config.canBeDeleted(), true);

    const defaultConfig = config.markAsDefault();
    assert.equal(defaultConfig.isDefault, true);
    assert.equal(defaultConfig.canBeDeleted(), false);

    const nonDefault = defaultConfig.markAsNonDefault();
    assert.equal(nonDefault.isDefault, false);
    assert.equal(nonDefault.canBeDeleted(), true);
  });
});

describe("AgentConfigDomainService", () => {
  let domainService: AgentConfigDomainService;

  beforeEach(() => {
    domainService = new AgentConfigDomainService();
  });

  test("should validate create request", () => {
    const validProps: CreateAgentConfigProps = {
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    };

    // Should not throw
    domainService.validateCreateRequest(validProps);

    // Should throw for invalid props
    assert.throws(() => {
      domainService.validateCreateRequest({
        ...validProps,
        name: ""
      });
    }, /Name is required/);

    assert.throws(() => {
      domainService.validateCreateRequest({
        ...validProps,
        temperature: 3
      });
    }, /Temperature must be between 0 and 2/);
  });

  test("should prepare default config change", () => {
    const config1 = AgentConfig.create({
      name: "Config 1",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123",
      isDefault: true
    });

    const config2 = AgentConfig.create({
      name: "Config 2",
      provider: "anthropic",
      model: "claude-3",
      apiKey: "sk-test456"
    });

    const { configsToUpdate, newDefault } = domainService.prepareDefaultConfigChange(
      [config1, config2],
      config2.id
    );

    assert.equal(configsToUpdate.length, 2);
    assert.equal(newDefault.id, config2.id);
    assert.equal(newDefault.isDefault, true);

    const updatedConfig1 = configsToUpdate.find(c => c.id === config1.id);
    assert(updatedConfig1);
    assert.equal(updatedConfig1.isDefault, false);
  });
});

describe("InMemoryAgentConfigRepository", () => {
  let repository: InMemoryAgentConfigRepository;

  beforeEach(() => {
    repository = new InMemoryAgentConfigRepository();
  });

  test("should save and retrieve configs", async () => {
    const config = AgentConfig.create({
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    });

    const saved = await repository.save(config, "encrypted_key");
    assert.equal(saved.name, "Test Config");

    const retrieved = await repository.findById(saved.id);
    assert(retrieved);
    assert.equal(retrieved.name, "Test Config");

    const all = await repository.findAll();
    assert.equal(all.length, 1);
  });

  test("should handle default config", async () => {
    const config1 = AgentConfig.create({
      name: "Config 1",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123",
      isDefault: true
    });

    const config2 = AgentConfig.create({
      name: "Config 2",
      provider: "anthropic",
      model: "claude-3",
      apiKey: "sk-test456"
    });

    await repository.save(config1, "encrypted_key1");
    await repository.save(config2, "encrypted_key2");

    const defaultConfig = await repository.findDefault();
    assert(defaultConfig);
    assert.equal(defaultConfig.id, config1.id);
  });

  test("should check name existence", async () => {
    const config = AgentConfig.create({
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    });

    await repository.save(config, "encrypted_key");

    const exists = await repository.existsByName("Test Config");
    assert.equal(exists, true);

    const notExists = await repository.existsByName("Other Config");
    assert.equal(notExists, false);

    const excludeSelf = await repository.existsByName("Test Config", config.id);
    assert.equal(excludeSelf, false);
  });
});

describe("AgentConfigApplicationService", () => {
  let applicationService: AgentConfigApplicationService;
  let repository: InMemoryAgentConfigRepository;
  let encryption: MockEncryptionService;
  let agentTesting: MockAgentTestingService;
  let auditLogger: InMemoryAuditLogger;
  let domainService: AgentConfigDomainService;

  beforeEach(() => {
    repository = new InMemoryAgentConfigRepository();
    encryption = new MockEncryptionService();
    agentTesting = new MockAgentTestingService();
    auditLogger = new InMemoryAuditLogger();
    domainService = new AgentConfigDomainService();

    applicationService = new AgentConfigApplicationService(
      repository,
      encryption,
      agentTesting,
      auditLogger,
      domainService
    );
  });

  test("should create agent config", async () => {
    const input: CreateAgentConfigProps = {
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    };

    const config = await applicationService.createConfig(input);

    assert.equal(config.name, "Test Config");
    assert.equal(config.apiKeyConfigured, true);

    // Check audit log
    const logs = auditLogger.getLogs();
    assert.equal(logs.length, 1);
    assert.equal(logs[0].action, 'CREATE');
  });

  test("should fail to create config without encryption", async () => {
    encryption.setAvailable(false);

    const input: CreateAgentConfigProps = {
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    };

    try {
      await applicationService.createConfig(input);
      assert.fail("Should have thrown an error");
    } catch (error) {
      assert(error instanceof Error);
      assert(error.message.includes("Encryption not available"));
    }
  });

  test("should prevent duplicate names", async () => {
    const input: CreateAgentConfigProps = {
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    };

    await applicationService.createConfig(input);

    try {
      await applicationService.createConfig(input);
      assert.fail("Should have thrown an error");
    } catch (error) {
      assert(error instanceof Error);
      assert(error.message.includes("already exists"));
    }
  });

  test("should update config", async () => {
    const config = await applicationService.createConfig({
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    });

    const updated = await applicationService.updateConfig(config.id, {
      name: "Updated Config",
      temperature: 0.5
    });

    assert.equal(updated.name, "Updated Config");
    assert.equal(updated.temperature, 0.5);

    // Check audit log
    const logs = auditLogger.getLogsForConfig(config.id);
    assert.equal(logs.length, 2); // CREATE + UPDATE
    assert.equal(logs[1].action, 'UPDATE');
  });

  test("should delete non-default config", async () => {
    const config = await applicationService.createConfig({
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    });

    await applicationService.deleteConfig(config.id);

    const retrieved = await applicationService.getConfig(config.id);
    assert.equal(retrieved, null); // Should be soft-deleted (inactive)

    // Check audit log
    const logs = auditLogger.getLogsForConfig(config.id);
    assert.equal(logs.length, 2); // CREATE + DELETE
    assert.equal(logs[1].action, 'DELETE');
  });

  test("should not delete default config", async () => {
    const config = await applicationService.createConfig({
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123",
      isDefault: true
    });

    try {
      await applicationService.deleteConfig(config.id);
      assert.fail("Should have thrown an error");
    } catch (error) {
      assert(error instanceof Error);
      assert(error.message.includes("Cannot delete the default"));
    }
  });

  test("should set default config", async () => {
    const config1 = await applicationService.createConfig({
      name: "Config 1",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123",
      isDefault: true
    });

    const config2 = await applicationService.createConfig({
      name: "Config 2",
      provider: "anthropic",
      model: "claude-3",
      apiKey: "sk-test456"
    });

    await applicationService.setDefaultConfig(config2.id);

    const defaultConfig = await applicationService.getDefaultConfig();
    assert(defaultConfig);
    assert.equal(defaultConfig.id, config2.id);

    // Check audit log
    const logs = auditLogger.getLogsForConfig(config2.id);
    const setDefaultLog = logs.find(log => log.action === 'SET_DEFAULT');
    assert(setDefaultLog);
  });

  test("should test config", async () => {
    const config = await applicationService.createConfig({
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    });

    const result = await applicationService.testConfig({
      configId: config.id,
      testPrompt: "Test message"
    });

    assert.equal(result.success, true);
    assert(result.responseTime !== undefined);
    assert.equal(result.modelUsed, "gpt-4");

    // Check audit log
    const logs = auditLogger.getLogsForConfig(config.id);
    const testLog = logs.find(log => log.action === 'TEST');
    assert(testLog);
  });

  test("should handle test failure", async () => {
    agentTesting.setShouldFail(true, "API connection failed");

    const config = await applicationService.createConfig({
      name: "Test Config",
      provider: "openai",
      model: "gpt-4",
      apiKey: "sk-test123"
    });

    const result = await applicationService.testConfig({
      configId: config.id
    });

    assert.equal(result.success, false);
    assert.equal(result.errorMessage, "API connection failed");
  });
});

describe("DTO Validation", () => {
  test("should parse valid DTO", () => {
    const schema = z.object({
      name: z.string().min(1),
      age: z.number().min(0).optional(),
      active: z.boolean(),
    });

    const input = {
      name: "John",
      age: 25,
      active: true
    };

    const result = parseDto(schema, input, "test");
    assert.equal(result.name, "John");
    assert.equal(result.age, 25);
    assert.equal(result.active, true);
  });

  test("should validate required fields", () => {
    const schema = z.object({
      name: z.string().min(1),
    });

    assert.throws(() => {
      parseDto(schema, {}, "test");
    }, BadRequestException);

    assert.throws(() => {
      parseDto(schema, { name: "" }, "test");
    }, BadRequestException);
  });

  test("should validate types", () => {
    const schema = z.object({
      name: z.string(),
      age: z.number(),
    });

    assert.throws(() => {
      parseDto(schema, { name: 123, age: "25" }, "test");
    }, BadRequestException);
  });

  test("should validate ranges", () => {
    const schema = z.object({
      temperature: z.number().min(0).max(2).optional(),
      name: z.string().min(2).max(10).optional(),
    });

    assert.throws(() => {
      parseDto(schema, { temperature: 3 }, "test");
    }, BadRequestException);

    assert.throws(() => {
      parseDto(schema, { name: "a" }, "test");
    }, BadRequestException);

    assert.throws(() => {
      parseDto(schema, { name: "very long name" }, "test");
    }, BadRequestException);
  });

  test("should validate enums", () => {
    const schema = z.object({
      provider: z.enum(["openai", "anthropic", "custom"]),
    });

    // Valid
    const result = parseDto(schema, { provider: 'openai' }, "test");
    assert.equal(result.provider, 'openai');

    // Invalid
    assert.throws(() => {
      parseDto(schema, { provider: 'invalid' }, "test");
    }, BadRequestException);
  });
});
