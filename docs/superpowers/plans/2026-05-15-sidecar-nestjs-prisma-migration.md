# Sidecar NestJS Prisma Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate `packages/backend` into a standard NestJS sidecar with Prisma-managed persistence and clean module boundaries.

**Architecture:** Keep the backend as a local-first NestJS sidecar, not a Next.js API layer. Use Prisma as the database schema and repository implementation layer, while exposing all persistence through module-owned ports and use cases.

**Tech Stack:** Node 22+, NestJS 10, TypeScript, Prisma ORM, PostgreSQL, Zod, Node test runner, OpenAI Agents SDK, Supabase Storage adapter.

---

## Execution Policy

- Work phase by phase; each phase must leave `packages/backend` buildable or clearly document a temporary red state.
- Prefer contract-preserving migrations. If an API response must change, introduce a v2 endpoint first.
- Do not edit unrelated web/desktop files unless the current phase explicitly requires it.
- Keep commits small and Conventional Commit formatted with the Codex co-author trailer.
- During the migration, `PostgresKidMemoryDbService` may coexist with Prisma, but new or migrated module code must not call `db.query` directly.

## File Responsibility Map

### New Backend Foundation

- Create: `packages/backend/prisma/schema.prisma`  
  Owns the canonical database model.

- Create: `packages/backend/src/infrastructure/database/prisma.service.ts`  
  Owns Prisma Client lifecycle and Nest shutdown hooks.

- Create: `packages/backend/src/infrastructure/database/transaction-manager.ts`  
  Owns transaction boundaries exposed to application use cases.

- Create: `packages/backend/src/common/errors/application-errors.ts`  
  Owns stable application/domain error classes.

- Create: `packages/backend/src/common/validation/parse-dto.ts`  
  Owns Zod DTO parsing helpers shared by controllers.

### Agent Config Module

- Create: `packages/backend/src/modules/agent-config/agent-config.module.ts`
- Create: `packages/backend/src/modules/agent-config/presentation/agent-config.controller.ts`
- Create: `packages/backend/src/modules/agent-config/presentation/agent-config.dto.ts`
- Create: `packages/backend/src/modules/agent-config/application/*.use-case.ts`
- Create: `packages/backend/src/modules/agent-config/domain/agent-config.ts`
- Create: `packages/backend/src/modules/agent-config/ports/agent-config.repository.ts`
- Create: `packages/backend/src/modules/agent-config/adapters/prisma-agent-config.repository.ts`

### Web Companion Module

- Split existing `packages/backend/src/modules/web-companion/web-companion.service.ts` into:
  - `upload-session/application`
  - `upload-item/application`
  - `share/application`
  - `browse/application`
  - `pullback/application`

### Books And Export Modules

- Move generation use cases out of `books/providers/books.domain.ts`.
- Move export logic into `modules/export`.
- Move Agent runner implementation into `infrastructure/agents`.

---

## Phase 0: Contract Freeze

**Files:**

- Create: `packages/backend/tests/contracts/http-contracts.test.ts`
- Create: `packages/backend/tests/contracts/backend-contract-client.ts`
- Modify: `packages/backend/package.json`

- [ ] **Step 0.1: Add backend HTTP contract test harness**

Create `packages/backend/tests/contracts/backend-contract-client.ts`:

```ts
import { strict as assert } from "node:assert";

export type ContractResponse<T = unknown> = {
  status: number;
  body: T;
};

export async function requestJson<T>(
  baseUrl: string,
  path: string,
  init: RequestInit = {},
): Promise<ContractResponse<T>> {
  const response = await fetch(`${baseUrl}${path}`, {
    ...init,
    headers: {
      "content-type": "application/json",
      ...(init.headers ?? {}),
    },
  });
  const text = await response.text();
  const body = text.length > 0 ? JSON.parse(text) as T : undefined as T;
  return { status: response.status, body };
}

export function assertObject(value: unknown): asserts value is Record<string, unknown> {
  assert.equal(typeof value, "object");
  assert.notEqual(value, null);
}
```

- [ ] **Step 0.2: Write characterization contracts for critical endpoints**

Create `packages/backend/tests/contracts/http-contracts.test.ts` with tests for:

- `GET /health`
- `GET /api/web-companion/shared/assets?token=invalid`
- `GET /api/web-companion/shared/book?token=invalid`
- `POST /api/books/jobs` validation failure without assets
- Agent config endpoints once available

