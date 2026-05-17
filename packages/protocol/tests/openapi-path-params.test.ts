import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";
import { describe, test } from "node:test";

type OpenApiDoc = {
  paths?: Record<string, Record<string, unknown>>;
  components?: {
    schemas?: Record<string, unknown>;
  };
};

function getMissingPathParams(openapiFile: string): string[] {
  const content = readFileSync(openapiFile, "utf8");
  const doc = JSON.parse(content) as OpenApiDoc;
  const missing: string[] = [];
  const httpMethods = new Set(["get", "put", "post", "patch", "delete", "head", "options", "trace"]);

  for (const [routePath, operations] of Object.entries(doc.paths ?? {})) {
    const placeholders = [...routePath.matchAll(/\{([^}]+)\}/g)].map((match) => match[1]);
    if (placeholders.length === 0) continue;

    const pathLevelParams = Array.isArray((operations as { parameters?: unknown }).parameters)
      ? ((operations as { parameters: Array<{ in?: string; name?: string }> }).parameters ?? [])
      : [];

    for (const [method, operation] of Object.entries(operations)) {
      if (!httpMethods.has(method)) continue;
      const operationParameters = Array.isArray((operation as { parameters?: unknown }).parameters)
        ? ((operation as { parameters: Array<{ in?: string; name?: string }> }).parameters ?? [])
        : [];
      const definedPathParams = new Set(
        [...pathLevelParams, ...operationParameters]
          .filter((parameter) => parameter.in === "path")
          .map((parameter) => parameter.name)
          .filter((name): name is string => Boolean(name)),
      );

      for (const placeholder of placeholders) {
        if (!definedPathParams.has(placeholder)) {
          missing.push(`${method.toUpperCase()} ${routePath} -> {${placeholder}}`);
        }
      }
    }
  }

  return missing;
}

describe("OpenAPI path parameters", () => {
  test("sidecar OpenAPI declares all templated path parameters", () => {
    const openapiFile = path.resolve(process.cwd(), "openapi/sidecar.openapi.json");
    const missing = getMissingPathParams(openapiFile);
    assert.equal(missing.length, 0, `Missing path parameters:\n${missing.join("\n")}`);
  });

  test("cloud-api OpenAPI declares all templated path parameters", () => {
    const openapiFile = path.resolve(process.cwd(), "openapi/cloud-api.openapi.json");
    const missing = getMissingPathParams(openapiFile);
    assert.equal(missing.length, 0, `Missing path parameters:\n${missing.join("\n")}`);
  });

  test("cloud-api web-companion write endpoints declare request body schemas", () => {
    const openapiFile = path.resolve(process.cwd(), "openapi/cloud-api.openapi.json");
    const doc = JSON.parse(readFileSync(openapiFile, "utf8")) as OpenApiDoc;
    const createUploadItems = doc.paths?.["/api/web-companion/sessions/{sessionId}/items"]?.post as
      | {
          requestBody?: {
            content?: {
              "application/json"?: {
                schema?: { $ref?: string };
              };
            };
          };
        }
      | undefined;
    const commitUploadItem = doc.paths?.["/api/web-companion/sessions/{sessionId}/items/{uploadItemId}/commit"]?.put as
      | {
          requestBody?: {
            content?: {
              "application/json"?: {
                schema?: { $ref?: string };
              };
            };
          };
        }
      | undefined;

    const createRef = createUploadItems?.requestBody?.content?.["application/json"]?.schema?.$ref;
    const commitRef = commitUploadItem?.requestBody?.content?.["application/json"]?.schema?.$ref;

    assert.equal(
      createRef,
      "#/components/schemas/CreateUploadItemsRequestDto",
      "Expected POST /api/web-companion/sessions/{sessionId}/items requestBody schema ref",
    );
    assert.equal(
      commitRef,
      "#/components/schemas/CommitUploadItemRequestDto",
      "Expected PUT /api/web-companion/sessions/{sessionId}/items/{uploadItemId}/commit requestBody schema ref",
    );

    const schemas = doc.components?.schemas ?? {};
    assert.ok(schemas.CreateUploadItemsRequestDto, "CreateUploadItemsRequestDto schema missing from components");
    assert.ok(schemas.CommitUploadItemRequestDto, "CommitUploadItemRequestDto schema missing from components");
  });

  test("generated cloud-api TypeScript client includes web-companion request body types", () => {
    const generatedTypeFile = path.resolve(process.cwd(), "generated/cloud-api/ts/index.d.ts");
    const content = readFileSync(generatedTypeFile, "utf8");

    assert.match(
      content,
      /WebCompanionController_createUploadItems:[\s\S]*?requestBody:\s*{[\s\S]*?CreateUploadItemsRequestDto/,
      "Generated TS client should keep requestBody type for createUploadItems",
    );
    assert.match(
      content,
      /WebCompanionController_commitUploadItem:[\s\S]*?requestBody:\s*{[\s\S]*?CommitUploadItemRequestDto/,
      "Generated TS client should keep requestBody type for commitUploadItem",
    );
  });
});
