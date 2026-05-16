import { useCallback, useEffect, useMemo, useState } from 'react'
import { ApiError } from '../api/errors'
import { getDirectUploadConfig } from '../api/uploadApi'
import {
  createDirectUploadClient,
  validateAddFiles,
  DirectUploadValidationError,
  type DirectUploadClient,
} from '../lib/direct-upload-client'
import type {
  DirectUploadConfig,
  DirectUploadFileTask,
} from '../lib/direct-upload-types'

const DEFAULT_RECOMMENDED_LIMIT = 200
const DEFAULT_EXPIRES_HINT_SECONDS = 3 * 60 * 60

type ClientFactory = typeof createDirectUploadClient

interface UseDirectUploadTasksProps {
  searchParams?: URLSearchParams
  clientFactory?: ClientFactory
}

interface ParsedPartialConfig {
  ok: true
  partial: Omit<DirectUploadConfig, 'anonKey'>
}

interface ParsedConfigError {
  ok: false
  missing: string[]
}

function parseConfigFromQuery(
  params: URLSearchParams,
): ParsedPartialConfig | ParsedConfigError {
  const sessionId = params.get('sessionId') ?? ''
  const childId = params.get('childId') ?? ''
  const bucket = params.get('bucket') ?? ''
  const supabaseUrl = params.get('supabaseUrl') ?? ''

  const missing: string[] = []
  if (!sessionId) missing.push('sessionId')
  if (!childId) missing.push('childId')
  if (!bucket) missing.push('bucket')
  if (!supabaseUrl) missing.push('supabaseUrl')
  if (missing.length > 0) {
    return { ok: false, missing }
  }

  const publicUrl = params.get('publicUrl') ?? ''
  const limitParam = params.get('supabaseDirectUploadLimit')
  const recommendedClientLimit = (() => {
    const parsed = limitParam != null ? Number(limitParam) : NaN
    if (Number.isFinite(parsed) && parsed > 0) return Math.floor(parsed)
    return DEFAULT_RECOMMENDED_LIMIT
  })()

  return {
    ok: true,
    partial: {
      sessionId,
      childId,
      bucket,
      supabaseUrl,
      publicUrl,
      sessionPath: `${bucket}/${sessionId}`,
      recommendedClientLimit,
      expiresAtHintSeconds: DEFAULT_EXPIRES_HINT_SECONDS,
    },
  }
}

function nextTaskId(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID()
  }
  return `task-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`
}

export function useDirectUploadTasks({ searchParams, clientFactory }: UseDirectUploadTasksProps) {
  const params = useMemo(
    () =>
      searchParams ??
      (typeof window !== 'undefined'
        ? new URLSearchParams(window.location.search)
        : new URLSearchParams()),
    [searchParams],
  )

  const parsed = useMemo(() => parseConfigFromQuery(params), [params])

  const [anonKey, setAnonKey] = useState<string | null>(null)
  const [anonKeyError, setAnonKeyError] = useState<string | null>(null)

  // Load anon key
  useEffect(() => {
    if (!parsed.ok) return
    let cancelled = false
    const { sessionId } = parsed.partial
    getDirectUploadConfig(sessionId)
      .then((data) => {
        if (!cancelled) setAnonKey(data.anonKey)
      })
      .catch((err) => {
        if (!cancelled) {
          const message = err instanceof ApiError ? err.message : (err instanceof Error ? err.message : String(err))
          setAnonKeyError(message)
        }
      })
    return () => { cancelled = true }
  }, [parsed])

  const fullConfig = useMemo((): DirectUploadConfig | null => {
    if (!parsed.ok || !anonKey) return null
    return { ...parsed.partial, anonKey }
  }, [parsed, anonKey])

  const [tasks, setTasks] = useState<DirectUploadFileTask[]>([])
  const [validationError, setValidationError] = useState<string | null>(null)
  const [isUploading, setIsUploading] = useState(false)

  const factory = clientFactory ?? createDirectUploadClient

  const handleFiles = useCallback(
    async (incoming: File[]) => {
      if (!fullConfig) return
      setValidationError(null)

      const result = validateAddFiles({
        existingCount: tasks.length,
        newFiles: incoming,
        recommendedClientLimit: fullConfig.recommendedClientLimit,
      })
      if (!result.ok) {
        if (result.code === 'limit_exceeded') {
          setValidationError(
            `已达到体验约束的张数上限（${result.limit} 张）。这是体验约束，不是安全约束。`,
          )
        } else {
          setValidationError(
            `仅支持图片文件（JPEG/PNG/WebP/HEIC/HEIF/GIF）。已忽略：${result.offendingFile.name}`,
          )
        }
        return
      }

      const newTasks: DirectUploadFileTask[] = result.files.map((file) => ({
        id: nextTaskId(),
        file,
        status: 'pending',
        progress: 0,
      }))
      setTasks((prev) => [...prev, ...newTasks])

      let client: DirectUploadClient
      try {
        client = factory(fullConfig)
      } catch (err) {
        setValidationError(err instanceof Error ? err.message : String(err))
        return
      }

      setIsUploading(true)
      try {
        for (const task of newTasks) {
          setTasks((prev) =>
            prev.map((t) =>
              t.id === task.id ? { ...t, status: 'uploading', progress: 0 } : t,
            ),
          )
          try {
            const r = await client.uploadFile(task.file, {
              onProgress: (p) => {
                setTasks((prev) =>
                  prev.map((t) =>
                    t.id === task.id ? { ...t, progress: p } : t,
                  ),
                )
              },
            })
            if (r.ok) {
              setTasks((prev) =>
                prev.map((t) =>
                  t.id === task.id
                    ? {
                        ...t,
                        status: 'success',
                        progress: 1,
                        objectKey: r.objectKey,
                      }
                    : t,
                ),
              )
            } else {
              setTasks((prev) =>
                prev.map((t) =>
                  t.id === task.id
                    ? {
                        ...t,
                        status: 'failed',
                        errorMessage: r.errorMessage,
                      }
                    : t,
                ),
              )
            }
          } catch (err) {
            const message =
              err instanceof DirectUploadValidationError
                ? err.message
                : err instanceof Error
                  ? err.message
                  : String(err)
            setTasks((prev) =>
              prev.map((t) =>
                t.id === task.id
                  ? { ...t, status: 'failed', errorMessage: message }
                  : t,
              ),
            )
          }
        }
      } finally {
        setIsUploading(false)
      }
    },
    [factory, fullConfig, tasks.length],
  )

  return {
    parsed,
    anonKey,
    anonKeyError,
    fullConfig,
    tasks,
    validationError,
    isUploading,
    handleFiles,
  }
}