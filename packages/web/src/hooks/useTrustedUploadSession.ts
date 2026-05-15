import { useCallback, useEffect, useMemo, useState } from 'react'
import axios from 'axios'
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

    axios.get(`/api/web-companion/sessions/${sessionId}?token=${encodeURIComponent(token)}`)
      .then((response) => {
        if (cancelled) return
        setSession(response.data)
        setSelectedProvider(response.data.providers?.lan?.available ? 'lan' : 'supabase')
        setLoading(false)
      })
      .catch((err) => {
        if (cancelled) return
        setError(err instanceof Error ? err.message : String(err))
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
        const response = await axios.post(`/api/web-companion/sessions/${sessionId}/items`, {
          token,
          provider,
          files: files.map((file, i) => ({
            clientFileId: newTasks[i].id,
            filename: file.name,
            contentType: file.type || 'application/octet-stream',
            sizeBytes: file.size,
          })),
        })

        const data = response.data as { items: UploadItem[] }

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

            await commitUploadItem(sessionId, token, item.uploadItemId, item.objectKey, task.file)

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
        setError(err instanceof Error ? err.message : String(err))
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

async function commitUploadItem(
  sessionId: string,
  token: string,
  uploadItemId: string,
  objectKey: string,
  file: File,
): Promise<void> {
  await axios.put(
    `/api/web-companion/sessions/${sessionId}/items/${uploadItemId}/commit`,
    {
      token,
      objectKey,
      sizeBytes: file.size,
      contentType: file.type || 'application/octet-stream',
    }
  )
}