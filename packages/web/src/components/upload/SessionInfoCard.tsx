import type { DirectUploadConfig } from '../../lib/direct-upload-types'

interface SessionInfoCardProps {
  config: DirectUploadConfig
  totalSelected: number
}

export function SessionInfoCard({ config, totalSelected }: SessionInfoCardProps) {
  const progressLabel = `${totalSelected} / ${config.recommendedClientLimit}`

  return (
    <div className="session-card" aria-label="会话信息">
      <div className="session-meta">
        <div className="child-row">
          <div>
            <h2>当前孩子</h2>
            <p data-testid="direct-upload-child-id">{config.childId}</p>
          </div>
        </div>
        <div className="remaining-time" data-testid="direct-upload-session-path">
          会话路径：{config.sessionPath}
        </div>
        <div className="progress-line" data-testid="direct-upload-count">
          <span>{progressLabel}</span>
          <span>张</span>
        </div>
      </div>
    </div>
  )
}