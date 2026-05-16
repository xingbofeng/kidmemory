import { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { UploadSession as UploadSessionType } from '../../types/api'
import { fetchUploadSession, formatRemainingTime, getUploadStatus } from '../../lib/upload-session'
import { Icon } from '../../components/ui/Icon'

interface UploadSessionProps {
  sessionId: string
  onSessionChange?: (session: UploadSessionType | null) => void
}

export function UploadSession({ sessionId, onSessionChange }: UploadSessionProps) {
  const { t } = useTranslation()
  const [session, setSession] = useState<UploadSessionType | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false

    const loadSession = async () => {
      setLoading(true)
      setError(null)
      setSession(null)
      onSessionChange?.(null)

      try {
        const sessionData = await fetchUploadSession(sessionId)
        if (cancelled) return
        setSession(sessionData)
        onSessionChange?.(sessionData)
      } catch {
        if (cancelled) return
        setError(t('uploadLegacy.sessionInvalid'))
        onSessionChange?.(null)
      } finally {
        if (!cancelled) {
          setLoading(false)
        }
      }
    }

    loadSession()
    return () => {
      cancelled = true
    }
  }, [onSessionChange, sessionId, t])

  if (loading) {
    return <div className="session-card loading-card">{t('uploadLegacy.loading')}</div>
  }

  if (error || !session) {
    return <div className="session-card error-card">{error || t('uploadLegacy.sessionInvalid')}</div>
  }

  const { childName, uploadCount = 0, maxUploads, expiresAt } = session
  const { isAtLimit, isNearLimit, progress } = getUploadStatus(uploadCount, maxUploads)
  const remainingTime = formatRemainingTime(expiresAt)

  return (
    <div className="session-card">
      <div className="qr-card" aria-hidden="true">
        <div className="qr-grid">
          {Array.from({ length: 49 }).map((_, index) => (
            <span key={index} className={(index * 7 + index) % 3 === 0 ? 'dark' : ''} />
          ))}
        </div>
        <span className="qr-leaf"><Icon name="leaf" /></span>
      </div>
      <div className="session-meta">
        <div className="session-valid">
          <span><Icon name="shield" /></span>
          <div>
            <strong>{t('uploadLegacy.sessionValid')}</strong>
            <b>{remainingTime}</b>
          </div>
        </div>
        <div className="child-row">
          <span className="child-avatar"><Icon name="child" /></span>
          <div>
            <h2>{childName}</h2>
            <p>{t('uploadLegacy.currentChild')}</p>
          </div>
        </div>
        <div className="progress-line">
          <span>{progress}</span>
          <span>{t('uploadLegacy.unitCount')}</span>
        </div>
        <div className="remaining-time">{t('uploadLegacy.remainingTime')}: {remainingTime}</div>
      </div>

      {isAtLimit && <div className="inline-alert danger">{t('uploadLegacy.atLimit')}</div>}
      {isNearLimit && <div className="inline-alert warning">{t('uploadLegacy.nearLimit')}</div>}

      <button className="sr-session-button" disabled={isAtLimit} role="button" aria-label={t('uploadLegacy.selectImage')}>
        {t('uploadLegacy.selectImage')}
      </button>
    </div>
  )
}
