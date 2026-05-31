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

type OpenApiParameter = {
  $ref?: string;
  in?: string;
  name?: string;
  required?: boolean;
  schema?: { $ref?: string; type?: string };
};

type OpenApiSchema = Record<string, unknown>;

const CLOUD_API_SCHEMAS: Record<string, OpenApiSchema> = {
  RegisterDeviceRequestDto: {
    type: "object",
    required: ["machineId"],
    properties: {
      machineId: { type: "string" },
      deviceName: { type: "string" },
      platform: { type: "string" },
    },
  },
  DeviceResponseDto: {
    type: "object",
    required: ["id", "machineId", "lastHeartbeat", "createdAt", "updatedAt"],
    properties: {
      id: { type: "string" },
      machineId: { type: "string" },
      deviceName: { type: "string" },
      platform: { type: "string" },
      lastHeartbeat: { type: "string" },
      createdAt: { type: "string" },
      updatedAt: { type: "string" },
    },
  },
  UploadItemResponseDto: {
    type: "object",
    required: ["id", "sessionId", "objectKey", "fileName", "status", "createdAt", "updatedAt"],
    properties: {
      id: { type: "string" },
      sessionId: { type: "string" },
      childId: { type: "string" },
      deviceId: { type: "string" },
      objectKey: { type: "string" },
      fileName: { type: "string" },
      fileSize: { type: "string" },
      mimeType: { type: "string" },
      status: { type: "string", enum: ["pending", "uploaded", "synced", "failed"] },
      uploadedAt: { type: "string" },
      syncedAt: { type: "string" },
      errorMessage: { type: "string" },
      createdAt: { type: "string" },
      updatedAt: { type: "string" },
    },
  },
  UpdateSyncStatusRequestDto: {
    type: "object",
    required: ["status"],
    properties: {
      status: { type: "string", enum: ["uploaded", "synced", "failed"] },
      syncedAt: { type: "string" },
      errorMessage: { type: "string" },
    },
  },
  DirectUploadConfigResponseDto: {
    type: "object",
    required: ["anonKey"],
    properties: {
      anonKey: { type: "string" },
    },
  },
  TrustedUploadSessionChildDto: {
    type: "object",
    required: ["id", "displayName"],
    properties: {
      id: { type: "string" },
      displayName: { type: "string" },
    },
  },
  ProviderAvailabilityDto: {
    type: "object",
    required: ["available"],
    properties: {
      available: { type: "boolean" },
    },
  },
  DirectUploadProvidersDto: {
    type: "object",
    required: ["lan", "supabase"],
    properties: {
      lan: { $ref: "#/components/schemas/ProviderAvailabilityDto" },
      supabase: { $ref: "#/components/schemas/ProviderAvailabilityDto" },
    },
  },
  SessionSummaryResponseDto: {
    type: "object",
    required: ["sessionId", "status", "child", "expiresAt", "maxItems", "usedItems", "providers"],
    properties: {
      sessionId: { type: "string" },
      status: { type: "string" },
      child: { $ref: "#/components/schemas/TrustedUploadSessionChildDto" },
      expiresAt: { type: "string" },
      maxItems: { type: "number" },
      usedItems: { type: "number" },
      providers: { $ref: "#/components/schemas/DirectUploadProvidersDto" },
    },
  },
  CreateUploadFileDto: {
    type: "object",
    required: ["clientFileId", "filename", "contentType", "sizeBytes"],
    properties: {
      clientFileId: { type: "string" },
      filename: { type: "string" },
      contentType: { type: "string" },
      sizeBytes: { type: "number" },
    },
  },
  CreateUploadItemsRequestDto: {
    type: "object",
    required: ["token", "files"],
    properties: {
      token: { type: "string" },
      provider: { type: "string", enum: ["lan", "supabase"] },
      files: { type: "array", items: { $ref: "#/components/schemas/CreateUploadFileDto" } },
    },
  },
  SignedUploadTargetDto: {
    type: "object",
    required: ["method", "url", "headers"],
    properties: {
      method: { type: "string" },
      url: { type: "string" },
      headers: {
        type: "object",
        additionalProperties: { type: "string" },
      },
      expiresAt: { type: "string" },
    },
  },
  CreatedUploadItemDto: {
    type: "object",
    required: ["clientFileId", "uploadItemId", "assetId", "objectKey", "status"],
    properties: {
      clientFileId: { type: "string" },
      uploadItemId: { type: "string" },
      assetId: { type: "string" },
      objectKey: { type: "string" },
      status: { type: "string" },
      signedUpload: { $ref: "#/components/schemas/SignedUploadTargetDto" },
    },
  },
  CreateUploadItemsResponseDto: {
    type: "object",
    required: ["items"],
    properties: {
      items: { type: "array", items: { $ref: "#/components/schemas/CreatedUploadItemDto" } },
    },
  },
  CommitUploadItemRequestDto: {
    type: "object",
    required: ["token", "objectKey", "contentType", "sizeBytes"],
    properties: {
      token: { type: "string" },
      objectKey: { type: "string" },
      contentType: { type: "string" },
      sizeBytes: { type: "number" },
      uploadToken: { type: "string" },
      checksumSha256: { type: "string" },
      metadata: {
        type: "object",
        additionalProperties: true,
      },
    },
  },
  CommitUploadItemResponseDto: {
    type: "object",
    required: ["uploadItemId", "status"],
    properties: {
      uploadItemId: { type: "string" },
      status: { type: "string" },
    },
  },
  ShareTokenAccessDto: {
    type: "object",
    required: ["id", "childId", "resourceType", "accessType"],
    properties: {
      id: { type: "string" },
      childId: { type: "string" },
      resourceType: { type: "string", enum: ["specific_book", "child_assets"] },
      resourceId: { type: "string" },
      accessType: { type: "string", enum: ["read"] },
    },
  },
  ShareTokenValidationResponseDto: {
    type: "object",
    required: ["isValid"],
    properties: {
      isValid: { type: "boolean" },
      error: { type: "string" },
      shareToken: { $ref: "#/components/schemas/ShareTokenAccessDto" },
    },
  },
  SharedAssetDto: {
    type: "object",
    required: ["id", "title", "type", "createdAt"],
    properties: {
      id: { type: "string" },
      title: { type: "string" },
      type: { type: "string" },
      createdAt: { type: "string" },
    },
  },
  SharedBookDto: {
    type: "object",
    required: ["id", "title", "childId", "createdAt", "status"],
    properties: {
      id: { type: "string" },
      title: { type: "string" },
      childId: { type: "string" },
      createdAt: { type: "string" },
      status: { type: "string" },
    },
  },
};

