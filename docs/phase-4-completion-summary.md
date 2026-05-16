# Phase 4 Completion Summary

Date: 2026-05-17

## Scope

Phase 4 focuses on service split and delivery:

- rename `packages/backend` to `packages/sidecar`
- split cloud-facing capabilities into `packages/cloud-api`
- migrate upload/share flows to cloud-api
- keep sidecar focused on local desktop runtime
- establish CI/CD and deployment baselines

## Delivered

- sidecar/cloud-api split completed at repository level
- web upload/share calls moved to cloud-api
- sync-related APIs and sidecar sync loop integrated
- CI workflows for protocol/sidecar/cloud-api/web/desktop created
- deployment pipelines for Tencent Cloud and Vercel established

## Verification Snapshot

- package-level lint/type-check/test/build gates are present
- protocol code generation artifacts are versioned
- sidecar and cloud-api can be built independently
