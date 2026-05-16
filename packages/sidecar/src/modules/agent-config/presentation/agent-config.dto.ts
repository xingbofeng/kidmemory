/**
 * Agent Configuration DTOs
 *
 * Data Transfer Objects for the Agent Configuration API.
 * These define the shape of data sent to and from the API.
 */

import { z } from "zod";
import type { AgentProvider, TestResult } from '../domain/agent-config.entity.ts';

// Zod schemas for validation
export const CreateAgentConfigDtoSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().optional(),
  provider: z.enum(['openai', 'anthropic', 'custom']),
  model: z.string().min(1),
  baseUrl: z.string().url().optional(),
  apiKey: z.string().min(1),
  temperature: z.number().min(0).max(2).optional(),
  maxTokens: z.number().int().positive().optional(),
  systemPrompt: z.string().optional(),
  toolsEnabled: z.array(z.string()).optional(),
  workspaceConfig: z.record(z.string(), z.any()).optional(),
  isDefault: z.boolean().optional(),
}).strict();

export const UpdateAgentConfigDtoSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  description: z.string().optional(),
  provider: z.enum(['openai', 'anthropic', 'custom']).optional(),
  model: z.string().min(1).optional(),
  baseUrl: z.string().url().optional(),
  apiKey: z.string().min(1).optional(),
  temperature: z.number().min(0).max(2).optional(),
  maxTokens: z.number().int().positive().optional(),
  systemPrompt: z.string().optional(),
  toolsEnabled: z.array(z.string()).optional(),
  workspaceConfig: z.record(z.string(), z.any()).optional(),
  isActive: z.boolean().optional(),
}).strict();

export const TestAgentConfigDtoSchema = z.object({
  testPrompt: z.string().optional(),
}).strict();

// Response DTOs
export interface AgentConfigDto {
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
  lastTestedAt?: string;
  testResult?: TestResult;
  createdAt: string;
  updatedAt: string;
}

export interface TestAgentConfigResultDto {
  success: boolean;
  responseTime?: number;
  errorMessage?: string;
  modelUsed?: string;
  tokensUsed?: number;
}

// Type definitions inferred from schemas
export type CreateAgentConfigDto = z.infer<typeof CreateAgentConfigDtoSchema>;
export type UpdateAgentConfigDto = z.infer<typeof UpdateAgentConfigDtoSchema>;
export type TestAgentConfigDto = z.infer<typeof TestAgentConfigDtoSchema>;

// Success response DTOs
export interface SuccessResponseDto {
  success: boolean;
}
