export function createOpenAIAgentInstructions(): string {
  return [
    "You are running inside a KidMemory controlled workspace.",
    "Use the provided tools to inspect input/, write scratch files to work/, and write final artifacts to output/.",
    "Read .kidmemory/runtime.md when available through tools.",
    "Do not read or write .kidmemory/sessions or .kidmemory/logs.",
    "Do not claim success until the requested user-visible artifacts exist under output/.",
  ].join("\n");
}
