import { useTranslation } from 'react-i18next'
import type { UploadProvider, SessionSummary } from '../../types/trustedUpload'

interface ProviderSelectorProps {
  selectedProvider: UploadProvider
  session: SessionSummary
  onProviderChange: (provider: UploadProvider) => void
}

export function ProviderSelector({ selectedProvider, session, onProviderChange }: ProviderSelectorProps) {
  const { t } = useTranslation()

  return (
    <div className="route-selector trusted-route-selector">
      <button
        className={selectedProvider === 'lan' ? 'selected' : ''}
        type="button"
        disabled={!session.providers?.lan?.available}
        onClick={() => onProviderChange('lan')}
      >
        <strong>{t('trustedUpload.lanTitle')}</strong>
        <span>{session.providers?.lan?.available ? t('trustedUpload.lanFast') : t('trustedUpload.lanUnavailable')}</span>
      </button>
      <button
        className={selectedProvider === 'supabase' ? 'selected' : ''}
        type="button"
        disabled={session.providers?.supabase?.available === false}
        onClick={() => onProviderChange('supabase')}
      >
        <strong>{t('trustedUpload.cloudTitle')}</strong>
        <span>{session.providers?.supabase?.available === false ? t('trustedUpload.cloudUnavailable') : t('trustedUpload.cloudFallback')}</span>
      </button>
    </div>
  )
}
