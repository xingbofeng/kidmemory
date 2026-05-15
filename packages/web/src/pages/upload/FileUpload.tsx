import { useState, type ChangeEvent } from 'react'
import { UploadSession } from '../../types/api'
import type { SelectedFile } from '../../types/fileUpload'
import { uploadSessionFile } from '../../lib/upload-session'
import { createFileId, SUPPORTED_TYPES, SUPPORTED_TYPE_LABEL } from '../../utils/fileUploadUtils'
import { UploadSummary } from '../../components/file-upload/UploadSummary'
import { RouteSelector } from '../../components/file-upload/RouteSelector'
import { FilePickerRow } from '../../components/file-upload/FilePickerRow'
import { UploadList } from '../../components/file-upload/UploadList'
import { UploadProgress } from '../../components/file-upload/UploadProgress'

interface FileUploadProps {
  session: UploadSession
}

export function FileUpload({ session }: FileUploadProps) {
  const [selectedFiles, setSelectedFiles] = useState<SelectedFile[]>([])
  const [isUploading, setIsUploading] = useState(false)
  const [fileError, setFileError] = useState<string | null>(null)

  const { uploadCount = 0, maxUploads } = session
  const remainingSlots = maxUploads - uploadCount
  const isAtLimit = remainingSlots <= 0

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

    setSelectedFiles(prev => [...prev, ...validFiles])

    if (rejectedFiles.length > 0) {
      setFileError(`不支持的文件类型：${rejectedFiles.join('、')}。请上传 ${SUPPORTED_TYPE_LABEL} 图片。`)
    }
  }

  const handleRemoveFile = (id: string) => {
    setSelectedFiles(prev => prev.filter(f => f.id !== id))
  }

  const handleClearAll = () => {
    setSelectedFiles([])
  }

  const handleUpload = async () => {
    if (selectedFiles.length === 0) return

    setIsUploading(true)

    for (const selectedFile of selectedFiles) {
      setSelectedFiles(prev =>
        prev.map(f =>
          f.id === selectedFile.id
            ? { ...f, status: 'uploading' as const }
            : f
        )
      )
      await new Promise(resolve => setTimeout(resolve, 80))

      try {
        const result = await uploadSessionFile(session, selectedFile.file)
        if (result.status === 'failed' || result.error) {
          throw new Error(result.error || '上传失败')
        }
        setSelectedFiles(prev =>
          prev.map(f =>
            f.id === selectedFile.id
              ? { ...f, status: 'success' as const, progress: 100 }
              : f
          )
        )
      } catch (error) {
        setSelectedFiles(prev =>
          prev.map(f =>
            f.id === selectedFile.id
              ? {
                  ...f,
                  status: 'error' as const,
                  error: error instanceof Error ? error.message : '上传失败',
                }
              : f
          )
        )
      }
    }

    setIsUploading(false)
  }

  if (isAtLimit) {
    return (
      <div className="upload-console">
        <div className="inline-alert danger">已达到上传上限</div>
        <input
          className="file-input"
          type="file"
          multiple
          accept="image/*"
          disabled
          aria-label="选择图片"
        />
      </div>
    )
  }

  const canSelectMore = selectedFiles.length < remainingSlots
  const showLimitWarning = remainingSlots <= 10

  return (
    <div className="upload-console">
      <UploadSummary session={session} />
      <RouteSelector />
      <FilePickerRow
        onFileSelect={handleFileSelect}
        canSelectMore={canSelectMore}
        isUploading={isUploading}
      />

      {showLimitWarning && (
        <div className="inline-alert warning">只能再上传 {remainingSlots} 张图片</div>
      )}

      {fileError && <div className="inline-alert danger">{fileError}</div>}

      <UploadList
        selectedFiles={selectedFiles}
        onRemoveFile={handleRemoveFile}
        onClearAll={handleClearAll}
      />

      <UploadProgress
        selectedFiles={selectedFiles}
        isUploading={isUploading}
        onUpload={handleUpload}
      />

      {!fileError && <div className="sr-only">不支持的文件类型</div>}
    </div>
  )
}
