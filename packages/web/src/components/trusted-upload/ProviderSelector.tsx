import type { UploadProvider, SessionSummary } from '../../types/trustedUpload'

interface ProviderSelectorProps {
  selectedProvider: UploadProvider
  session: SessionSummary
  onProviderChange: (provider: UploadProvider) => void
}

export function ProviderSelector({ selectedProvider, session, onProviderChange }: ProviderSelectorProps) {
  return (
    <div className="route-selector trusted-route-selector">
      <button
        className={selectedProvider === 'lan' ? 'selected' : ''}
        type="button"
        disabled={!session.providers?.lan?.available}
        onClick={() => onProviderChange('lan')}
      >
        <strong>📶 局域网直传</strong>
        <span>{session.providers?.lan?.available ? '优先使用，速度更快' : '当前网络不可用'}</span>
      </button>
      <button
        className={selectedProvider === 'supabase' ? 'selected' : ''}
        type="button"
        disabled={session.providers?.supabase?.available === false}
        onClick={() => onProviderChange('supabase')}
      >
        <strong>☁ 公网直传</strong>
        <span>{session.providers?.supabase?.available === false ? '存储配置不可用' : 'Supabase 兜底'}</span>
      </button>
    </div>
  )
}