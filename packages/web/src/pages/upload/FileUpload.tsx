import { useEffect, useMemo, useState, type ChangeEvent } from 'react'
import { useTranslation } from 'react-i18next'
import { UploadSession } from '../../types/api'
import type { SelectedFile } from '../../types/fileUpload'
import { createFileId, SUPPORTED_TYPES, SUPPORTED_TYPE_LABEL } from '../../utils/fileUploadUtils'
import { UploadSummary } from '../../components/file-upload/UploadSummary'
import { RouteSelector } from '../../components/file-upload/RouteSelector'
import { FilePickerRow } from '../../components/file-upload/FilePickerRow'
import { UploadList } from '../../components/file-upload/UploadList'
import { UploadProgress } from '../../components/file-upload/UploadProgress'
import { commitUploadItem, createUploadItems } from '../../api/uploadApi'
import type { UploadProvider } from '../../types/trustedUpload'
import { uploadFileWithSignedUrl } from '../../lib/signed-upload'
import { waitForUploadItemReady } from '../../lib/upload-item-ready'

interface FileUploadProps {
  session: UploadSession
  sessionToken?: string
}

export function FileUpload({ session, sessionToken }: FileUploadProps) {
  const { t } = useTranslation()
  const [selectedFiles, setSelectedFiles] = useState<SelectedFile[]>([])
  const [isUploading, setIsUploading] = useState(false)
  const [fileError, setFileError] = useState<string | null>(null)

  const { uploadCount = 0, maxUploads, maxItems } = session
  const remainingSlots = Math.max(0, (maxUploads ?? maxItems ?? 0) - uploadCount)
  const isAtLimit = remainingSlots <= 0
  const resolvedToken = sessionToken ?? session.token ?? ''
  const providers = useMemo(() => ({
    lan: {
      available: Boolean((session.providers as { lan?: { available?: boolean } } | undefined)?.lan?.available),
    },
    cos: {
      available: (session.providers as { cos?: { available?: boolean } } | undefined)?.cos?.available !== false,
    },
  }), [session.providers])
  const [selectedProvider, setSelectedProvider] = useState<UploadProvider>(providers.lan.available ? 'lan' : 'cos')
  const hasAvailableProvider = providers.lan.available || providers.cos.available

  useEffect(() => {
    setSelectedProvider((current) => {
      if (providers[current].available) return current
      return providers.lan.available ? 'lan' : 'cos'
    })
  }, [providers])

  const handleFileSelect = (event: ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(event.target.files || [])

    const validFiles: SelectedFile[] = []
    const rejectedFiles: string[] = []
    setFileError(null)

    for (const file of files) {
      if (!SUPPORTED_TYPES.includes(file.type)) {
        rejectedFiles.push(file.name)
        continue
      }

      if (validFiles.length + selectedFiles.length >= remainingSlots) {
        break
      }

      validFiles.push({
        file,
        id: createFileId(file),
        status: 'pending',
        progress: 0,
      })
    }

    setSelectedFiles((prev) => [...prev, ...validFiles])

    if (rejectedFiles.length > 0) {
      setFileError(t('upload.unsupportedType', { files: rejectedFiles.join('、'), label: SUPPORTED_TYPE_LABEL }))
    }
  }

  const handleRemoveFile = (id: string) => {
    setSelectedFiles((prev) => prev.filter((file) => file.id !== id))
  }

  const handleClearAll = () => {
    setSelectedFiles([])
  }

  const handleUpload = async () => {
    if (selectedFiles.length === 0) return

    setIsUploading(true)

    if (!hasAvailableProvider || !providers[selectedProvider].available) {
      setFileError(t('upload.routeUnavailable'))
      setIsUploading(false)
      return
    }

    const provider: UploadProvider = selectedProvider
    try {
      const response = await createUploadItems(session.sessionId, {
        token: resolvedToken,
        provider,
        files: selectedFiles.map((selectedFile) => ({
          clientFileId: selectedFile.id,
          filename: selectedFile.file.name,
          contentType: selectedFile.file.type || 'application/octet-stream',
          sizeBytes: selectedFile.file.size,
        })),
      })

      for (let index = 0; index < response.items.length; index += 1) {
        const selectedFile = selectedFiles[index]
        const item = response.items[index]
        if (!selectedFile || !item) continue

        if (!item.signedUpload) {
          setSelectedFiles((prev) =>
            prev.map((file) =>
              file.id === selectedFile.id
                ? { ...file, status: 'error' as const, error: t('upload.uploadFailed') }
                : file,
            ),
          )
          continue
        }

        try {
          setSelectedFiles((prev) =>
            prev.map((file) => (file.id === selectedFile.id ? { ...file, status: 'uploading' as const } : file)),
          )
          await uploadFileWithSignedUrl(selectedFile.file, item.signedUpload, (progress) => {
            setSelectedFiles((prev) =>
              prev.map((file) => (file.id === selectedFile.id ? { ...file, progress } : file)),
            )
          })
          setSelectedFiles((prev) =>
            prev.map((file) =>
              file.id === selectedFile.id ? { ...file, status: 'committing' as const, progress: 100 } : file,
            ),
          )

          await commitUploadItem(session.sessionId, item.uploadItemId, {
            token: resolvedToken,
            objectKey: item.objectKey,
            sizeBytes: selectedFile.file.size,
            contentType: selectedFile.file.type || 'application/octet-stream',
          })

          const ready = await waitForUploadItemReady(session.sessionId, resolvedToken, item.uploadItemId)
          if (ready.status !== 'ready') {
            setSelectedFiles((prev) =>
              prev.map((file) =>
                file.id === selectedFile.id
                  ? { ...file, status: 'error' as const, error: ready.errorMessage ?? t('directUpload.taskImportFailed') }
                  : file,
              ),
            )
            continue
          }

          setSelectedFiles((prev) =>
            prev.map((file) =>
              file.id === selectedFile.id ? { ...file, status: 'success' as const, progress: 100 } : file,
            ),
          )
        } catch (error) {
          const message = error instanceof Error ? error.message : t('upload.uploadFailed')
          setSelectedFiles((prev) =>
            prev.map((file) =>
              file.id === selectedFile.id ? { ...file, status: 'error' as const, error: message } : file,
            ),
          )
          setFileError(message)
        }
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : t('upload.uploadFailed')
      setFileError(message)
    }

    setIsUploading(false)
  }

  if (isAtLimit) {
    return (
      <div className="upload-console">
        <div className="inline-alert danger">{t('upload.atLimit')}</div>
        <input className="file-input" type="file" multiple accept="image/*" disabled aria-label={t('upload.selectImage')} />
      </div>
    )
  }

  const canSelectMore = selectedFiles.length < remainingSlots
  const showLimitWarning = remainingSlots <= 10

  return (
    <div className="upload-console">
      <UploadSummary session={session} />
      <RouteSelector selectedProvider={selectedProvider} providers={providers} onSelect={setSelectedProvider} />
      <FilePickerRow onFileSelect={handleFileSelect} canSelectMore={canSelectMore} isUploading={isUploading} />

      {showLimitWarning && <div className="inline-alert warning">{t('upload.canUploadOnly', { count: remainingSlots })}</div>}
      {fileError && <div className="inline-alert danger">{fileError}</div>}

      <UploadList selectedFiles={selectedFiles} onRemoveFile={handleRemoveFile} onClearAll={handleClearAll} />

      <UploadProgress
        selectedFiles={selectedFiles}
        isUploading={isUploading}
        disabled={!hasAvailableProvider}
        onUpload={handleUpload}
      />

      {!fileError && <div className="sr-only">{t('upload.unsupportedTypeSr')}</div>}
    </div>
  )
}
