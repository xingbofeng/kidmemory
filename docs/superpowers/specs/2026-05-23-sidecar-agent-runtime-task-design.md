# Sidecar Agent Runtime Task Design

Date: 2026-05-23

## Goal

Connect `packages/sidecar` to the already-defined `@kidmemory/agent-runtime` boundary and remove the old Sidecar-local agent/runtime concepts that now duplicate or violate that boundary.

The target model is:

- One creation task has one identity: `taskId`.
- One creation task has one runtime workspace.
- Plan, Generate, Review, Publish all reuse that same workspace.
- Sidecar owns product orchestration, persistence, config, local data, export, share, and repair flows.
- `@kidmemory/agent-runtime` owns agent execution, executor selection, skill discovery, runtime tools, session logs, and artifact scanning.

## Non-Goals

- Do not turn `@kidmemory/agent-runtime` into a service.
- Do not keep compatibility aliases for `/creation/jobs`, `planId`, or `jobId` in the creation flow.
- Do not keep Sidecar-local `run_skill_task` or `SkillRuntimeService`.
- Do not move database, config, asset import, export, or share responsibilities into `agent-runtime`.
- Do not remove non-creation `jobId` concepts such as storage sync jobs, embedding jobs, or legacy `/books/jobs`.

## Architecture

Add a thin Sidecar adapter module:

```text
packages/sidecar/src/modules/agent-runtime/
  agent-runtime.module.ts
  agent-runtime.service.ts
  agent-runtime.workspace.ts
  agent-runtime.contracts.ts
```

This module is the only Sidecar module allowed to import `@kidmemory/agent-runtime`.

Responsibilities:

1. Resolve provider config from `AgentConfigApplicationService`.
2. Decrypt the selected API key.
3. Prepare or refresh task workspace input files.
4. Call `AgentRuntime.run`.
5. Map runtime result, artifacts, event summary, and trace data into Sidecar task status and events.

Sidecar source code must not import `@openai/agents` after this change. `@openai/agents` should remain only inside `packages/agent-runtime`.

## Task Workspace

`POST /creation/tasks` creates the task and the workspace:

```text
<sidecar workspaceDir>/creation-tasks/<taskId>/
  .kidmemory/
    runtime.md
    manifest.json
    skills/
    sessions/
    logs/
  input/
    task-request.json
    child.json
    assets.json
    media/
  work/
  output/
    plan.json
    book.json
    book.html
    video.mp4
```

Rules:

- The workspace path is derived from `taskId`.
- Plan and Generate must not create separate workspaces.
- Generate may refresh `input/assets.json` and `input/media/*`.
- Generate must not delete `.kidmemory/`.
- Generate must not delete `output/plan.json`.
- Generate may remove stale stage-specific outputs, such as old `output/book.*` or `output/video.mp4`, before rerunning that stage.

## Runtime Stages

The adapter exposes a stage-oriented API:

```ts
type RuntimeStage = "plan" | "generate_book" | "generate_video";

type RunCreationStageInput = {
  taskId: string;
  workspacePath: string;
  stage: RuntimeStage;
  creationType: "storybook" | "memory_book" | "memoir_video";
  prompt: string;
  traceId: string;
  metadata?: Record<string, unknown>;
};
```

Required output files:

```ts
const requiredOutputFilesByStage = {
  plan: ["output/plan.json"],
  generate_book: ["output/book.json", "output/book.html"],
  generate_video: ["output/video.mp4"],
};
```

Provider config:

- `model` from the default agent config.
- `baseURL` from the default agent config.
- `apiKey` from decrypted default config.
- `useResponses` based on provider config.
- `executorKind` is read from config or env; default to `agent` for OpenAI-compatible providers.

## Task-First API

Delete creation job/plan endpoints and replace them with task endpoints:

```text
POST /creation/tasks
POST /creation/tasks/{taskId}/generate
GET  /creation/tasks/{taskId}
GET  /creation/tasks/{taskId}/events
GET  /creation/tasks/{taskId}/preview
POST /creation/tasks/{taskId}/export
POST /creation/tasks/{taskId}/share
```

