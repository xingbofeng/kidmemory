/**
 * Web Companion Supabase Direct Upload — 共享类型。
 *
 * 这些类型描述：
 *   - 从 sidecar `POST /web-companion/direct-upload/sessions` 获得的非敏感配置子集；
 *   - Web Companion 内部追踪每张图的状态机；
 *   - startDirectUpload 返回的 discriminated union 结果。
 *
 * 安全约束：本类型集合 **不** 包含 service role key、数据库连接串或本地绝对路径。
 */

export interface DirectUploadConfig {
  /** sidecar 分配的会话 ID，做 storage path 隔离用，非可信会话。 */
  sessionId: string
  /** Supabase Storage bucket 名称。 */
  bucket: string
  /** `{bucket}/{sessionId}` 形式的展示用 path（仅展示，不参与 upload 调用）。 */
  sessionPath: string
  /** 公开的 Supabase 项目 URL（非敏感）。 */
  supabaseUrl: string
  /** 公开 anon key（受 bucket policy 约束）。 */
  anonKey: string
  /** Web Companion 静态部署对外公开 URL（用于二维码或回链）。 */
  publicUrl: string
  /** 体验约束的客户端张数上限，sidecar 默认下发 200。 */
  recommendedClientLimit: number
  /** 体验约束的会话提示有效期（秒），仅前端展示用。 */
  expiresAtHintSeconds: number
  /** 当前会话绑定的 child id，仅展示与日志使用。 */
  childId: string
}

export type DirectUploadFileStatus =
  | 'pending'
  | 'uploading'
  | 'success'
  | 'failed'

export interface DirectUploadFileTask {
  id: string
  file: File
  status: DirectUploadFileStatus
  errorMessage?: string
  objectKey?: string
  /** 0..1 进度。Supabase JS v2 暂不暴露字节级进度，这里以 0/1 切换。 */
  progress: number
}

export type DirectUploadResult =
  | {
      ok: true
      file: File
      objectKey: string
    }
  | {
      ok: false
      file: File
      errorMessage: string
    }

export type ValidateAddFilesError =
  | {
      ok: false
      code: 'limit_exceeded'
      limit: number
      message: string
    }
  | {
      ok: false
      code: 'unsupported_mime'
      message: string
      offendingFile: File
    }

export type ValidateAddFilesResult =
  | {
      ok: true
      files: File[]
    }
  | ValidateAddFilesError
