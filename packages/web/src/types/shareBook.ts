import type { components } from '@kidmemory/protocol/generated/cloud-api/ts'

export type SharedBook = components['schemas']['SharedBookDto'] & {
  description?: string
  previewUrl?: string
  pageCount?: number
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