`POST /creation/tasks`:

- Creates `taskId`.
- Creates the task workspace.
- Writes `input/task-request.json`, `input/assets.json`, and any available media context.
- Runs the `plan` stage.
- Parses and validates `output/plan.json`.
- Persists and returns `CreationTask` with `status: "ready"` or `status: "failed"`.

`POST /creation/tasks/{taskId}/generate`:

- Requires an existing task in `status: "ready"`.
- Reuses the existing workspace.
- Runs `generate_book` for `storybook` and `memory_book`.
- Runs `generate_video` for `memoir_video`.
- Maps artifacts into the same `CreationTask`.

No compatibility endpoints are kept for `/creation/jobs`.

## Protocol Types

Delete:

- `CreationPlan`
- `CreationJob`
- `CreationPlanStatus`
- `CreationJobStatus`
- `planId`
- `jobId` in the creation flow

Add:

```ts
export type CreationTaskStatus =
  | "planning"
  | "ready"
  | "generating"
  | "succeeded"
  | "failed"
  | "exporting"
  | "exported"
  | "sharing"
  | "shared"
  | "cancelled";

export interface CreationTask {
  taskId: string;
  creationType: CreationType;
  goal: string;
  assetIds: string[];
  status: CreationTaskStatus;
  currentStepId: string | null;
  summary?: string;
  skillName?: string;
  steps: CreationStep[];
  requirements: CreationPlanRequirements;
  requirementItems: string[];
  artifacts: CreationArtifact[];
  error: CreationError | null;
  workspacePath: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreationArtifact {
  artifactId: string;
  taskId: string;
  kind: "pdf" | "mp4" | "web_share";
  localPath?: string;
  shareId?: string;
  shareUrl?: string;
  createdAt: string;
}

export interface CreationEvent {
  eventId: string;
  taskId: string;
  stepId?: string;
  type: "plan" | "task" | "step" | "export" | "share" | "error";
  message: string;
  createdAt: string;
}
```

DTO replacements:

- `CreateCreationPlanDto` -> deleted
- `CreateCreationJobDto` -> deleted
- `CreateCreationTaskDto` -> `{ creationType, goal, assetIds }`
- `GenerateCreationTaskDto` -> `{}` for the first version
- `ExportCreationJobDto` -> `ExportCreationTaskDto`
- `ShareCreationJobDto` -> `ShareCreationTaskDto`

## Planning Contract

The plan stage writes `output/plan.json`:

```json
{
  "summary": "string",
  "skillName": "string",
  "steps": [
    {
      "stepId": "compose|plan|generate|review|publish",
      "label": "string",
      "detail": "string"
    }
  ],
  "requirements": ["string"]
}
```

Sidecar validates:

- JSON is parseable.
- `summary` is non-empty.
- `skillName` is non-empty.
- `steps` only use canonical step IDs.
- requirements are strings.

Sidecar no longer directly constructs `Agent`, `Runner`, `OpenAIProvider`, or `OpenAI` for planning.

## Book Generation Contract

The book generation stage writes:

```text
output/book.json
output/book.html
```

`output/book.json` keeps the existing Sidecar book contract:

```ts
{
  metadata: {
    title: string;
    childName: string;
  };
  pages: Array<{
    kind: "cover" | "artwork" | "photo" | "craft" | "closing";
    title: string;
    text: string;
    assetId?: string;
  }>;
}
```

Sidecar validates with existing book output validation before preview/export. The old silent fallback that creates a fake one-page book from malformed agent text should be removed. Contract failure should fail the task.

## Video Generation Contract

The video generation stage writes:

```text
output/video.mp4
```

Video rendering capability is supplied by runtime skill discovery, runtime tools, custom tools, or MCP configured through `agent-runtime`. Sidecar does not call `SkillRuntimeService.execute({ skillId: "hyperframes", tool: "render_hyperframes_video" })`.

