export interface SessionSummary {
  sessionId: string
  status: string
  child: {
    id: string
    displayName: string
  }
  expiresAt: string
  maxItems: number
  usedItems: number
  providers?: {
    lan?: { available: boolean }
    supabase?: { available: boolean }
  }
}

export type UploadProvider = 'lan' | 'supabase'

export interface UploadItem {
  clientFileId: string
  uploadItemId: string
  assetId: string
  objectKey: string
  status: string
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