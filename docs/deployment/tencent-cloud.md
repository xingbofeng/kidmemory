# Tencent Cloud Deployment

This document describes the SSH + PM2 deployment path used by `.github/workflows/deploy-tencent.yml`.

## Required GitHub Secrets

- `TENCENT_HOST`
- `TENCENT_USER`
- `TENCENT_SSH_KEY`
- `TENCENT_PORT` (optional, defaults to `22`)
- `TENCENT_PROJECT_PATH` (optional, defaults to `/root/kidmemory`)
- `TENCENT_SMOKE_BASE_URL` (optional, enables post-deploy smoke checks)

## Server Prerequisites

- Node.js 22+
- `npm`
- `pm2`
- project repo already cloned on the server (`TENCENT_PROJECT_PATH`)
- cloud-api runtime `.env` present at `packages/cloud-api/.env`

## Deployment Flow

1. Fetch and reset to `origin/main`.
2. Build and migrate `packages/cloud-api`.
3. Reload PM2 services.
4. Optionally run smoke checks if `TENCENT_SMOKE_BASE_URL` is configured.

## Smoke Endpoint Expectations

- `GET /health` returns `200`
- `GET /docs/openapi.json` returns `200`

## Cloudflare Tunnel Example

See [`scripts/deploy/cloudflared.example.yml`](/Users/counter/workspace/kidmemory/scripts/deploy/cloudflared.example.yml) for an example tunnel config.