FFmpeg repair remains a Sidecar concern, but it is triggered by mapped runtime errors or missing MP4 artifacts instead of `HYPERFRAMES_RENDER_COMMAND` return codes.

`HyperframesRenderService` is deleted in this migration. Diagnostic MCP must stop exposing `render_hyperframes_video`; video generation is only represented as creation task runtime execution that produces `output/video.mp4`.

## Desktop Client

Desktop keeps the user-facing two-step experience: create a plan, then confirm and generate. Internally it stores one ID.

Delete state:

```dart
String? planId;
String? jobId;
CreationPlanPreviewVm? creationPlan;
List<CreationPlanStepVm> creationJobSteps;
Timer? _creationJobPollingTimer;
```

Replace with:

```dart
String? taskId;
CreationTaskPreviewVm? creationTask;
List<CreationTaskStepVm> creationTaskSteps;
Timer? _creationTaskPollingTimer;
```

Delete gateway methods:

```dart
createCreationPlanRaw
createCreationJobRaw
getCreationJobRaw
getCreationJobEventsRaw
exportCreationJobRaw
shareCreationJobRaw
```

Add gateway methods:

```dart
createCreationTaskRaw
generateCreationTaskRaw
getCreationTaskRaw
getCreationTaskEventsRaw
exportCreationTaskRaw
shareCreationTaskRaw
```

Preview/export/share URLs use `/creation/tasks/{taskId}`.

UI text should prefer user-facing language such as "task" or "creation task". Avoid showing raw `taskId` except in debug logs.

## Deletion Inventory

This is a required implementation checklist. Each item must be deleted, rewritten, regenerated, or explicitly justified in the implementation notes.

### Deleted Use Cases

- [ ] Delete the two-ID creation flow: `planId -> jobId`.
- [ ] Delete Sidecar-local OpenAI agent execution.
- [ ] Delete Sidecar MCP `run_skill_task`.
- [ ] Delete Sidecar skill runtime registry/permission/workspace as runtime concepts.
- [ ] Delete creation main-path Hyperframes rendering through `SkillRuntimeService`.

### Deleted HTTP/API Surface

Delete:

- [ ] `POST /creation/jobs/plan`
- [ ] `POST /creation/jobs`
- [ ] `GET /creation/jobs/{jobId}`
- [ ] `GET /creation/jobs/{jobId}/events`
- [ ] `GET /creation/jobs/{jobId}/preview`
- [ ] `POST /creation/jobs/{jobId}/export`
- [ ] `POST /creation/jobs/{jobId}/share`

Add:

- [ ] `POST /creation/tasks`
- [ ] `POST /creation/tasks/{taskId}/generate`
- [ ] `GET /creation/tasks/{taskId}`
- [ ] `GET /creation/tasks/{taskId}/events`
- [ ] `GET /creation/tasks/{taskId}/preview`
- [ ] `POST /creation/tasks/{taskId}/export`
- [ ] `POST /creation/tasks/{taskId}/share`

### Deleted Source Files

Hard delete:

- [ ] `packages/sidecar/src/modules/books/providers/openai-sdk-agent-runner.ts`
- [ ] `packages/sidecar/src/modules/skills/skill-runtime.service.ts`
- [ ] `packages/sidecar/src/modules/skills/skill-workspace.service.ts`
- [ ] `packages/sidecar/src/modules/skills/skill-permission.service.ts`
- [ ] `packages/sidecar/src/modules/mcp/tools/skill-runtime.mcp-tools.ts`

Rewrite:

- [ ] `packages/sidecar/src/modules/creation/creation-planning.service.ts`
- [ ] `packages/sidecar/src/modules/creation/creation.service.ts`
- [ ] `packages/sidecar/src/modules/creation/creation.module.ts`
- [ ] `packages/sidecar/src/modules/creation/creation.controller.ts`
- [ ] `packages/sidecar/src/modules/creation/dto/creation.dto.ts`
- [ ] `packages/sidecar/src/modules/books/books.service.ts`
- [ ] `packages/sidecar/src/modules/books/providers/books.domain.ts`
- [ ] `packages/sidecar/src/modules/media/media.module.ts`
- [ ] `packages/sidecar/src/modules/mcp/tools/diagnostic.mcp-tools.ts`
- [ ] `packages/sidecar/src/modules/mcp/mcp.module.ts`
- [ ] `packages/sidecar/src/app.module.ts`
- [ ] `packages/sidecar/package.json`
- [ ] `packages/sidecar/package-lock.json`

