import type { operations } from '@kidmemory/protocol/sidecar'

type JsonResponse<
  OperationId extends keyof operations,
  Status extends keyof operations[OperationId]['responses'],
> = operations[OperationId]['responses'][Status] extends { content: { 'application/json': infer Body } }
  ? Body
  : never

export type SharedAsset = JsonResponse<'WebCompanionController_getSharedAssets', 200>[number] & {
  previewUrl?: string
}

export type ShareTokenValidation = JsonResponse<'WebCompanionController_accessSharedContent', 200>
