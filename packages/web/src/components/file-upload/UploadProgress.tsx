import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import type { SelectedFile } from '../../types/fileUpload'

interface UploadProgressProps {
  selectedFiles: SelectedFile[]
  isUploading: boolean
  disabled?: boolean
  onUpload: () => void
}

export function UploadProgress({ selectedFiles, isUploading, disabled = false, onUpload }: UploadProgressProps) {
  const { t } = useTranslation()
  const uploadingCount = selectedFiles.filter((file) => file.status === 'uploading').length

  return (
    <>
      {isUploading && (
        <div className="batch-progress">
          <span><Icon name="cloud-upload" /> {t('upload.uploadingFiles', { count: uploadingCount })}</span>
          <div><i /></div>
        </div>
      )}

      <button
        className="primary-action"
        onClick={onUpload}
        aria-label={t('upload.startUploadAria')}
        disabled={selectedFiles.length === 0 || isUploading || disabled}
      >
        <Icon name="upload" /> {selectedFiles.length > 0 ? t('upload.startUpload') : t('upload.continueUpload')}
      </button>
    </>
  )
}
