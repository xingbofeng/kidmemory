import { useCallback, useEffect, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { getUploadSession, createUploadItems, commitUploadItem } from '../api/uploadApi'
import { sessionProvidersOf, type SessionSummary, type UploadProvider, type FileTask } from '../types/trustedUpload'
import { nextTaskId, formatRemaining } from '../utils/trustedUploadUtils'
import { resolveTrustedUploadErrorMessage } from './trustedUploadError'
import { uploadFileWithSignedUrl } from '../lib/signed-upload'
import { waitForUploadItemReady } from '../lib/upload-item-ready'

interface UseTrustedUploadSessionProps {
  sessionId: string
  token: string
}

const ACCEPTED_IMAGE_TYPE_SET = new Set(['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif'])

export function useTrustedUploadSession({ sessionId, token }: UseTrustedUploadSessionProps) {
  const { t } = useTranslation()
  const [session, setSession] = useState<SessionSummary | null>(null)
  const [tasks, setTasks] = useState<FileTask[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [selectedProvider, setSelectedProvider] = useState<UploadProvider>('supabase')

  useEffect(() => {
    let cancelled = false
    setLoading(true)
    setError(null)

    getUploadSession(sessionId, token)
      .then((data) => {
        if (cancelled) return
        setSession(data)
        const providers = sessionProvidersOf(data)
        setSelectedProvider(providers.lan?.available ? 'lan' : 'supabase')
        setLoading(false)
      })
      .catch((err) => {
        if (cancelled) return
        setError(resolveTrustedUploadErrorMessage(err, t))
        setLoading(false)
      })

    return () => {
      cancelled = true
    }
  }, [sessionId, token, t])

  const remainingText = useMemo(() => (session ? formatRemaining(session.expiresAt) : t('common.loading')), [session, t])

  const usedCount = (session?.usedItems ?? 0) + tasks.length

  const handleFileSelect = useCallback(
    async (files: File[]) => {
      if (!session || files.length === 0) return

      setError(null)
      if (session.usedItems + tasks.length + files.length > session.maxItems) {
        setError(t('trustedUpload.maxFiles', { max: session.maxItems }))
        return
      }

      const unsupported = files.find((file) => !ACCEPTED_IMAGE_TYPE_SET.has(file.type))
      if (unsupported) {
        setError(t('trustedUpload.unsupportedType', { name: unsupported.name }))
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
        const providers = sessionProvidersOf(session)
        const provider = selectedProvider === 'lan' && providers.lan?.available ? 'lan' : 'supabase'
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
              prev.map((taskItem) =>
                taskItem.id === task.id
                  ? { ...taskItem, status: 'failed', errorMessage: t('trustedUpload.routeUnavailable') }
                  : taskItem,
              ),
            )
            continue
          }

          setTasks((prev) =>
            prev.map((taskItem) =>
              taskItem.id === task.id
                ? {
                    ...taskItem,
                    uploadItemId: item.uploadItemId,
                    objectKey: item.objectKey,
                    status: 'uploading',
                  }
                : taskItem,
            ),
          )

          try {
            await uploadFileWithSignedUrl(task.file, item.signedUpload, (progress) => {
              setTasks((prev) => prev.map((taskItem) => (taskItem.id === task.id ? { ...taskItem, progress } : taskItem)))
            })

            setTasks((prev) =>
              prev.map((taskItem) => (taskItem.id === task.id ? { ...taskItem, status: 'committing' } : taskItem)),
            )

            await commitUploadItem(sessionId, item.uploadItemId, {
              token,
              objectKey: item.objectKey,
              sizeBytes: task.file.size,
              contentType: task.file.type || 'application/octet-stream',
            })

            const ready = await waitForUploadItemReady(sessionId, token, item.uploadItemId)
            if (ready.status !== 'ready') {
              setTasks((prev) =>
                prev.map((taskItem) =>
                  taskItem.id === task.id
                    ? {
                        ...taskItem,
                        status: 'failed',
                        errorMessage: ready.errorMessage ?? t('directUpload.taskImportFailed'),
                      }
                    : taskItem,
                ),
              )
              continue
            }

            setTasks((prev) =>
              prev.map((taskItem) => (taskItem.id === task.id ? { ...taskItem, status: 'success', progress: 100 } : taskItem)),
            )
          } catch (err) {
            setTasks((prev) =>
              prev.map((taskItem) =>
                taskItem.id === task.id
                  ? {
                      ...taskItem,
                      status: 'failed',
                      errorMessage: err instanceof Error ? err.message : String(err),
                    }
                  : taskItem,
              ),
            )
          }
        }
      } catch (err) {
        setError(resolveTrustedUploadErrorMessage(err, t))
      }
    },
    [selectedProvider, session, sessionId, tasks.length, token, t],
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
