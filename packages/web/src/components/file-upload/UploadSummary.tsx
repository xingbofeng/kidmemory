import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import { UploadSession } from '../../types/api'
import { formatCompactRemaining } from '../../utils/fileUploadUtils'

interface UploadSummaryProps {
  session: UploadSession
}

export function UploadSummary({ session }: UploadSummaryProps) {
  const { t } = useTranslation()
  const { uploadCount = 0, maxUploads, maxItems } = session
  const resolvedMaxUploads = maxUploads ?? maxItems ?? 0

  return (
    <div className="upload-summary">
      <span><Icon name="image" /> <strong>{uploadCount}</strong> / {resolvedMaxUploads} {t('upload.unitCount')}</span>
      <span><Icon name="time" /> {t('upload.remainingTime')} {formatCompactRemaining(session.expiresAt)}</span>
    </div>
  )
}
