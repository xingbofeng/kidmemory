# CI/CD Overview

This repository uses GitHub Actions for both CI and CD.

## CI Workflows

- `ci.yml`: full monorepo checks for sidecar, cloud-api, web, and desktop.
- `protocol-ci.yml`: protocol package checks, tests, and code generation verification.
- `cloud-api-ci.yml`: focused cloud-api lint/test/build checks.
- `acceptance.yml`: contract, integration, and smoke gates after package checks.

## CD Workflows

- `deploy-tencent.yml`: deploys `packages/cloud-api` to Tencent Cloud via SSH and reloads PM2.
- `deploy-vercel.yml`: triggers Vercel deployment using a deploy hook.
- `desktop-release.yml`: builds desktop macOS artifacts on `v*-alpha` tags and publishes a GitHub prerelease.

## Notes

- CI runs on Node.js 22 and uses package-local lockfiles for cache keys.
- Sidecar and acceptance jobs use PostgreSQL + pgvector (`pgvector/pgvector:pg16`).
- OpenAPI generated artifacts must remain in sync under `packages/protocol/generated/`.
