/**
 * Web Companion Supabase Direct Upload browser client.
 *
 * 安全约束（必须由本模块守住）：
 *   - 永远只接收非敏感配置（bucket、sessionPath、supabaseUrl、anonKey、recommendedClientLimit）。
 *   - object key 必须经 buildDirectUploadObjectKey 生成，文件名必须经 cleanDirectUploadFilename 清洗。
 *   - 单张失败不阻塞队列其他文件（per-file try/catch，结果以 discriminated union 返回）。
 *   - 超过 recommendedClientLimit 时拒绝继续添加（体验约束，可被绕过，但 UI 必须提示）。
 *   - 非图片 MIME 拒绝继续添加。
 *
 * 实现说明：
 *   - 真实生产路径下使用 `@supabase/supabase-js` 的 createClient(...).storage.from(bucket).upload(...)。
 *   - 测试通过 deps.createClient 注入 fake；默认实现使用 dynamic import，避免在 SSR/未配置环境下提前抓取。
 */

import { buildDirectUploadObjectKey } from './direct-upload-naming'
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

/**
 * 注入式 createClient 类型，匹配 `@supabase/supabase-js` 的 minimal shape。
 * 测试可以传入 vi.fn() 实现，避免引入真正的 SDK。
 */
export type DirectUploadCreateClient = (
  url: string,
  key: string,
) => DirectUploadSupabaseClient

export interface DirectUploadSupabaseClient {
  storage: {
    from: (bucket: string) => DirectUploadStorageBucket
  }
}

export interface DirectUploadStorageBucket {
  upload: (
    objectKey: string,
    file: File,
    options: { contentType: string; upsert?: boolean },
  ) => Promise<{
    data: { path: string } | null
    error: { message: string } | null
  }>
}

export interface DirectUploadDeps {
  createClient?: DirectUploadCreateClient
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
      message: `单次最多上传 ${recommendedClientLimit} 张（体验约束，非安全约束）`,
    }
  }

  for (const file of newFiles) {
    const mime = (file.type || '').toLowerCase()
    if (!ALLOWED_IMAGE_MIMES.has(mime)) {
      return {
        ok: false,
        code: 'unsupported_mime',
        message: `仅支持图片文件（JPEG/PNG/WebP/HEIC/HEIF/GIF），收到：${mime || '未知类型'}`,
        offendingFile: file,
      }
    }
  }

  return { ok: true, files: newFiles }
}

/**
 * 默认 createClient 实现：dynamic import @supabase/supabase-js。
 * 使用 dynamic import 是为了让测试可以完全跳过 SDK 加载（通过 deps.createClient 覆盖）。
 */
async function defaultCreateClient(
  url: string,
  key: string,
): Promise<DirectUploadSupabaseClient> {
  const mod = await import('@supabase/supabase-js')
  return mod.createClient(url, key) as unknown as DirectUploadSupabaseClient
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

/**
 * 创建一个绑定到具体 DirectUploadConfig 的 client；内部维护 supabase client 引用。
 * 当 deps.createClient 为同步函数（测试场景）时，立即解析；否则首次调用 uploadFile 时 lazy 解析。
 */
export function createDirectUploadClient(
  config: DirectUploadConfig,
  deps?: DirectUploadDeps,
): DirectUploadClient {
  let supabaseClient: DirectUploadSupabaseClient | null = null
  let pending: Promise<DirectUploadSupabaseClient> | null = null

  const ensureClient = (): Promise<DirectUploadSupabaseClient> => {
    if (supabaseClient) return Promise.resolve(supabaseClient)
    if (pending) return pending

    pending = (async () => {
      if (deps?.createClient) {
        const c = deps.createClient(config.supabaseUrl, config.anonKey)
        // deps.createClient may be sync (tests) or async (defensive)
        const resolved = (await Promise.resolve(c)) as DirectUploadSupabaseClient
        supabaseClient = resolved
        return resolved
      }
      const resolved = await defaultCreateClient(config.supabaseUrl, config.anonKey)
      supabaseClient = resolved
      return resolved
    })()
    return pending
  }

  return {
    async uploadFile(file, callbacks) {
      const objectKey = buildDirectUploadObjectKey({
        sessionId: config.sessionId,
        filename: file.name,
      })
      try {
        const client = await ensureClient()
        callbacks.onProgress?.(0)
        const { data, error } = await client.storage
          .from(config.bucket)
          .upload(objectKey, file, {
            contentType: file.type || 'application/octet-stream',
            upsert: false,
          })
        callbacks.onProgress?.(1)
        if (error || !data) {
          return {
            ok: false,
            errorMessage: error?.message ?? '上传失败：未知错误',
          }
        }
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
 * 串行上传一组文件到 Supabase Storage。
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
