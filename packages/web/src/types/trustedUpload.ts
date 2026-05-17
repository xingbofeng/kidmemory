import type { components } from '@kidmemory/protocol/cloud-api'

export type SessionSummary = components['schemas']['SessionSummaryResponseDto']
export type SessionProviderAvailability = { available?: boolean }
export type SessionProviders = {
  lan?: SessionProviderAvailability
  supabase?: SessionProviderAvailability
}
export type SessionChild = { id?: string; displayName?: string }

export function sessionProvidersOf(session: SessionSummary): SessionProviders {
  return (session.providers ?? {}) as SessionProviders
}

export function sessionChildOf(session: SessionSummary): SessionChild {
  return (session.child ?? {}) as SessionChild
}

export type UploadProvider = 'lan' | 'supabase'

export type UploadItem = components['schemas']['CreatedUploadItemDto']

export interface FileTask {
  id: string
  file: File
  uploadItemId?: string
  objectKey?: string
  status: 'pending' | 'uploading' | 'committing' | 'success' | 'failed'
  progress: number
  errorMessage?: string
}
