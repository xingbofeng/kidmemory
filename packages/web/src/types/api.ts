// 0.5 Upload Session Types
export interface UploadSession {
  sessionId: string
  token: string
  expiresAt: string
  childId: string
  childName: string
  maxUploads: number
  uploadCount?: number
  isValid?: boolean
}

export interface UploadSessionRequest {
  childId: string
}

// 0.5 Upload Types
export interface UploadRequest {
  sessionId: string
  token: string
  file: File
}

export interface UploadResponse {
  uploadId: string
  objectKey: string
  status: UploadStatus
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

export interface AssetListResponse {
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

export interface BookListResponse {
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

export interface ApiResponse<T> {
  data?: T
  error?: ApiError
}
