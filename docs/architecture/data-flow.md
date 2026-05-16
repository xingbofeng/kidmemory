# Data Flow

## Upload Flow (Web -> Cloud)

1. Web client starts upload session on cloud-api.
2. File metadata/items are committed in cloud-api.
3. Cloud records pending-sync items for devices.

## Sync Flow (Cloud -> Sidecar)

1. Sidecar sends heartbeat and polls pending upload items.
2. Sidecar downloads assets and imports into local storage.
3. Sidecar reports sync status back to cloud-api.

## Job Flow (Cloud -> Sidecar -> Cloud)

1. Sidecar polls pending jobs by device.
2. Sidecar executes local processing/generation.
3. Sidecar reports job status/progress and completion.

## Share Flow (Web -> Cloud)

1. Web resolves share token and resource metadata via cloud-api.
2. Access policies/rate limits are enforced in cloud-api.
3. Access logs are written in cloud persistence.
