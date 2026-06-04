import { useTranslation } from 'react-i18next'
import { sessionProvidersOf, type UploadProvider, type SessionSummary } from '../../types/trustedUpload'

interface ProviderSelectorProps {
  selectedProvider: UploadProvider
  session: SessionSummary
  onProviderChange: (provider: UploadProvider) => void
}

export function ProviderSelector({ selectedProvider, session, onProviderChange }: ProviderSelectorProps) {
  const { t } = useTranslation()
  const providers = sessionProvidersOf(session)

  return (
    <div className="route-selector trusted-route-selector">
      <button
        className={selectedProvider === 'lan' ? 'selected' : ''}
        type="button"
        disabled={!providers.lan?.available}
        onClick={() => onProviderChange('lan')}
      >
        <strong>{t('trustedUpload.lanTitle')}</strong>
        <span>{providers.lan?.available ? t('trustedUpload.lanFast') : t('trustedUpload.lanUnavailable')}</span>
      </button>
      <button
        className={selectedProvider === 'cos' ? 'selected' : ''}
        type="button"
        disabled={providers.cos?.available === false}
        onClick={() => onProviderChange('cos')}
      >
        <strong>{t('trustedUpload.cloudTitle')}</strong>
        <span>{providers.cos?.available === false ? t('trustedUpload.cloudUnavailable') : t('trustedUpload.cloudFallback')}</span>
      </button>
    </div>
  )
}
