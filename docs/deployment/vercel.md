# Vercel Deployment

Web deployment is triggered by `.github/workflows/deploy-vercel.yml`.

The project-level Vercel build command is defined in `vercel.json` and must build
the shared protocol package before the web package:

```bash
cd packages/protocol && npm ci && npm run build && cd ../web && npm ci && npm run build
```

## Required GitHub Secret

- `VERCEL_DEPLOY_HOOK_URL`: deploy hook URL from your Vercel project.

## Trigger Strategy

- Automatically on pushes to `main`.
- Manually via `workflow_dispatch`.

## Environment Variables

Configure runtime variables in Vercel Project Settings:

- `VITE_CLOUD_API_BASE_URL`
- `VITE_SIDECAR_BASE_URL` (if local-network flows are enabled)
- any additional public `VITE_*` values required by `packages/web`

## Verification

After each deployment:

1. Open the deployed domain.
2. Verify upload/share pages load.
3. Validate API connectivity for at least one cloud-api endpoint.
