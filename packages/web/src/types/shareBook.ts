import type { components } from '@kidmemory/protocol/cloud-api'

export type SharedBook = components['schemas']['SharedBookDto'] & {
  description?: string
  previewUrl?: string
  pageCount?: number
}

export type ShareTokenValidation = components['schemas']['ShareTokenValidationResponseDto']
