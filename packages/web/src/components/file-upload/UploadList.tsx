import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import type { SelectedFile } from '../../types/fileUpload'

interface UploadListProps {
  selectedFiles: SelectedFile[]
  onRemoveFile: (id: string) => void
  onClearAll?: () => void
}

export function UploadList({ selectedFiles, onRemoveFile, onClearAll }: UploadListProps) {
  const { t } = useTranslation()

  return (
    <>
      <div className="queue-heading">
        <h2>{t('upload.queueTitle', { count: selectedFiles.length })}</h2>
        <button type="button" onClick={onClearAll} disabled={selectedFiles.length === 0}>
          {t('upload.clearQueue')}
        </button>
      </div>

      <div className="upload-list">
        {selectedFiles.map((selectedFile) => (
          <div className="upload-item" key={selectedFile.id}>
            <div className="upload-thumb drawing-thumb" />
            <div className="upload-copy">
              <span>{selectedFile.file.name}</span>
              <small>{(selectedFile.file.size / 1024 / 1024 || 4.2).toFixed(1)} MB</small>
            </div>

            {selectedFile.status === 'pending' && (
              <button className="remove-file" onClick={() => onRemoveFile(selectedFile.id)} aria-label={t('upload.delete')}>
                <Icon name="delete" label={t('upload.delete')} />
              </button>
            )}

            {selectedFile.status === 'uploading' && <span className="item-status uploading">{t('upload.uploading')}</span>}
            {selectedFile.status === 'committing' && <span className="item-status uploading">{t('upload.committing')}</span>}
            {selectedFile.status === 'success' && <span className="item-status success">{t('upload.uploadSuccess')}</span>}
            {selectedFile.status === 'error' && (
              <span className="item-status danger">{selectedFile.error || t('upload.uploadFailed')}</span>
            )}
          </div>
        ))}

        {selectedFiles.length === 0 && <div className="empty-upload-list">{t('upload.emptyUploadList')}</div>}
      </div>
    </>
  )
}
