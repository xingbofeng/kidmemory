# Service Split Architecture

## Responsibility Boundary

- `packages/sidecar`
  - local desktop API
  - local dataset/index/search/book generation orchestration
  - local persistence and local-first resilience
- `packages/cloud-api`
  - cloud upload/share/session lifecycle
  - device registration and sync coordination endpoints
  - cloud data persistence

## Communication Flow

1. Web clients call cloud-api for upload/share workflows.
2. Sidecar registers itself to cloud-api and sends heartbeat.
3. Sidecar polls sync endpoints and materializes local assets/jobs.

## Design Constraints

- sidecar local features must continue working when cloud-api is unavailable.
- cloud-api should not assume local sidecar process availability.
- shared contracts are expressed via `packages/protocol`.
