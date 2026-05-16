import { useCallback, useEffect, useMemo, useState } from 'react'
import { ApiError } from '../api/errors'
import { getUploadSession, createUploadItems, commitUploadItem } from '../api/uploadApi'
import type { SessionSummary, UploadProvider, UploadItem, FileTask } from '../types/trustedUpload'
import { nextTaskId, formatRemaining } from '../utils/trustedUploadUtils'

interface UseTrustedUploadSessionProps {
  sessionId: string
  token: string
}

const ACCEPTED_IMAGE_TYPE_SET = new Set(['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif'])

export function useTrustedUploadSession({ sessionId, token }: UseTrustedUploadSessionProps) {
  const [session, setSession] = useState<SessionSummary | null>(null)
  const [tasks, setTasks] = useState<FileTask[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [selectedProvider, setSelectedProvider] = useState<UploadProvider>('supabase')

  // Load session data
  useEffect(() => {
    let cancelled = false
    setLoading(true)
    setError(null)

    getUploadSession(sessionId, token)
      .then((data) => {
        if (cancelled) return
        setSession(data)
        setSelectedProvider(data.providers?.lan?.available ? 'lan' : 'supabase')
        setLoading(false)
      })
      .catch((err) => {
        if (cancelled) return
        const message = err instanceof ApiError ? err.message : (err instanceof Error ? err.message : String(err))
        setError(message)
        setLoading(false)
      })

    return () => {
      cancelled = true
    }
  }, [sessionId, token])

  const remainingText = useMemo(
    () => (session ? formatRemaining(session.expiresAt) : '加载中'),
    [session],
  )

  const usedCount = (session?.usedItems ?? 0) + tasks.length

  const handleFileSelect = useCallback(
    async (files: File[]) => {
      if (!session || files.length === 0) return

      setError(null)
      if (session.usedItems + tasks.length + files.length > session.maxItems) {
        setError(`最多只能上传 ${session.maxItems} 个文件`)
        return
      }

      const unsupported = files.find((file) => !ACCEPTED_IMAGE_TYPE_SET.has(file.type))
      if (unsupported) {
        setError(`仅支持 JPG、PNG、WebP、HEIC/HEIF 图片：${unsupported.name}`)
        return
      }

      const newTasks: FileTask[] = files.map((file) => ({
        id: nextTaskId(),
        file,
        status: 'pending',
        progress: 0,
      }))

      setTasks((prev) => [...prev, ...newTasks])

      try {
        const provider = selectedProvider === 'lan' && session.providers?.lan?.available
          ? 'lan'
          : 'supabase'
        const data = await createUploadItems(sessionId, {
          token,
          provider,
          files: files.map((file, i) => ({
            clientFileId: newTasks[i].id,
            filename: file.name,
            contentType: file.type || 'application/octet-stream',
            sizeBytes: file.size,
          })),
        })

        for (let i = 0; i < data.items.length; i++) {
          const item = data.items[i]
          const task = newTasks[i]

          if (!item.signedUpload) {
            setTasks((prev) =>
              prev.map((t) =>
                t.id === task.id
                  ? { ...t, status: 'failed', errorMessage: '当前上传路线暂不可用，请切换公网直传' }
                  : t,
              ),
            )
            continue
          }

          setTasks((prev) =>
            prev.map((t) =>
              t.id === task.id
                ? {
                    ...t,
                    uploadItemId: item.uploadItemId,
                    objectKey: item.objectKey,
                    status: 'uploading',
                  }
                : t,
            ),
          )

          try {
            await uploadFileWithSignedUrl(task.file, item.signedUpload, (progress) => {
              setTasks((prev) =>
                prev.map((t) => (t.id === task.id ? { ...t, progress } : t)),
              )
            })

            setTasks((prev) =>
              prev.map((t) => (t.id === task.id ? { ...t, status: 'committing' } : t)),
            )

            await commitUploadItem(sessionId, item.uploadItemId, {
              token,
              objectKey: item.objectKey,
              sizeBytes: task.file.size,
              contentType: task.file.type || 'application/octet-stream',
            })

            setTasks((prev) =>
              prev.map((t) =>
                t.id === task.id ? { ...t, status: 'success', progress: 100 } : t,
              ),
            )
          } catch (err) {
            setTasks((prev) =>
              prev.map((t) =>
                t.id === task.id
                  ? {
                      ...t,
                      status: 'failed',
                      errorMessage: err instanceof Error ? err.message : String(err),
                    }
                  : t,
              ),
            )
          }
        }
      } catch (err) {
        const message = err instanceof ApiError ? err.message : (err instanceof Error ? err.message : String(err))
        setError(message)
      }
    },
    [selectedProvider, session, sessionId, tasks.length, token],
  )

  const handleClearTasks = useCallback(() => {
    setTasks([])
  }, [])

  return {
    session,
    tasks,
    loading,
    error,
    selectedProvider,
    remainingText,
    usedCount,
    setSelectedProvider,
    handleFileSelect,
    handleClearTasks,
  }
}

async function uploadFileWithSignedUrl(
  file: File,
  signedUpload: UploadItem['signedUpload'],
  onProgress: (progress: number) => void,
): Promise<void> {
  if (!signedUpload) throw new Error('Missing signed upload target')
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest()

    xhr.upload.addEventListener('progress', (event) => {
      if (event.lengthComputable) {
        onProgress(Math.round((event.loaded / event.total) * 100))
      }
    })

    xhr.addEventListener('load', () => {
      if (xhr.status >= 200 && xhr.status < 300) resolve()
      else reject(new Error(`上传失败 (${xhr.status})`))
    })
    xhr.addEventListener('error', () => reject(new Error('上传失败：网络错误')))

    xhr.open(signedUpload.method, signedUpload.url)
    Object.entries(signedUpload.headers).forEach(([key, value]) => {
      xhr.setRequestHeader(key, value)
    })
    xhr.send(file)
  })
}