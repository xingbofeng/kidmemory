# KidMemory Context

This file is the short, stable project context Codex should read at session start.

## Product Language

- **KidMemory**: A local-first family memory workspace for collecting, organizing, searching, generating, reviewing, and publishing children's growth materials.
- **Family memory asset**: A durable item owned by the family, such as a drawing, photo, craft, note, transcript, clip, generated draft, or export.
- **Capture**: Bring materials into KidMemory through desktop import, drag and drop, sample datasets, or mobile upload.
- **Curate**: Maintain children profiles, asset metadata, tags, timeline information, and selected collections.
- **Search**: Locate assets through metadata and semantic retrieval backed by PostgreSQL and pgvector.
- **Compose**: Build the context for a book, portfolio, or export from a child, topic, date range, and selected assets.
- **Plan**: Produce and persist an agent-executable creation plan from the user goal, selected assets, and generation settings.
- **Generate**: Run an AI agent in a controlled workspace to create structured draft outputs.
- **Review**: Let parents inspect, correct, and approve generated content before export.
- **Publish**: Export approved work as HTML, PDF, or future share/print formats.
- **Archive**: Keep local data, generated outputs, protocol records, and exports recoverable and portable.

## Canonical Creation Flow

- The canonical 5-step creation flow is: **Compose -> Plan -> Generate -> Review -> Publish**.
- UI stage labels, API status/step fields, and activity logs should use this canonical vocabulary.
- Plan confirmation is a hard gate: no generation job should be created before a persisted plan is confirmed.
- The only valid creation type enum values are: `storybook`, `memory_book`, `memoir_video`.
- For `memoir_video`, missing FFmpeg should be handled via silent auto-repair through the existing setup/install runner, with install progress and failures visible in activity logs.
- Share confirmation should happen exactly once before web share-link creation in the **Publish** stage.
- Failures should be represented as stage-scoped failures with root-cause categories: `asset_validation`, `planning`, `generation`, `skill`, `hyperframes`, `export`, `share`, `environment`.

## Core Modules

- **Desktop app (`packages/desktop`)**: Flutter macOS app. Owns the main local user experience, starts the sidecar, manages desktop state, and displays import, library, search, generation, preview, and export workflows.
- **Sidecar (`packages/sidecar`)**: Local NestJS service. Owns local APIs, controlled agent workspaces, dataset import, asset processing, local PostgreSQL access, MCP/tool boundaries, and export orchestration.
- **Web Companion (`packages/web`)**: Vite React app for mobile upload, lightweight browsing, and sharing flows.
- **Cloud API (`packages/cloud-api`)**: NestJS service for cloud upload, sharing, device sync, and deployment-facing API behavior.
- **Protocol (`packages/protocol`)**: Shared protocol, OpenAPI artifacts, generated clients, error codes, and cross-package type contracts.
- **Creation Orchestrator (`/creation/jobs`)**: Workflow orchestration entry that composes existing generation, agent, skill, export, and share capabilities instead of reimplementing them.

## Architecture Decisions

- KidMemory is local-first. Family data should remain on the user's machine by default.
- Desktop development should use one launch path per debugging session: either Xcode Run or `flutter run -d macos`, not both.
- The sidecar is the trusted boundary for database access, local files, MCP tools, agent workspace setup, validation, and export operations.
- `/creation/jobs` should act as an orchestration layer. If legacy endpoints are fully covered and verified by the new path, they can be removed directly with their obsolete tests.
- AI agents should work inside controlled workspaces and should not directly access databases, secrets, object storage credentials, or arbitrary local files.
- Generated book artifacts should be structured and validated before they reach preview, export, or publishing flows.
- `packages/protocol` is the contract source for sidecar, cloud API, web, and desktop client integration.

## Agentic Development Workflow

- Current MVP follows the article-style Slack agent army flow: Slack channel -> overseer Hermes -> product manager Hermes -> developer Hermes -> tmux -> Codex CLI -> GitHub PR -> tester / human review.
- Hermes clarifies requirements, coordinates agents, and starts long-running work through scripts; Hermes gateway should not block on long coding tasks.
- Long-running Codex work should run in an isolated git worktree through `scripts/agent-codex-tmux-run.sh`.
- GitHub PRs are the delivery boundary. GitHub Issues remain useful for complex tasks and archival facts, and may become the hard source of truth again when the full Harness daemon is implemented.
- The full Harness workflow is documented for later evolution, but it is not the first runtime target.
