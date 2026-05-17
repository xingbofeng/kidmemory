/**
 * Agent Configuration DTOs
 *
 * Data Transfer Objects for the Agent Configuration API.
 * These define the shape of data sent to and from the API.
 */

import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

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
export type AgentConfigDto = components["schemas"]["AgentConfigResponseDto"];
export type TestAgentConfigResultDto =
  components["schemas"]["TestAgentConfigResultResponseDto"];

// Type definitions inferred from schemas
export type CreateAgentConfigDto = components["schemas"]["CreateAgentConfigRequestDto"];
export type UpdateAgentConfigDto = components["schemas"]["UpdateAgentConfigRequestDto"];
export type TestAgentConfigDto = components["schemas"]["TestAgentConfigRequestDto"];

// Success response DTOs
export type SuccessResponseDto = components["schemas"]["SuccessResponseDto"];
