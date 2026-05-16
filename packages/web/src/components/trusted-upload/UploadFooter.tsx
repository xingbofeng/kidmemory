import { useTranslation } from 'react-i18next'
import type { FileTask } from '../../types/trustedUpload'

interface UploadFooterProps {
  tasks: FileTask[]
  onContinueUpload: () => void
}

export function UploadFooter({ tasks, onContinueUpload }: UploadFooterProps) {
  const { t } = useTranslation()
  const successCount = tasks.filter((t) => t.status === 'success').length
  const failedCount = tasks.filter((t) => t.status === 'failed').length
  const activeCount = tasks.filter((t) => t.status === 'uploading' || t.status === 'committing').length
  const progressPercent = tasks.length === 0 ? 0 : Math.round((successCount / tasks.length) * 100)

  return (
    <footer className="trusted-footer">
      <div className="batch-progress">
        <span>{t('trustedUpload.footerProgress', { active: activeCount, success: successCount, failed: failedCount })}</span>
        <div><i style={{ width: `${progressPercent}%` }} /></div>
      </div>
      <button className="primary-action" type="button" onClick={onContinueUpload}>
        {t('trustedUpload.continueUpload')}
      </button>
      <p className="privacy-note">{t('trustedUpload.privacy')}</p>
    </footer>
  )
}