Dependency changes:

- [ ] Remove direct Sidecar dependency on `@openai/agents`.
- [ ] Add Sidecar dependency on `@kidmemory/agent-runtime` via `file:../agent-runtime`.
- [ ] Keep `openai` only for non-agent config health checks such as `AgentTestingService`.
- [ ] Add or update architecture test so any Sidecar `src/**` import of `@openai/agents` fails.

Delete by default, or rename to installer-only module if still needed:

- [ ] `packages/sidecar/src/modules/skills/skill-loader.service.ts`
- [ ] `packages/sidecar/src/modules/skills/skill-registry.service.ts`
- [ ] `packages/sidecar/src/modules/skills/skill-auto-pull.service.ts`
- [ ] `packages/sidecar/src/modules/skills/skills.module.ts`
- [ ] `packages/sidecar/skills/skill-registry.json`

If the installer-only path is kept:

- [ ] Rename module/service names away from `SkillsModule` if they imply runtime execution.
- [ ] Do not export `execute`, `run`, `runtime`, `permission`, or `workspace` semantics.
- [ ] Do not import installer-only code from `CreationModule`.
- [ ] Do not import installer-only code from `SidecarMcpModule`.

PostgreSQL persistence:

- [ ] Rewrite creation task state from file-backed `creation/state.json` to PostgreSQL-backed records.
- [ ] Update `packages/sidecar/prisma/schema.prisma`.
- [ ] Add Prisma migration for creation tasks, creation events, and creation artifacts.
- [ ] Add repository/provider code for `CreationTask`, `CreationEvent`, and `CreationArtifact`.
- [ ] Remove or retire creation-specific use of `readRecord` / `writeRecord` file persistence.
- [ ] Keep non-creation export artifact `jobId` schema only if it still belongs to legacy `/books/jobs` or storage sync behavior.

### Deleted Tests

Hard delete:

- [ ] `packages/sidecar/tests/unit/modules/books/openai-sdk-agent-runner.test.ts`
- [ ] `packages/sidecar/tests/http/mcp-skill-runtime.test.ts`
- [ ] `packages/sidecar/tests/http/mcp-skill-runtime-chain.test.ts`
- [ ] `packages/sidecar/tests/unit/modules/media/hyperframes-render-service.test.ts`

Rewrite:

- [ ] `packages/sidecar/tests/contracts/creation-contracts.test.ts`
- [ ] `packages/sidecar/tests/unit/modules/creation/creation-books-bridge.test.ts`
- [ ] `packages/sidecar/tests/unit/modules/creation/creation-hyperframes-bridge.test.ts`
- [ ] `packages/sidecar/tests/unit/modules/creation/creation-planning-service.test.ts`
- [ ] `packages/sidecar/tests/http/mcp-diagnostic-image-hyperframes-tools.test.ts`
- [ ] `packages/sidecar/tests/architecture/architecture.test.ts`
- [ ] `packages/sidecar/tests/integration/prisma-migration.test.ts`
- [ ] `packages/desktop/test/core/sidecar/sidecar_api_test.dart`
- [ ] `packages/desktop/test/features/generate_export/generate_export_ui_enhancement_test.dart`
- [ ] `packages/desktop/test/features/app/app_test.dart`

Delete or rewrite if installer-only skill support remains:

- [ ] `packages/sidecar/tests/unit/modules/skills/skill-loader-scan.test.ts`
- [ ] `packages/sidecar/tests/unit/modules/skills/skill-loader-paths.test.ts`
- [ ] `packages/sidecar/tests/unit/modules/skills/skill-auto-pull.service.test.ts`

