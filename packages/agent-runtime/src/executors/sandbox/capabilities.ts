import { Capabilities, type Capability } from "@openai/agents/sandbox";

import { toOpenAISandboxSkillCapabilities, type SkillDeckLoadResult } from "../../skills/index.js";

export function createOpenAISandboxRuntimeCapabilities(
  skills: SkillDeckLoadResult,
  options: { useResponses?: boolean } = {},
): Capability[] {
  if (options.useResponses === false) {
    return Capabilities.default();
  }
  return [...Capabilities.default(), ...toOpenAISandboxSkillCapabilities(skills)];
}
