import type { ApiResponse as ProtocolApiResponse } from '@kidmemory/protocol'
import type { components } from '@kidmemory/protocol/cloud-api'

type SessionSummaryDto = components['schemas']['SessionSummaryResponseDto']
type UploadItemResponseDto = components['schemas']['UploadItemResponseDto']

// 0.5 Upload Session Types
export type UploadSession = Omit<SessionSummaryDto, 'child' | 'providers'> & {
  token?: string
  child?: {
    id: string
    displayName: string
  }
  childId?: string
  childName?: string
  maxUploads?: number
  uploadCount?: number
  isValid?: boolean
  providers?: {
    lan?: { available: boolean }
    supabase?: { available: boolean }
  }
}

export interface UploadSessionInput {
  childId: string
}

// 0.5 Upload Types
export interface UploadInput {
  sessionId: string
  token: string
  file: File
}

export type UploadResult = Partial<UploadItemResponseDto> & {
  uploadId?: string
  error?: string
}

export type UploadStatus =
  | 'pending'
  | 'uploading'
  | 'uploaded_remote'
  | 'pulling_local'
  | 'ready'
  | 'failed'

export interface UploadProgress {
  uploadId: string
  progress: number
  status: UploadStatus
  error?: string
}

// Asset types
export interface Asset {
  id: string
  title: string
  thumbnail: string
  type: AssetType
  createdAt: string
  description?: string
  tags?: string[]
}

export type AssetType = 'photo' | 'drawing' | 'craft' | 'other'

export interface AssetFilter {
  type?: AssetType | 'all' | 'recent'
  query?: string
  limit?: number
  offset?: number
}

export interface AssetListResult {
  assets: Asset[]
  total: number
  hasMore: boolean
}

// Book types
export interface Book {
  id: string
  title: string
  cover: string
  pageCount: number
  createdAt: string
  status: BookStatus
  summary?: string
  pdfUrl?: string
  longImageUrl?: string
}

export type BookStatus = 'generating' | 'ready' | 'failed'

export interface BookListResult {
  books: Book[]
  total: number
}

// Share types
export interface ShareInfo {
  bookId: string
  shareUrl: string
  expiresAt?: string
  isPublic: boolean
  copyText?: string
}

// Common Types
export interface ApiError {
  message: string
  code?: string
  details?: Record<string, unknown>
}

export type ApiResponse<T = unknown> = ProtocolApiResponse<T>