Add architecture checks:

- [ ] Sidecar `src` must not import `@openai/agents`.
- [ ] Sidecar MCP must not expose `run_skill_task` or Sidecar-level `list_skills`.
- [ ] Sidecar MCP must not expose `render_hyperframes_video`.
- [ ] Creation API and generated clients must not expose `/creation/jobs`, `planId`, or creation-main-path `jobId`.
- [ ] Creation persistence must use PostgreSQL-backed task/event/artifact records, not `creation/state.json`.

### Frontend Client Deletions

Rewrite:

- [ ] `packages/desktop/lib/core/sidecar/desktop_sidecar_gateway.dart`
- [ ] `packages/desktop/lib/app/desktop_shell.dart`
- [ ] `packages/desktop/lib/app/export/export.dart`
- [ ] `packages/desktop/lib/app/export/export_generation_state.dart`
- [ ] `packages/desktop/lib/app/export/export_actions.dart`
- [ ] `packages/desktop/lib/app/dataset/dataset_preview.dart`
- [ ] `packages/desktop/lib/features/generate_export/generate_export_page.dart`
- [ ] `packages/desktop/lib/app/pages/pages.dart`
- [ ] `packages/desktop/lib/app/assets/asset_actions.dart`
- [ ] `packages/desktop/lib/app/dataset/dataset.dart`
- [ ] `packages/desktop/lib/app/dataset/dataset_sample.dart`
- [ ] `packages/desktop/translations_data.json`
- [ ] `packages/desktop/lib/l10n/app_en.arb`
- [ ] `packages/desktop/lib/l10n/app_zh.arb`
- [ ] `packages/desktop/lib/l10n/app_localizations.dart`
- [ ] `packages/desktop/lib/l10n/app_localizations_en.dart`
- [ ] `packages/desktop/lib/l10n/app_localizations_zh.dart`

Delete or rename UI concepts:

- [ ] `planId`
- [ ] `jobId` in creation flow
- [ ] `creationPlan` if it represents a separate entity instead of a task preview
- [ ] `creationJobSteps`
- [ ] `_creationJobPollingTimer`
- [ ] `CreationPlanPreviewVm` as a separate plan entity
- [ ] `CreationPlanStepVm` if it keeps plan/job naming
- [ ] `readCreationPlanSteps` if it keeps plan/job naming
- [ ] `_invalidateCreationPlanForInputChange` if it keeps plan-only naming
- [ ] `confirmCreationPlan` if it keeps plan-only naming instead of confirming a task
- [ ] "missing jobId" user-facing text
- [ ] "got jobId" user-facing text
- [ ] `/creation/jobs/.../preview` preview URLs

Preferred replacements:

- [ ] `CreationTaskPreviewVm`
- [ ] `CreationTaskStepVm`
- [ ] `readCreationTaskSteps`
- [ ] `_invalidateCreationTaskForInputChange`
- [ ] `confirmCreationTask`
- [ ] User-facing copy should say "task", "creation task", or omit raw IDs.

Web companion currently has no direct `/creation/jobs` references. After generated protocol updates, verify this with static search.

### Generated Artifacts

Regenerate; do not hand-edit:

- [ ] `packages/protocol/src/common/creation.ts`
- [ ] `packages/protocol/src/index.ts`
- [ ] `packages/protocol/dist/index.d.ts`
- [ ] `packages/protocol/dist/common/creation.d.ts`
- [ ] `packages/protocol/openapi/sidecar.openapi.yaml`
- [ ] `packages/protocol/openapi/sidecar.openapi.json`
- [ ] `packages/protocol/openapi/sidecar.openapi.enhanced.json`
- [ ] `packages/protocol/openapi/sidecar.openapi.preview.zh.html`
- [ ] `packages/protocol/openapi/sidecar.preview.html`
- [ ] `packages/protocol/openapi/sidecar.preview.zh.html`
- [ ] `packages/protocol/generated/sidecar/ts/index.d.ts`
- [ ] `packages/protocol/generated/sidecar/dart/README.md`
- [ ] `packages/protocol/generated/sidecar/dart/lib/src/api/creation_api.dart`
- [ ] `packages/protocol/generated/sidecar/dart/doc/CreationApi.md`
- [ ] `packages/protocol/generated/sidecar/dart/test/creation_api_test.dart`

