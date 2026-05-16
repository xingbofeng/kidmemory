import { AgentConfig } from '../domain/agent-config.entity.ts';
import type { AgentConfigProps } from '../domain/agent-config.entity.ts';
import type { AgentConfigRepository } from '../ports/agent-config.ports.ts';

interface PrismaAgentConfigRecord {
  id: string;
  name: string;
  description: string | null;
  provider: string;
  model: string;
  baseUrl: string | null;
  apiKeyEncrypted: string;
  temperature: unknown;
  maxTokens: number;
  systemPrompt: string | null;
  toolsEnabled: string[];
  workspaceConfig: unknown;
  isDefault: boolean;
  isActive: boolean;
  lastTestedAt: Date | null;
  testResult: string | null;
  createdAt: Date;
  updatedAt: Date;
}

interface AgentConfigDelegate {
  findMany(args?: unknown): Promise<PrismaAgentConfigRecord[]>;
  findUnique(args: unknown): Promise<PrismaAgentConfigRecord | null>;
  findFirst(args: unknown): Promise<PrismaAgentConfigRecord | null>;
  create(args: unknown): Promise<PrismaAgentConfigRecord>;
  update(args: unknown): Promise<PrismaAgentConfigRecord>;
  updateMany(args: unknown): Promise<{ count: number }>;
}

interface PrismaAgentConfigClient {
  agentConfig: AgentConfigDelegate;
  $transaction<T>(fn: (tx: PrismaAgentConfigClient) => Promise<T>): Promise<T>;
}

export class PrismaAgentConfigRepository implements AgentConfigRepository {
  private readonly prisma: PrismaAgentConfigClient;

  constructor(prisma: PrismaAgentConfigClient) {
    this.prisma = prisma;
  }

  async findAll(): Promise<AgentConfig[]> {
    const configs = await this.prisma.agentConfig.findMany({
      where: { isActive: true },
      orderBy: [
        { isDefault: 'desc' },
        { createdAt: 'desc' },
      ],
    });

    return configs.map(config => this.toDomainEntity(config));
  }

  async findById(id: string): Promise<AgentConfig | null> {
    const config = await this.prisma.agentConfig.findUnique({
      where: { id },
    });

    if (!config || !config.isActive) {
      return null;
    }

    return this.toDomainEntity(config);
  }

  async findDefault(): Promise<AgentConfig | null> {
    const config = await this.prisma.agentConfig.findFirst({
      where: {
        isDefault: true,
        isActive: true,
      },
    });

    if (!config) {
      return null;
    }

    return this.toDomainEntity(config);
  }

  async save(config: AgentConfig, encryptedApiKey: string): Promise<AgentConfig> {
    const props = config.toPlainObject();

    if (props.isDefault) {
      return await this.prisma.$transaction(async (tx) => {
        await tx.agentConfig.updateMany({
          where: { isDefault: true },
          data: { isDefault: false },
        });
        const created = await this.createRecord(tx, props, encryptedApiKey);
        return this.toDomainEntity(created);
      });
    }

    const created = await this.createRecord(this.prisma, props, encryptedApiKey);
    return this.toDomainEntity(created);
  }

  async update(config: AgentConfig, encryptedApiKey?: string): Promise<AgentConfig> {
    const props = config.toPlainObject();
    const updateData: Record<string, unknown> = {
      name: props.name,
      description: props.description || null,
      provider: props.provider,
      model: props.model,
      baseUrl: props.baseUrl || null,
      temperature: props.temperature,
      maxTokens: props.maxTokens,
      systemPrompt: props.systemPrompt || null,
      toolsEnabled: props.toolsEnabled,
      workspaceConfig: props.workspaceConfig,
      isDefault: props.isDefault,
      isActive: props.isActive,
      lastTestedAt: props.lastTestedAt || null,
      testResult: props.testResult || null,
      updatedAt: new Date(),
    };

    if (encryptedApiKey) {
      updateData.apiKeyEncrypted = encryptedApiKey;
    }

    const updated = await this.prisma.agentConfig.update({
      where: { id: props.id },
      data: updateData,
    });

    return this.toDomainEntity(updated);
  }

  async saveMany(configs: AgentConfig[]): Promise<AgentConfig[]> {
    return await this.prisma.$transaction(async (tx) => {
      const results: AgentConfig[] = [];

      for (const config of configs) {
        const updated = await new PrismaAgentConfigRepository(tx).update(config);
        results.push(updated);
      }

      return results;
    });
  }

  async getEncryptedApiKey(configId: string): Promise<string | null> {
    const config = await this.prisma.agentConfig.findUnique({
      where: { id: configId },
    });

    if (!config || !config.isActive) {
      return null;
    }

    return config.apiKeyEncrypted;
  }

  async existsByName(name: string, excludeId?: string): Promise<boolean> {
    const where: Record<string, unknown> = {
      name,
      isActive: true,
    };

    if (excludeId) {
      where.id = { not: excludeId };
    }

    const existing = await this.prisma.agentConfig.findFirst({
      where,
    });

    return !!existing;
  }

  private async createRecord(prisma: PrismaAgentConfigClient, props: AgentConfigProps, encryptedApiKey: string) {
    return await prisma.agentConfig.create({
      data: {
        id: props.id,
        name: props.name,
        description: props.description || null,
        provider: props.provider,
        model: props.model,
        baseUrl: props.baseUrl || null,
        apiKeyEncrypted: encryptedApiKey,
        temperature: props.temperature,
        maxTokens: props.maxTokens,
        systemPrompt: props.systemPrompt || null,
        toolsEnabled: props.toolsEnabled,
        workspaceConfig: props.workspaceConfig,
        isDefault: props.isDefault,
        isActive: props.isActive,
        lastTestedAt: props.lastTestedAt || null,
        testResult: props.testResult || null,
      },
    });
  }

  private toDomainEntity(prismaConfig: PrismaAgentConfigRecord): AgentConfig {
    const props: AgentConfigProps = {
      id: prismaConfig.id,
      name: prismaConfig.name,
      description: prismaConfig.description || undefined,
      provider: this.normalizeProvider(prismaConfig.provider),
      model: prismaConfig.model,
      baseUrl: prismaConfig.baseUrl || undefined,
      apiKeyConfigured: !!prismaConfig.apiKeyEncrypted,
      temperature: Number(prismaConfig.temperature),
      maxTokens: prismaConfig.maxTokens,
      systemPrompt: prismaConfig.systemPrompt || undefined,
      toolsEnabled: prismaConfig.toolsEnabled,
      workspaceConfig: this.normalizeWorkspaceConfig(prismaConfig.workspaceConfig),
      isDefault: prismaConfig.isDefault,
      isActive: prismaConfig.isActive,
      lastTestedAt: prismaConfig.lastTestedAt || undefined,
      testResult: this.normalizeTestResult(prismaConfig.testResult),
      createdAt: prismaConfig.createdAt,
      updatedAt: prismaConfig.updatedAt,
    };

    return AgentConfig.fromPersistence(props);
  }

  private normalizeProvider(provider: string): AgentConfigProps["provider"] {
    if (provider === "anthropic" || provider === "custom") {
      return provider;
    }
    return "openai";
  }

  private normalizeTestResult(testResult: string | null): AgentConfigProps["testResult"] {
    if (testResult === "success" || testResult === "failed" || testResult === "pending") {
      return testResult;
    }
    return undefined;
  }

  private normalizeWorkspaceConfig(value: unknown): Record<string, unknown> {
    return typeof value === "object" && value !== null && !Array.isArray(value) ? value as Record<string, unknown> : {};
  }
}