function normalizePathParameters(document: { paths?: Record<string, { parameters?: OpenApiParameter[] }> }): void {
  const paths = document.paths;
  if (!paths) return;

  for (const [routePath, pathItem] of Object.entries(paths)) {
    const placeholders = [...routePath.matchAll(/\{([^}]+)\}/g)].map((match) => match[1]);
    if (placeholders.length === 0) continue;

    const existingParameters = Array.isArray(pathItem.parameters) ? pathItem.parameters : [];

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
      .addServer("http://127.0.0.1:3002", "Cloud API local server")
      .addServer("http://localhost:3002", "Cloud API local server (localhost)")
      .addTag("health", "Health check endpoints")
      .addTag("devices", "Device registration and sync")
      .addTag("upload-items", "Upload item sync")
      .build();

    const document = SwaggerModule.createDocument(app, swaggerConfig);
    normalizePathParameters(document);
    document.components = {
      ...document.components,
      schemas: {
        ...document.components?.schemas,
        ...CLOUD_API_SCHEMAS,
      },
    };

    await mkdir(outputDir, { recursive: true });
    await writeFile(jsonPath, `${JSON.stringify(document, null, 2)}\n`, "utf8");
    await writeFile(yamlPath, YAML.stringify(document), "utf8");

    process.stdout.write(`Generated ${jsonPath}\n`);
    process.stdout.write(`Generated ${yamlPath}\n`);
  } finally {
    await app.close();
  }
}

void generateOpenApi().catch((error) => {
  process.stderr.write(`Failed to generate cloud-api OpenAPI: ${error instanceof Error ? error.stack ?? error.message : String(error)}\n`);
  process.exitCode = 1;
});
