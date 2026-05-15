import { useRef, type ChangeEvent } from 'react'
import type { DirectUploadConfig } from '../../lib/direct-upload-types'

interface UploadControlsProps {
  config: DirectUploadConfig
  successCount: number
  totalSelected: number
  isUploading: boolean
  validationError: string | null
  onFilesSelected: (files: File[]) => void
}

export function UploadControls({
  config,
  successCount,
  totalSelected,
  isUploading,
  validationError,
  onFilesSelected
}: UploadControlsProps) {
  const fileInputRef = useRef<HTMLInputElement>(null)

  const onPickerChange = (event: ChangeEvent<HTMLInputElement>) => {
    const list = Array.from(event.target.files ?? [])
    // reset input to allow same-file reselection later
    if (fileInputRef.current) fileInputRef.current.value = ''
    if (list.length === 0) return
    onFilesSelected(list)
  }

  return (
    <div className="upload-console">
      <div className="upload-summary">
        <span>
          已上传成功：<strong>{successCount}</strong>
        </span>
        <span>当前队列：{totalSelected} 张</span>
      </div>

      <div className="picker-row">
        <label className="picker-tile">
          从相册选择
          <input
            ref={fileInputRef}
            className="file-input"
            type="file"
            multiple
            accept="image/*"
            onChange={onPickerChange}
            disabled={isUploading}
            aria-label="选择图片"
          />
        </label>
      </div>

      <p
        className="privacy-note"
        data-testid="direct-upload-experience-hint"
      >
        体验约束：单次最多 {config.recommendedClientLimit} 张图片，
        仅支持 JPEG/PNG/WebP/HEIC/HEIF/GIF。该限制为体验约束，非安全约束。
      </p>

      {validationError && (
        <div className="inline-alert danger" role="alert">
          {validationError}
        </div>
      )}
    </div>
  )
}