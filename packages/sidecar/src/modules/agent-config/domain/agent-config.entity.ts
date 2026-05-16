/**
 * Agent Configuration Domain Entity
 *
 * Core business entity representing an AI agent configuration.
 * Contains business rules and validation logic.
 */

export type AgentProvider = 'openai' | 'anthropic' | 'custom';
export type TestResult = 'success' | 'failed' | 'pending';

export interface AgentConfigProps {
  id: string;
  name: string;
  description?: string;
  provider: AgentProvider;
  model: string;
  baseUrl?: string;
  apiKeyConfigured: boolean;
  temperature: number;
  maxTokens: number;
  systemPrompt?: string;
  toolsEnabled: string[];
  workspaceConfig: Record<string, any>;
  isDefault: boolean;
  isActive: boolean;
  lastTestedAt?: Date;
  testResult?: TestResult;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateAgentConfigProps {
  name: string;
  description?: string;
  provider: AgentProvider;
  model: string;
  baseUrl?: string;
  apiKey: string;
  temperature?: number;
  maxTokens?: number;
  systemPrompt?: string;
  toolsEnabled?: string[];
  workspaceConfig?: Record<string, any>;
  isDefault?: boolean;
}

export interface UpdateAgentConfigProps {
  name?: string;
  description?: string;
  provider?: AgentProvider;
  model?: string;
  baseUrl?: string;
  apiKey?: string;
  temperature?: number;
  maxTokens?: number;
  systemPrompt?: string;
  toolsEnabled?: string[];
  workspaceConfig?: Record<string, any>;
  isActive?: boolean;
}

export class AgentConfig {
  private readonly props: AgentConfigProps;

  private constructor(props: AgentConfigProps) {
    this.props = props;
    this.validateInvariants();
  }

  static create(props: CreateAgentConfigProps, id?: string): AgentConfig {
    const now = new Date();

    return new AgentConfig({
      id: id || this.generateId(),
      name: props.name,
      description: props.description,
      provider: props.provider,
      model: props.model,
      baseUrl: props.baseUrl,
      apiKeyConfigured: true, // We have an API key
      temperature: props.temperature ?? 0.7,
      maxTokens: props.maxTokens ?? 4000,
      systemPrompt: props.systemPrompt,
      toolsEnabled: props.toolsEnabled ?? [],
      workspaceConfig: props.workspaceConfig ?? {},
      isDefault: props.isDefault ?? false,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    });
  }

  static fromPersistence(props: AgentConfigProps): AgentConfig {
    return new AgentConfig(props);
  }

  update(props: UpdateAgentConfigProps): AgentConfig {
    const updatedProps: AgentConfigProps = {
      ...this.props,
      ...Object.fromEntries(
        Object.entries(props).filter(([_, value]) => value !== undefined)
      ),
      updatedAt: this.nextUpdatedAt(),
    };

    return new AgentConfig(updatedProps);
  }

  markAsDefault(): AgentConfig {
    if (this.props.isDefault) {
      return this;
    }

    return new AgentConfig({
      ...this.props,
      isDefault: true,
      updatedAt: this.nextUpdatedAt(),
    });
  }

  markAsNonDefault(): AgentConfig {
    if (!this.props.isDefault) {
      return this;
    }

    return new AgentConfig({
      ...this.props,
      isDefault: false,
      updatedAt: this.nextUpdatedAt(),
    });
  }

  deactivate(): AgentConfig {
    if (!this.props.isActive) {
      return this;
    }

    return new AgentConfig({
      ...this.props,
      isActive: false,
      updatedAt: this.nextUpdatedAt(),
    });
  }

  updateTestResult(result: TestResult, error?: string): AgentConfig {
    return new AgentConfig({
      ...this.props,
      lastTestedAt: new Date(),
      testResult: result,
      updatedAt: this.nextUpdatedAt(),
    });
  }

  canBeDeleted(): boolean {
    return !this.props.isDefault;
  }

  requiresCustomBaseUrl(): boolean {
    return this.props.provider === 'custom';
  }

  // Getters
  get id(): string { return this.props.id; }
  get name(): string { return this.props.name; }
  get description(): string | undefined { return this.props.description; }
  get provider(): AgentProvider { return this.props.provider; }
  get model(): string { return this.props.model; }
  get baseUrl(): string | undefined { return this.props.baseUrl; }
  get apiKeyConfigured(): boolean { return this.props.apiKeyConfigured; }
  get temperature(): number { return this.props.temperature; }
  get maxTokens(): number { return this.props.maxTokens; }
  get systemPrompt(): string | undefined { return this.props.systemPrompt; }
  get toolsEnabled(): string[] { return [...this.props.toolsEnabled]; }
  get workspaceConfig(): Record<string, any> { return { ...this.props.workspaceConfig }; }
  get isDefault(): boolean { return this.props.isDefault; }
  get isActive(): boolean { return this.props.isActive; }
  get lastTestedAt(): Date | undefined { return this.props.lastTestedAt; }
  get testResult(): TestResult | undefined { return this.props.testResult; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  toPlainObject(): AgentConfigProps {
    return {
      ...this.props,
      toolsEnabled: [...this.props.toolsEnabled],
      workspaceConfig: { ...this.props.workspaceConfig },
    };
  }

  private validateInvariants(): void {
    if (!this.props.name || this.props.name.trim().length === 0) {
      throw new Error('Agent config name is required');
    }

    if (!this.props.provider) {
      throw new Error('Agent config provider is required');
    }

    if (!['openai', 'anthropic', 'custom'].includes(this.props.provider)) {
      throw new Error('Agent config provider must be one of: openai, anthropic, custom');
    }

    if (!this.props.model || this.props.model.trim().length === 0) {
      throw new Error('Agent config model is required');
    }

    if (this.props.temperature < 0 || this.props.temperature > 2) {
      throw new Error('Agent config temperature must be between 0 and 2');
    }

    if (this.props.maxTokens <= 0) {
      throw new Error('Agent config max tokens must be greater than 0');
    }

    if (this.props.provider === 'custom' && (!this.props.baseUrl || this.props.baseUrl.trim().length === 0)) {
      throw new Error('Base URL is required for custom provider');
    }
  }

  private nextUpdatedAt(): Date {
    return new Date(Math.max(Date.now(), this.props.updatedAt.getTime() + 1));
  }

  private static generateId(): string {
    return `config_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
  }
}
