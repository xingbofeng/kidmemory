import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { test } from "node:test";

test("creation task contract tests use current contract language", () => {
  const source = readFileSync(path.resolve(process.cwd(), "tests/creation-task-types.test.ts"), "utf8");
  const forbidden = [
    ["mig", "ration"].join(""),
    ["o", "ld"].join(""),
    ["must", "remove"].join(" "),
    ["must", "add"].join(" "),
  ];

  for (const phrase of forbidden) {
    assert.equal(source.includes(phrase), false, `historical phrasing found: ${phrase}`);
  }
  assert.equal(source.match(/readFileSync\(creationSourcePath/g)?.length ?? 0, 1);
});

test("generated cloud api clients do not expose legacy jobs sync", () => {
  const files = [
    "openapi/cloud-api.openapi.yaml",
    "openapi/cloud-api.openapi.json",
    "generated/cloud-api/ts/index.d.ts",
    "generated/cloud-api/dart/README.md",
    "generated/cloud-api/dart/lib/kidmemory_protocol.dart",
    "generated/cloud-api/dart/lib/src/api.dart",
    "generated/cloud-api/dart/lib/src/deserialize.dart",
  ];
  const forbidden = /\/jobs\/pending|\/jobs\/\{id\}\/status|JobsApi|JobResponseDto|UpdateJobStatusRequestDto|JobsController_/;
  const offenders = files.filter((file) => forbidden.test(
    readFileSync(path.resolve(process.cwd(), file), "utf8"),
  ));

  assert.deepEqual(offenders, []);
});

test("generated cloud api dart models use stable component schema names", () => {
  const files = [
    "generated/cloud-api/dart/lib/kidmemory_protocol.dart",
    "generated/cloud-api/dart/lib/src/api.dart",
    "generated/cloud-api/dart/lib/src/deserialize.dart",
    "generated/cloud-api/dart/README.md",
  ];
  const inlineResolverNames =
    /SessionSummaryResponseDtoChild|SessionSummaryResponseDtoProviders|SessionSummaryResponseDtoProvidersLan|ShareTokenValidationResponseDtoShareToken/;
  const offenders = files.filter((file) => inlineResolverNames.test(
    readFileSync(path.resolve(process.cwd(), file), "utf8"),
  ));
  const staleInlineModelFiles = [
    "generated/cloud-api/dart/doc/SessionSummaryResponseDtoChild.md",
    "generated/cloud-api/dart/doc/SessionSummaryResponseDtoProviders.md",
    "generated/cloud-api/dart/doc/SessionSummaryResponseDtoProvidersLan.md",
    "generated/cloud-api/dart/doc/ShareTokenValidationResponseDtoShareToken.md",
    "generated/cloud-api/dart/lib/src/model/session_summary_response_dto_child.dart",
    "generated/cloud-api/dart/lib/src/model/session_summary_response_dto_providers.dart",
    "generated/cloud-api/dart/lib/src/model/session_summary_response_dto_providers_lan.dart",
    "generated/cloud-api/dart/lib/src/model/share_token_validation_response_dto_share_token.dart",
  ].filter((file) => existsSync(path.resolve(process.cwd(), file)));

  assert.deepEqual([...offenders, ...staleInlineModelFiles], []);
});
