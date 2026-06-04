import type { operations } from '@kidmemory/protocol/sidecar'

type JsonResponse<
  OperationId extends keyof operations,
  Status extends keyof operations[OperationId]['responses'],
> = operations[OperationId]['responses'][Status] extends { content: { 'application/json': infer Body } }
  ? Body
  : never

export type SessionSummary = JsonResponse<'WebCompanionController_getSessionSummary', 200>
export type SessionDetail = JsonResponse<'WebCompanionController_getSessionDetail', 200>
export type RecentUpload = JsonResponse<'WebCompanionController_getRecentUploads', 200>[number]
export type SessionProviderAvailability = { available?: boolean }
export type SessionProviders = {
  lan?: SessionProviderAvailability
  cos?: SessionProviderAvailability
}
export type SessionChild = { id?: string; displayName?: string }

export function sessionProvidersOf(session: SessionSummary): SessionProviders {
  return (session.providers ?? {}) as SessionProviders
}

export function sessionChildOf(session: SessionSummary): SessionChild {
  return (session.child ?? {}) as SessionChild
}

export type UploadProvider = 'lan' | 'cos'

export type UploadItem = JsonResponse<'WebCompanionController_createUploadItems', 201>['items'][number]

export interface FileTask {
  id: string
  file: File
  uploadItemId?: string
  objectKey?: string
  status: 'pending' | 'uploading' | 'committing' | 'success' | 'failed'
  progress: number
  errorMessage?: string
}
