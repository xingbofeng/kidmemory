import type { components } from '@kidmemory/protocol/generated/cloud-api/ts'

type SessionSummarySchema = components['schemas']['SessionSummaryResponseDto']

export type SessionSummary = Omit<SessionSummarySchema, 'child' | 'providers'> & {
  child: {
    id: string
    displayName: string
  }
  providers?: {
    lan?: { available: boolean }
    supabase?: { available: boolean }
  }
}

export type UploadProvider = 'lan' | 'supabase'

export type UploadItem = components['schemas']['CreatedUploadItemDto'] & {
  signedUpload?: {
    method: string
    url: string
    expiresAt: string
    headers: Record<string, string>
  }
}

export interface FileTask {
  id: string
  file: File
  uploadItemId?: string
  objectKey?: string
  status: 'pending' | 'uploading' | 'committing' | 'success' | 'failed'
  progress: number
  errorMessage?: string
}
