# KidMemory Context

This file is the short, stable project context Codex should read at session start.

## Product Language

- **KidMemory**: A local-first family memory workspace for collecting, organizing, searching, generating, reviewing, and publishing children's growth materials.
- **Family memory asset**: A durable item owned by the family, such as a drawing, photo, craft, note, transcript, clip, generated draft, or export.
- **Capture**: Bring materials into KidMemory through desktop import, drag and drop, sample datasets, or mobile upload.
- **Curate**: Maintain children profiles, asset metadata, tags, timeline information, and selected collections.
- **Search**: Locate assets through metadata and semantic retrieval backed by PostgreSQL and pgvector.
- **Compose**: Build the context for a book, portfolio, or export from a child, topic, date range, and selected assets.
- **Generate**: Run an AI agent in a controlled workspace to create structured draft outputs.
- **Review**: Let parents inspect, correct, and approve generated content before export.
- **Publish**: Export approved work as HTML, PDF, or future share/print formats.
- **Archive**: Keep local data, generated outputs, protocol records, and exports recoverable and portable.

## Core Modules

- **Desktop app (`packages/desktop`)**: Flutter macOS app. Owns the main local user experience, starts the sidecar, manages desktop state, and displays import, library, search, generation, preview, and export workflows.
- **Sidecar (`packages/sidecar`)**: Local NestJS service. Owns local APIs, controlled agent workspaces, dataset import, asset processing, local PostgreSQL access, MCP/tool boundaries, and export orchestration.
- **Web Companion (`packages/web`)**: Vite React app for mobile upload, lightweight browsing, and sharing flows.
- **Cloud API (`packages/cloud-api`)**: NestJS service for cloud upload, sharing, device sync, and deployment-facing API behavior.
- **Protocol (`packages/protocol`)**: Shared protocol, OpenAPI artifacts, generated clients, error codes, and cross-package type contracts.

## Architecture Decisions

- KidMemory is local-first. Family data should remain on the user's machine by default.
- Desktop development should use one launch path per debugging session: either Xcode Run or `flutter run -d macos`, not both.
- The sidecar is the trusted boundary for database access, local files, MCP tools, agent workspace setup, validation, and export operations.
- AI agents should work inside controlled workspaces and should not directly access databases, secrets, object storage credentials, or arbitrary local files.
- Generated book artifacts should be structured and validated before they reach preview, export, or publishing flows.
- `packages/protocol` is the contract source for sidecar, cloud API, web, and desktop client integration.

## Agentic Development Workflow

- GitHub Issues are the source of truth for ready implementation tasks.
- Hermes clarifies requirements and creates `status:ready` issues from the project issue template.
- The local Harness is expected to run outside this repository. It may create worktrees, call `gh`, and start `codex exec` workers.
- Codex should execute ready issues conservatively, keep changes scoped, verify before completion, and produce clear PR notes.
