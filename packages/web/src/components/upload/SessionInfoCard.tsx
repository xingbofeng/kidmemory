import { useTranslation } from 'react-i18next'
import type { DirectUploadConfig } from '../../lib/direct-upload-types'

interface SessionInfoCardProps {
  config: DirectUploadConfig
  totalSelected: number
}

export function SessionInfoCard({ config, totalSelected }: SessionInfoCardProps) {
  const { t } = useTranslation()
  const progressLabel = `${totalSelected} / ${config.recommendedClientLimit}`

  return (
    <div className="session-card" aria-label={t('directUpload.sessionInfoAria')}>
      <div className="session-meta">
        <div className="child-row">
          <div>
            <h2>{t('directUpload.currentChild')}</h2>
            <p data-testid="direct-upload-child-id">{config.childId}</p>
          </div>
        </div>
        <div className="remaining-time" data-testid="direct-upload-session-path">
          {t('directUpload.sessionPath', { path: config.sessionPath })}
        </div>
        <div className="progress-line" data-testid="direct-upload-count">
          <span>{progressLabel}</span>
          <span>{t('directUpload.countUnit')}</span>
        </div>
      </div>
    </div>
  )
}
