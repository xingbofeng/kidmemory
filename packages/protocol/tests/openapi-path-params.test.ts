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

  test("sidecar web-companion generated client includes books and share response contracts", () => {
    const generatedTypeFile = path.resolve(process.cwd(), "generated/sidecar/ts/index.d.ts");
    const content = readFileSync(generatedTypeFile, "utf8");

    const operations = [
      "WebCompanionController_getBooksList",
      "WebCompanionController_getBookDetails",
      "WebCompanionController_createShareToken",
      "WebCompanionController_accessSharedContent",
      "WebCompanionController_getSharedAssets",
      "WebCompanionController_getSharedBook",
    ];

    for (const operation of operations) {
      const match = content.match(new RegExp(`${operation}:[\\s\\S]*?(?=\\n    [A-Za-z0-9_]+: \\{|\\n\\};)`));
      assert.ok(match, `${operation} missing from generated sidecar client`);
      assert.doesNotMatch(match[0], /content\?: never/, `${operation} response content should not be never`);
    }

    const createShareToken = content.match(
      /WebCompanionController_createShareToken:[\s\S]*?(?=\n    [A-Za-z0-9_]+: \{|\n\};)/,
    );
    assert.ok(createShareToken, "WebCompanionController_createShareToken missing from generated sidecar client");
    assert.doesNotMatch(createShareToken[0], /requestBody\?: never/, "createShareToken requestBody should not be never");
  });

  test("sidecar creation task generated client includes planning request body settings", () => {
    const openapiFile = path.resolve(process.cwd(), "openapi/sidecar.openapi.json");
    const doc = JSON.parse(readFileSync(openapiFile, "utf8")) as OpenApiDoc;
    const createTask = doc.paths?.["/creation/tasks"]?.post as
      | {
          requestBody?: {
            content?: {
              "application/json"?: {
                schema?: {
                  properties?: Record<string, unknown>;
                };
              };
            };
          };
        }
      | undefined;

    const schema = createTask?.requestBody?.content?.["application/json"]?.schema;
    assert.ok(schema?.properties?.goal, "creation task request body should include goal");
    assert.ok(schema?.properties?.creationType, "creation task request body should include creationType");
    assert.ok(schema?.properties?.assetIds, "creation task request body should include assetIds");
    assert.ok(schema?.properties?.settings, "creation task request body should include settings");

    const generatedTypeFile = path.resolve(process.cwd(), "generated/sidecar/ts/index.d.ts");
    const content = readFileSync(generatedTypeFile, "utf8");
    const createTaskOperation = content.match(
      /CreationController_createTask:[\s\S]*?(?=\n    [A-Za-z0-9_]+: \{|\n\};)/,
    );
    assert.ok(createTaskOperation, "CreationController_createTask missing from generated sidecar client");
    assert.doesNotMatch(createTaskOperation[0], /requestBody\?: never/, "createTask requestBody should not be never");
    assert.match(createTaskOperation[0], /settings\?:\s*\{[\s\S]*?\[key: string\]: unknown/, "createTask settings should be typed");
  });

  test("generated TypeScript clients keep empty component maps typed as unknown", () => {
    const files = [
      "generated/cloud-api/ts/index.d.ts",
      "generated/sidecar/ts/index.d.ts",
      "scripts/generate-ts-client.mjs",
    ];
    const offenders = files.filter((file) =>
      readFileSync(path.resolve(process.cwd(), file), "utf8").includes("Record<string, any>"),
    );

    assert.deepEqual(offenders, [], `Generated TS client any maps found:\n${offenders.join("\n")}`);
  });

  test("generated Dart clients do not keep broad build_runner constraints", () => {
    const files = [
      "generated/cloud-api/dart/pubspec.yaml",
      "generated/sidecar/dart/pubspec.yaml",
    ];
    const offenders = files.filter((file) =>
      readFileSync(path.resolve(process.cwd(), file), "utf8").includes("build_runner: any"),
    );

    assert.deepEqual(offenders, [], `Generated Dart pubspec broad constraints found:\n${offenders.join("\n")}`);
  });
});
