/**
 * Web Companion provider-neutral direct upload browser client.
 *
 * 安全约束（必须由本模块守住）：
 *   - 永远只接收非敏感配置（bucket、sessionPath、recommendedClientLimit）。
 *   - object key 必须经 buildDirectUploadObjectKey 生成，文件名必须经 cleanDirectUploadFilename 清洗。
 *   - 浏览器只拿后端签出的 PUT URL，不接触 COS/S3 secret。
 *   - 单张失败不阻塞队列其他文件（per-file try/catch，结果以 discriminated union 返回）。
 *   - 超过 recommendedClientLimit 时拒绝继续添加（体验约束，可被绕过，但 UI 必须提示）。
 *   - 非图片 MIME 拒绝继续添加。
 */

import { buildDirectUploadObjectKey } from './direct-upload-naming'
import { uploadFileWithSignedUrl, type SignedUploadTarget } from './signed-upload'
import i18n from '../i18n'
import type {
  DirectUploadConfig,
  DirectUploadResult,
  ValidateAddFilesResult,
} from './direct-upload-types'

const ALLOWED_IMAGE_MIMES = new Set<string>([
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/heic',
  'image/heif',
  'image/gif',
])

export interface DirectUploadDeps {
  signUpload?: (input: {
    objectKey: string
    contentType: string
    sizeBytes: number
  }) => Promise<SignedUploadTarget>
  uploadWithSignedUrl?: typeof uploadFileWithSignedUrl
}

export interface ValidateAddFilesInput {
  existingCount: number
  newFiles: File[]
  recommendedClientLimit: number
}

export function validateAddFiles({
  existingCount,
  newFiles,
  recommendedClientLimit,
}: ValidateAddFilesInput): ValidateAddFilesResult {
  if (existingCount + newFiles.length > recommendedClientLimit) {
    return {
      ok: false,
      code: 'limit_exceeded',
      limit: recommendedClientLimit,
      message: i18n.t('directUpload.limitExceeded', { limit: recommendedClientLimit }),
    }
  }

  for (const file of newFiles) {
    const mime = (file.type || '').toLowerCase()
    if (!ALLOWED_IMAGE_MIMES.has(mime)) {
      return {
        ok: false,
        code: 'unsupported_mime',
        message: i18n.t('directUpload.unsupportedMime', {
          mime: mime || i18n.t('directUpload.unknownMime'),
        }),
        offendingFile: file,
      }
    }
  }

  return { ok: true, files: newFiles }
}

export interface DirectUploadClient {
  uploadFile: (
    file: File,
    callbacks: { onProgress?: (progress: number) => void },
  ) => Promise<
    | { ok: true; objectKey: string }
    | { ok: false; errorMessage: string }
  >
}

export function createDirectUploadClient(
  config: DirectUploadConfig,
  deps?: DirectUploadDeps,
): DirectUploadClient {
  return {
    async uploadFile(file, callbacks) {
      const objectKey = buildDirectUploadObjectKey({
        sessionId: config.sessionId,
        filename: file.name,
      })
      try {
        callbacks.onProgress?.(0)
        if (!deps?.signUpload) {
          throw new Error('Missing signed upload target signer')
        }
        const signedUpload = await deps.signUpload({
          objectKey,
          contentType: file.type || 'application/octet-stream',
          sizeBytes: file.size,
        })
        await (deps.uploadWithSignedUrl ?? uploadFileWithSignedUrl)(
          file,
          signedUpload,
          (progress) => {
            callbacks.onProgress?.(progress > 1 ? progress / 100 : progress)
          },
        )
        callbacks.onProgress?.(1)
        return { ok: true, objectKey }
      } catch (err) {
        return {
          ok: false,
          errorMessage: err instanceof Error ? err.message : String(err),
        }
      }
    },
  }
}

export interface StartDirectUploadInput {
  files: File[]
  config: DirectUploadConfig
  /** 每个文件进度变化时回调；签名为 (file, progress 0..1)。 */
  onProgress?: (file: File, progress: number) => void
  deps?: DirectUploadDeps
}

/**
 * 结构化错误：超出 recommendedClientLimit 或非图片 MIME。
 * 调用方应捕获并展示「体验约束」提示。
 */
export class DirectUploadValidationError extends Error {
  readonly code: 'limit_exceeded' | 'unsupported_mime'
  readonly limit?: number

  constructor(args: {
    code: 'limit_exceeded' | 'unsupported_mime'
    message: string
    limit?: number
  }) {
    super(args.message)
    this.name = 'DirectUploadValidationError'
    this.code = args.code
    this.limit = args.limit
  }
}

/**
 * 串行上传一组文件到后端签出的对象存储 PUT URL。
 *
 * - 调用前先用 validateAddFiles 检查；不通过则抛 {@link DirectUploadValidationError}。
 * - 每个文件独立 try/catch；任意单张失败不影响其它。
 * - onProgress(file, progress) 在每个文件开始（0）和结束（1）时各触发一次。
 */
export async function startDirectUpload({
  files,
  config,
  onProgress,
  deps,
}: StartDirectUploadInput): Promise<DirectUploadResult[]> {
  const validation = validateAddFiles({
    existingCount: 0,
    newFiles: files,
    recommendedClientLimit: config.recommendedClientLimit,
  })
  if (!validation.ok) {
    if (validation.code === 'limit_exceeded') {
      throw new DirectUploadValidationError({
        code: 'limit_exceeded',
        message: validation.message,
        limit: validation.limit,
      })
    }
    throw new DirectUploadValidationError({
      code: 'unsupported_mime',
      message: validation.message,
    })
  }

  const client = createDirectUploadClient(config, deps)
  const results: DirectUploadResult[] = []

  for (const file of files) {
    const fileResult = await client.uploadFile(file, {
      onProgress: (progress) => onProgress?.(file, progress),
    })
    if (fileResult.ok) {
      results.push({ ok: true, file, objectKey: fileResult.objectKey })
    } else {
      results.push({ ok: false, file, errorMessage: fileResult.errorMessage })
    }
  }

  return results
}
