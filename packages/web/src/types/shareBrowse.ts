import type { components } from '@kidmemory/protocol/cloud-api'

export type SharedAsset = components['schemas']['SharedAssetDto'] & {
  previewUrl?: string
}

export type ShareTokenValidation = components['schemas']['ShareTokenValidationResponseDto']