The tests should assert status codes and response JSON shape only; they should not require a real database until the DB test phase.

- [ ] **Step 0.3: Add contract test script**

Modify `packages/backend/package.json`:

```json
{
  "scripts": {
    "test:contracts": "node --test tests/contracts/*.test.ts"
  }
}
```

- [ ] **Step 0.4: Run contract tests against current implementation**

Run:

```bash
cd packages/backend && npm run test:contracts
```

Expected: contracts either pass or fail with documented current behavior. If they fail because the current behavior is inconsistent, update the assertions to match the desired release contract and mark the endpoint as needing migration.

- [ ] **Step 0.5: Commit Phase 0**

```bash
git add packages/backend/tests/contracts packages/backend/package.json package-lock.json
git commit -m "test(sidecar): freeze backend HTTP contracts" -m "Co-authored-by: OpenAI Codex <codex@openai.com>"
```

---

## Phase 1: Nest Runtime Standardization

**Files:**

- Modify: `packages/backend/package.json`
- Modify: `packages/backend/tsconfig.json`
- Create or modify: `packages/backend/tsconfig.build.json`
- Modify: `packages/backend/src/main.ts`
- Modify: `packages/backend/src/app.module.ts`
- Modify controllers currently using manual decorator registration.

- [ ] **Step 1.1: Add standard runtime tooling**

Install or add dependencies:

```bash
cd packages/backend && npm install -D tsx
```

Change scripts:

```json
{
  "scripts": {
    "dev": "tsx watch src/main.ts",
    "build": "tsc -p tsconfig.build.json",
    "start": "node dist/main.js",
    "test": "find tests -name '*.test.ts' -print0 | xargs -0 node --test"
  }
}
```

- [ ] **Step 1.2: Enable decorators in TypeScript config**

Ensure `packages/backend/tsconfig.json` and `tsconfig.build.json` include:

```json
{
  "compilerOptions": {
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "module": "NodeNext",
    "moduleResolution": "NodeNext"
  }
}
```

- [ ] **Step 1.3: Convert one low-risk controller to standard decorators**

Start with a small controller. Replace manual decorator registration with:

```ts
@Controller("...")
export class ExampleController {
  constructor(private readonly service: ExampleService) {}

  @Get("...")
  async method() {
    return this.service.method();
  }
}
```

Run:

```bash
cd packages/backend && npm run build
```

Expected: build passes.

- [ ] **Step 1.4: Convert remaining controllers incrementally**

Repeat controller conversion one module at a time:

- config / agent-config
- books
- web-companion
- dataset

After each module:

```bash
cd packages/backend && npm run build
cd packages/backend && npm test
```

- [ ] **Step 1.5: Commit Phase 1**

```bash
git add packages/backend
git commit -m "refactor(sidecar): standardize NestJS runtime" -m "Co-authored-by: OpenAI Codex <codex@openai.com>"
```

---

## Phase 2: Prisma Foundation

**Files:**

- Create: `packages/backend/prisma/schema.prisma`
- Create: `packages/backend/src/infrastructure/database/prisma.service.ts`
- Create: `packages/backend/src/infrastructure/database/transaction-manager.ts`
- Modify: `packages/backend/package.json`
- Modify: `packages/backend/src/app.module.ts`
- Create: `packages/backend/tests/integration/prisma-migration.test.ts`

- [ ] **Step 2.1: Add Prisma dependencies**

Run:

```bash
cd packages/backend && npm install @prisma/client && npm install -D prisma
```

- [ ] **Step 2.2: Create initial Prisma schema**

Create `packages/backend/prisma/schema.prisma` with models:

- `Child`
- `Asset`
- `Book`
- `BookPage`
- `BookGenerationJob`
- `ExportArtifact`
- `UploadSession`
- `UploadItem`
- `ShareToken`
- `ShareAccessLog`
- `AgentConfig`
- `AgentRun`
- `BackupSnapshot`

Use PostgreSQL provider and `DATABASE_URL`.

- [ ] **Step 2.3: Generate first migration**

Run:

```bash
cd packages/backend && npx prisma migrate dev --name init
```

Expected: migration generated under `prisma/migrations`.

- [ ] **Step 2.4: Add PrismaService**

Create `packages/backend/src/infrastructure/database/prisma.service.ts`:

```ts
import { Injectable, OnModuleDestroy, OnModuleInit } from "@nestjs/common";
import { PrismaClient } from "@prisma/client";

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
```

- [ ] **Step 2.5: Add transaction manager**

