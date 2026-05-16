import type { components } from '@kidmemory/protocol/generated/cloud-api/ts'

export type SharedAsset = components['schemas']['SharedAssetDto'] & {
  previewUrl?: string
}

export type ShareTokenValidation = Omit<components['schemas']['ShareTokenValidationResponseDto'], 'shareToken'> & {
  shareToken?: {
    id: string
    childId: string
    resourceType: string
    resourceId?: string
    accessType: string
  }
}
