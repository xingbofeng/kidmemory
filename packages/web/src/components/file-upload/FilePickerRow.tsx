import { useRef, type ChangeEvent } from 'react'
import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'

interface FilePickerRowProps {
  onFileSelect: (event: ChangeEvent<HTMLInputElement>) => void
  canSelectMore: boolean
  isUploading: boolean
}

export function FilePickerRow({ onFileSelect, canSelectMore, isUploading }: FilePickerRowProps) {
  const { t } = useTranslation()
  const fileInputRef = useRef<HTMLInputElement>(null)

  return (
    <div className="picker-row">
      <label className="picker-tile">
        <Icon name="camera" /> {t('upload.photo')}
        <input
          ref={fileInputRef}
          className="file-input"
          type="file"
          multiple
          accept="image/*"
          onChange={onFileSelect}
          disabled={!canSelectMore || isUploading}
          aria-label={t('upload.chooseImageAria')}
        />
      </label>
      <label className="picker-tile">
        <Icon name="image" /> {t('upload.chooseFromAlbum')}
        <input
          className="file-input"
          type="file"
          multiple
          accept="image/*"
          onChange={onFileSelect}
          disabled={!canSelectMore || isUploading}
          aria-label={t('upload.importFromAlbumAria')}
        />
      </label>
    </div>
  )
}