Create `packages/backend/src/infrastructure/database/transaction-manager.ts`:

```ts
import { Injectable } from "@nestjs/common";
import type { Prisma, PrismaClient } from "@prisma/client";
import { PrismaService } from "./prisma.service.ts";

export type PrismaTransaction = Prisma.TransactionClient;

@Injectable()
export class TransactionManager {
  constructor(private readonly prisma: PrismaService) {}

  run<T>(callback: (tx: PrismaTransaction) => Promise<T>): Promise<T> {
    return this.prisma.$transaction(callback);
  }
}
```

- [ ] **Step 2.6: Add migration smoke test**

Create `packages/backend/tests/integration/prisma-migration.test.ts` that:

- Skips if `DATABASE_URL` is missing.
- Runs `npx prisma migrate deploy`.
- Uses Prisma Client to count each core model.

- [ ] **Step 2.7: Commit Phase 2**

```bash
git add packages/backend/prisma packages/backend/src/infrastructure/database packages/backend/tests/integration packages/backend/package.json packages/backend/package-lock.json
git commit -m "feat(sidecar): add Prisma persistence foundation" -m "Co-authored-by: OpenAI Codex <codex@openai.com>"
```

---

## Phase 3: Agent Config And Security

**Files:**

- Modify: `packages/backend/src/modules/security/encryption.service.ts`
- Create: `packages/backend/src/modules/agent-config/**`
- Modify: `packages/backend/src/app.module.ts`
- Modify: `packages/backend/src/modules/books/**` only to consume default agent config.

Tasks:

- Replace CBC/mock tag encryption with AES-256-GCM.
- Move duplicated agent config services into one `modules/agent-config`.
- Persist agent configs through Prisma repository.
- Expose sidecar-backed CRUD/test/default endpoints.
- Ensure Books generation resolves persisted default config instead of request raw key.
- Add tests for encryption tamper detection, default switching, redacted responses, and Books config resolution.

Commit:

```bash
git commit -m "feat(agent-config): persist secure agent settings with Prisma" -m "Co-authored-by: OpenAI Codex <codex@openai.com>"
```

---

## Phase 4: Web Companion Migration

Tasks:

- Split current Web Companion service into upload-session, upload-item, share, browse, pullback use cases.
- Move persistence into Prisma repositories.
- Replace query token for authenticated session APIs with header support while preserving query fallback temporarily.
- Make public share audit metadata come from request IP and headers.
- Add contract and repository tests.

Commit:

```bash
git commit -m "refactor(web-companion): split upload and share use cases" -m "Co-authored-by: OpenAI Codex <codex@openai.com>"
```

---

## Phase 5: Books, Agent Runner, Export

Tasks:

- Extract generation use case from `books.domain.ts`.
- Move export logic into `modules/export`.
- Move OpenAI/Claude runner adapters to `infrastructure/agents`.
- Use persisted AgentConfig for all real generation.
- Keep mock runner only for tests/dev mode.
- Add output validation tests and export path safety tests.

Commit:

```bash
git commit -m "refactor(books): isolate generation and export use cases" -m "Co-authored-by: OpenAI Codex <codex@openai.com>"
```

---

## Phase 6: Dataset And Backup

Tasks:

- Move child/asset persistence to Prisma repositories.
- Add backup manifest and restore use cases.
- Add backup/restore integration tests.
- Ensure restored fresh DB can browse, generate a mocked book, and export metadata.

Commit:

```bash
git commit -m "feat(backup): add Prisma-backed backup and restore" -m "Co-authored-by: OpenAI Codex <codex@openai.com>"
```

---

## Phase 7: Legacy Removal

Tasks:

- Remove business usage of `PostgresKidMemoryDbService`.
- Remove runtime dependency on `sql/001_final_schema.sql`.
- Remove duplicate agent config code.
- Remove direct `body.agentConfig` generation path.
- Run final release gate.

Verification:

```bash
rg -n "db\\.query|pg\\.Pool|001_final_schema|body\\.agentConfig" packages/backend/src
cd packages/backend && npm run build
cd packages/backend && npm test
cd packages/backend && npm run test:contracts
cd packages/web && npm test -- --run
cd packages/web && npm run build
cd packages/desktop && flutter analyze
cd packages/desktop && flutter test
```

Commit:

```bash
git commit -m "refactor(sidecar): remove legacy SQL persistence paths" -m "Co-authored-by: OpenAI Codex <codex@openai.com>"
```