Generated model/API names must change from job/plan to task:

- [ ] `creationControllerCreatePlan` removed.
- [ ] `creationControllerCreateJob` removed.
- [ ] `creationControllerGenerateTask` added.
- [ ] `creationControllerGetTask` replaces `creationControllerGetJob`.
- [ ] `creationControllerExportTask` replaces `creationControllerExportJob`.
- [ ] `creationControllerShareTask` replaces `creationControllerShareJob`.
- [ ] Any generated `jobId` path parameter in Creation API becomes `taskId`.

### Docs And Script References

Update:

- [ ] `CONTEXT.md`
- [ ] `README.md`
- [ ] `README_EN.md`
- [ ] `packages/sidecar/README.md`
- [ ] `packages/protocol/openapi/README.md`
- [ ] `docs/README.md`
- [ ] `docs/images/README.md`
- [ ] `docs/images/agent-sdk-mcp-skill-en.png`
- [ ] `docs/images/agent-sdk-mcp-skill-zh.png`
- [ ] `docs/images/kidmemory-runtime-architecture-en.svg`
- [ ] `docs/images/kidmemory-runtime-architecture-zh.svg`
- [ ] `docs/images/kidmemory-runtime-architecture.svg`
- [ ] `docs/images/kidmemory-runtime-architecture.excalidraw`
- [ ] `implementation-notes.md`

Scripts to keep but use during regeneration/verification:

- [ ] `packages/sidecar/scripts/generate-openapi.ts`
- [ ] `packages/protocol/scripts/generate-ts-client.mjs`
- [ ] `packages/protocol/scripts/generate-dart-client.mjs`
- [ ] `packages/protocol/scripts/enhance-openapi-docs.mjs`
- [ ] `scripts/run-all-tests.sh`

If any script output still contains `/creation/jobs`, `planId`, or creation-main-path `jobId`, the implementation is incomplete.

## Verification

Static deletion checks:

```bash
rg "creation/jobs|planId|jobId|run_skill_task|SkillRuntimeService|OpenAISDKAgentRunner|@openai/agents" \
  packages/sidecar packages/desktop packages/protocol README.md README_EN.md \
  CONTEXT.md packages/sidecar/README.md packages/protocol/openapi/README.md docs/README.md docs/images/README.md
```

Allowed matches:

- `jobId` in non-creation domains such as storage sync, embedding jobs, sync jobs, and legacy `/books/jobs`.
- `@openai/agents` under `packages/agent-runtime`.
- `list_skills` under `packages/agent-runtime` skill-deck docs or implementation.
- Historical notes in `implementation-notes.md`, only if a new correction note makes the current boundary explicit.
- This design spec itself is excluded from the static deletion check because it intentionally names deleted APIs and files.

Focused creation API check:

```bash
rg "/creation/jobs|planId|jobId" \
  packages/protocol/openapi \
  packages/protocol/generated \
  packages/desktop/lib \
  packages/desktop/test
```

Target: no matches for the creation main path.

Sidecar runtime dependency check:

```bash
rg "@openai/agents|OpenAISDKAgentRunner|CreationPlanningService|SkillRuntimeService|HyperframesRenderService" \
  packages/sidecar/src packages/sidecar/tests packages/sidecar/package.json packages/sidecar/package-lock.json
```

Target:

- No `@openai/agents` in Sidecar.
- No `OpenAISDKAgentRunner`.
- No Sidecar `CreationPlanningService` that directly runs an agent.
- No `SkillRuntimeService`.
- No `HyperframesRenderService`.

MCP deletion check:

