import { useCallback, useEffect, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { ApiError } from '../api/errors'
import { getDirectUploadConfig, pullbackDirectUpload, signDirectUploadObject } from '../api/uploadApi'
import {
  createDirectUploadClient,
  validateAddFiles,
  DirectUploadValidationError,
  type DirectUploadClient,
} from '../lib/direct-upload-client'
import type { DirectUploadConfig, DirectUploadFileTask } from '../lib/direct-upload-types'

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

function parseConfigFromQuery(params: URLSearchParams): ParsedPartialConfig | ParsedConfigError {
  const sessionId = params.get('sessionId') ?? ''
  const childId = params.get('childId') ?? ''
  const bucket = params.get('bucket') ?? ''
  const supabaseUrl = params.get('supabaseUrl') ?? ''
  const token = params.get('token') ?? ''
  const uploadMode = params.get('uploadMode') === 'signed-url' ? 'signed-url' : 'supabase-js'
  const providerParam = params.get('provider')
  const provider = providerParam === 'cos' || providerParam === 's3' ? providerParam : 'supabase'

  const missing: string[] = []
  if (!sessionId) missing.push('sessionId')
  if (!childId) missing.push('childId')
  if (!bucket) missing.push('bucket')
  if (!supabaseUrl && uploadMode !== 'signed-url') missing.push('supabaseUrl')
  if (!token) missing.push('token')
  if (missing.length > 0) {
    return { ok: false, missing }
  }

  const publicUrl = params.get('publicUrl') ?? ''
  const limitParam = params.get('supabaseDirectUploadLimit')
  const recommendedClientLimit = (() => {
    const parsed = limitParam != null ? Number(limitParam) : Number.NaN
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
      provider,
      uploadMode,
      publicUrl,
      token,
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
  const { t } = useTranslation()
  const params = useMemo(
    () =>
      searchParams
      ?? (typeof window !== 'undefined' ? new URLSearchParams(window.location.search) : new URLSearchParams()),
    [searchParams],
  )

  const parsed = useMemo(() => parseConfigFromQuery(params), [params])

  const [anonKey, setAnonKey] = useState<string | null>(null)
  const [serverConfig, setServerConfig] = useState<Awaited<ReturnType<typeof getDirectUploadConfig>> | null>(null)
  const [anonKeyError, setAnonKeyError] = useState<string | null>(null)

  useEffect(() => {
    if (!parsed.ok) return
    let cancelled = false
    const { sessionId, token } = parsed.partial
    getDirectUploadConfig(sessionId, token)
      .then((data) => {
        if (!cancelled) {
          setServerConfig(data)
          setAnonKey(data.anonKey ?? '')
        }
      })
      .catch((err) => {
        if (!cancelled) {
          const message = err instanceof ApiError ? err.message : err instanceof Error ? err.message : String(err)
          setAnonKeyError(message)
        }
      })
    return () => {
      cancelled = true
    }
  }, [parsed])

  const fullConfig = useMemo((): DirectUploadConfig | null => {
    if (!parsed.ok || anonKey == null) return null
    return {
      ...parsed.partial,
      anonKey,
      provider: serverConfig?.provider ?? parsed.partial.provider,
      uploadMode: serverConfig?.uploadMode ?? parsed.partial.uploadMode,
    }
  }, [parsed, anonKey, serverConfig])

  const [tasks, setTasks] = useState<DirectUploadFileTask[]>([])
  const [validationError, setValidationError] = useState<string | null>(null)
  const [isUploading, setIsUploading] = useState(false)

  const factory = clientFactory ?? ((config: DirectUploadConfig) =>
    createDirectUploadClient(config, {
      signUpload: (input) => signDirectUploadObject(config.sessionId, {
        token: config.token,
        ...input,
      }),
    }))

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
          setValidationError(t('directUpload.experienceHint', { limit: result.limit }))
        } else {
          setValidationError(`Only image files are supported. Ignored: ${result.offendingFile.name}`)
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
          setTasks((prev) => prev.map((item) => (item.id === task.id ? { ...item, status: 'uploading', progress: 0 } : item)))
          try {
            const uploadResult = await client.uploadFile(task.file, {
              onProgress: (progress) => {
                setTasks((prev) => prev.map((item) => (item.id === task.id ? { ...item, progress } : item)))
              },
            })
            if (uploadResult.ok) {
              setTasks((prev) =>
                prev.map((item) =>
                  item.id === task.id
                    ? {
                        ...item,
                        status: 'importing',
                        progress: 1,
                        objectKey: uploadResult.objectKey,
                      }
                    : item,
                ),
              )
              const pullback = await pullbackDirectUpload(fullConfig.sessionId, {
                token: fullConfig.token,
                objectKeys: [uploadResult.objectKey],
              })
              const result = pullback.results.find((item) => item.objectKey === uploadResult.objectKey)
              if (result?.status !== 'ready') {
                setTasks((prev) =>
                  prev.map((item) =>
                    item.id === task.id
                      ? {
                          ...item,
                          status: 'failed',
                          errorMessage: result?.errorMessage ?? t('directUpload.taskImportFailed'),
                        }
                      : item,
                  ),
                )
                continue
              }
              setTasks((prev) =>
                prev.map((item) =>
                  item.id === task.id
                    ? {
                        ...item,
                        status: 'success',
                        progress: 1,
                        objectKey: uploadResult.objectKey,
                      }
                    : item,
                ),
              )
            } else {
              setTasks((prev) =>
                prev.map((item) =>
                  item.id === task.id
                    ? {
                        ...item,
                        status: 'failed',
                        errorMessage: uploadResult.errorMessage,
                      }
                    : item,
                ),
              )
            }
          } catch (err) {
            const message = err instanceof DirectUploadValidationError ? err.message : err instanceof Error ? err.message : String(err)
            setTasks((prev) =>
              prev.map((item) => (item.id === task.id ? { ...item, status: 'failed', errorMessage: message } : item)),
            )
          }
        }
      } finally {
        setIsUploading(false)
      }
    },
    [factory, fullConfig, t, tasks.length],
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
