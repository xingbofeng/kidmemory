import { fileURLToPath } from "node:url";

import {
  assertOpenAIProviderEnvValid,
  loadDefaultEnvFile,
  readProviderChatHealthcheckTimeoutMs,
  runProviderChatHealthcheck,
} from "./lib.ts";

async function main(): Promise<void> {
  await loadDefaultEnvFile();
  assertOpenAIProviderEnvValid();

  try {
    const result = await runProviderChatHealthcheck({
      timeoutMs: readProviderChatHealthcheckTimeoutMs(),
    });
    console.log("Provider chat healthcheck passed.");
    console.log(`Provider host: ${result.providerHost}`);
    console.log(`Model configured: ${result.modelConfigured}`);
    console.log(`Content preview: ${result.contentPreview}`);
  } catch (error) {
    console.error(error instanceof Error ? error.message : "Provider chat healthcheck failed.");
    process.exitCode = 1;
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  await main();
}