```bash
rg "run_skill_task|list_skills|render_hyperframes_video" \
  packages/sidecar/src/modules/mcp packages/sidecar/tests/http
```

Target: no Sidecar MCP matches. `list_skills` may still exist only inside `packages/agent-runtime`.

Desktop task-first check:

```bash
rg "creation/jobs|planId|jobId|CreationPlanPreviewVm|CreationPlanStepVm|creationJobSteps|_creationJobPollingTimer" \
  packages/desktop/lib packages/desktop/test packages/desktop/translations_data.json
```

Target: no creation-flow matches. Legacy `/books/jobs` payload classes may keep `jobId`.

PostgreSQL persistence check:

```bash
rg "creation/state.json|readRecord|writeRecord|plans: Record|jobs: Record|linkedBookJobs" \
  packages/sidecar/src/modules/creation packages/sidecar/tests
```

Target: no file-backed creation task state.

Package verification:

```bash
npm --prefix packages/agent-runtime run build
npm --prefix packages/sidecar run build
npm --prefix packages/protocol run build
cd packages/desktop && flutter test
./scripts/run-all-tests.sh
```

Generated artifacts:

```bash
npm --prefix packages/sidecar run gen:openapi
npm --prefix packages/protocol run build
```

The final implementation report must distinguish:

- Real external model calls, if any.
- Mocked runtime adapter tests.
- Static checks.
- Generated client regeneration.
- Any environment-blocked verification.

## Decisions Confirmed (2026-05-23)

- Use one-shot breaking migration for creation flow: remove `/creation/jobs`, `planId`, and creation-main-path `jobId` without compatibility aliases.
- Runtime ownership is fully transferred to `@kidmemory/agent-runtime`. Sidecar must not keep runtime execution semantics.
- Delete `HyperframesRenderService` from creation main path and remove it entirely in this migration.
- Delete Sidecar `skills` runtime stack (`SkillRuntimeService`, workspace/permission/runtime MCP path, and related creation wiring). Keep installer-only capability only if a non-creation dependency is proven; rename it away from runtime wording.
- Persist `CreationTask`, `CreationEvent`, and `CreationArtifact` in PostgreSQL for the first task-first release.
- Workspace path is deterministic: `<configured workspaceDir>/creation-tasks/<taskId>`. Return `workspacePath` in task payload for debug and user "open folder" entry.
- Desktop dynamic log view reads Sidecar task events only. Do not read runtime `.jsonl` directly in client.
- Implement an explicit `runtime-event -> creation-event` mapper with whitelist output types for stable UI contracts.
- `POST /creation/tasks/{taskId}/generate` is single-flight: reject repeated trigger while generating.
- Stage timeouts:
  - `plan`: 5 minutes
  - `generate_book`: 15 minutes
  - `generate_video`: 15 minutes
- Timeout handling: mark task as `failed`, set error category to `generation`, and append timeout event.
- This phase does not introduce cancel API.

## Module Deletion Scope (for upcoming implementation review)

Delete unconditionally:

- `packages/sidecar/src/modules/skills/skill-runtime.service.ts`
- `packages/sidecar/src/modules/skills/skill-workspace.service.ts`
- `packages/sidecar/src/modules/skills/skill-permission.service.ts`
- `packages/sidecar/src/modules/mcp/tools/skill-runtime.mcp-tools.ts`
- `packages/sidecar/src/modules/books/providers/openai-sdk-agent-runner.ts`
- `packages/sidecar/src/modules/media/hyperframes-render.service.ts`

Delete unless non-creation installer dependency is proven:

- `packages/sidecar/src/modules/skills/skill-loader.service.ts`
- `packages/sidecar/src/modules/skills/skill-registry.service.ts`
- `packages/sidecar/src/modules/skills/skill-auto-pull.service.ts`
- `packages/sidecar/src/modules/skills/skills.module.ts`
- `packages/sidecar/skills/skill-registry.json`

If kept, rename as installer-only:

- Module and service naming must not include runtime semantics (`runtime`, `execute`, `run_skill_task`).
