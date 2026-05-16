import "reflect-metadata";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { NestFactory } from "@nestjs/core";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import YAML from "yaml";

import { AppModule } from "../src/app.module.ts";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const outputDir = path.resolve(__dirname, "../../protocol/openapi");
const jsonPath = path.join(outputDir, "cloud-api.openapi.json");
const yamlPath = path.join(outputDir, "cloud-api.openapi.yaml");

function normalizePathParameters(document: Record<string, unknown>): void {
  const paths = document.paths as Record<string, Record<string, unknown>> | undefined;
  if (!paths) return;

  for (const [routePath, pathItem] of Object.entries(paths)) {
    const placeholders = [...routePath.matchAll(/\{([^}]+)\}/g)].map((match) => match[1]);
    if (placeholders.length === 0) continue;

    const existingParameters = Array.isArray(pathItem.parameters)
      ? (pathItem.parameters as Array<{ in?: string; name?: string }>)
      : [];

    for (const placeholder of placeholders) {
      const exists = existingParameters.some((parameter) => parameter.in === "path" && parameter.name === placeholder);
      if (exists) continue;
      existingParameters.push({
        name: placeholder,
        in: "path",
        required: true,
        schema: { type: "string" },
      });
    }

    pathItem.parameters = existingParameters;
  }
}

async function generateOpenApi(): Promise<void> {
  const app = await NestFactory.create(AppModule, { logger: false });
  try {
    const swaggerConfig = new DocumentBuilder()
      .setTitle("KidMemory Cloud API")
      .setDescription("Cloud API for KidMemory - uploads, sharing, and device sync")
      .setVersion("1.0.0")
      .addTag("health", "Health check endpoints")
      .addTag("devices", "Device registration and sync")
      .addTag("jobs", "Job lifecycle and sync")
      .addTag("upload-items", "Upload item sync")
      .build();

    const document = SwaggerModule.createDocument(app, swaggerConfig);
    normalizePathParameters(document as unknown as Record<string, unknown>);

    await mkdir(outputDir, { recursive: true });
    await writeFile(jsonPath, `${JSON.stringify(document, null, 2)}\n`, "utf8");
    await writeFile(yamlPath, YAML.stringify(document), "utf8");

    // eslint-disable-next-line no-console
    console.log(`Generated ${jsonPath}`);
    // eslint-disable-next-line no-console
    console.log(`Generated ${yamlPath}`);
  } finally {
    await app.close();
  }
}

void generateOpenApi().catch((error) => {
  // eslint-disable-next-line no-console
  console.error("Failed to generate cloud-api OpenAPI:", error);
  process.exitCode = 1;
});
