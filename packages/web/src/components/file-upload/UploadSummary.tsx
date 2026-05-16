import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import { UploadSession } from '../../types/api'
import { formatCompactRemaining } from '../../utils/fileUploadUtils'

interface UploadSummaryProps {
  session: UploadSession
}

export function UploadSummary({ session }: UploadSummaryProps) {
  const { t } = useTranslation()
  const { uploadCount = 0, maxUploads } = session

  return (
    <div className="upload-summary">
      <span><Icon name="image" /> {t('uploadLegacy.summaryCount', { count: uploadCount, max: maxUploads })}</span>
      <span><Icon name="time" /> {t('uploadLegacy.summaryRemaining', { time: formatCompactRemaining(session.expiresAt) })}</span>
    </div>
  )
}
