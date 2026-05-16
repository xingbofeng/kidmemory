import { useRef, type ChangeEvent } from 'react'
import { useTranslation } from 'react-i18next'
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
  onFilesSelected,
}: UploadControlsProps) {
  const { t } = useTranslation()
  const fileInputRef = useRef<HTMLInputElement>(null)

  const onPickerChange = (event: ChangeEvent<HTMLInputElement>) => {
    const list = Array.from(event.target.files ?? [])
    if (fileInputRef.current) fileInputRef.current.value = ''
    if (list.length === 0) return
    onFilesSelected(list)
  }

  return (
    <div className="upload-console">
      <div className="upload-summary">
        <span>
          {t('directUpload.uploadedSuccess')}<strong>{successCount}</strong>
        </span>
        <span>{t('directUpload.queueCount', { count: totalSelected })}</span>
      </div>

      <div className="picker-row">
        <label className="picker-tile">
          {t('directUpload.pickFromAlbum')}
          <input
            ref={fileInputRef}
            className="file-input"
            type="file"
            multiple
            accept="image/*"
            onChange={onPickerChange}
            disabled={isUploading}
            aria-label={t('directUpload.pickImageAria')}
          />
        </label>
      </div>

      <p className="privacy-note" data-testid="direct-upload-experience-hint">
        {t('directUpload.experienceHint', { limit: config.recommendedClientLimit })}
      </p>

      {validationError && (
        <div className="inline-alert danger" role="alert">
          {validationError}
        </div>
      )}
    </div>
  )
}
