import { useTranslation } from 'react-i18next'
import type { SessionSummary } from '../../types/trustedUpload'

interface SessionStatsProps {
  session: SessionSummary
  usedCount: number
  remainingText: string
}

export function SessionStats({ session, usedCount, remainingText }: SessionStatsProps) {
  const { t } = useTranslation()

  return (
    <div className="trusted-stats" aria-label={t('trustedUpload.sessionStats')}>
      <span>{t('trustedUpload.usedCount', { used: usedCount, max: session.maxItems })}</span>
      <span>{t('trustedUpload.sessionRemaining', { time: remainingText })}</span>
    </div>
  )
}
