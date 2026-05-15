import { Icon } from '../ui/Icon'
import { UploadSession } from '../../types/api'
import { formatCompactRemaining } from '../../utils/fileUploadUtils'

interface UploadSummaryProps {
  session: UploadSession
}

export function UploadSummary({ session }: UploadSummaryProps) {
  const { uploadCount = 0, maxUploads } = session

  return (
    <div className="upload-summary">
      <span><Icon name="image" /> <strong>{uploadCount}</strong> / {maxUploads} 张</span>
      <span><Icon name="time" /> 会话剩余 <strong>{formatCompactRemaining(session.expiresAt)}</strong></span>
    </div>
  )
}