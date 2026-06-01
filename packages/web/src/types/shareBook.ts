import type { operations } from '@kidmemory/protocol/sidecar'

type JsonResponse<
  OperationId extends keyof operations,
  Status extends keyof operations[OperationId]['responses'],
> = operations[OperationId]['responses'][Status] extends { content: { 'application/json': infer Body } }
  ? Body
  : never

export type SharedBook = JsonResponse<'WebCompanionController_getSharedBook', 200> & {
  description?: string
  previewUrl?: string
  pageCount?: number
}

export type ShareTokenValidation = JsonResponse<'WebCompanionController_accessSharedContent', 200>
