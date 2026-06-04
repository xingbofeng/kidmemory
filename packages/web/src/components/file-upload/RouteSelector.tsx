import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import type { UploadProvider } from '../../types/trustedUpload'

interface RouteSelectorProps {
  selectedProvider: UploadProvider
  providers: Record<UploadProvider, { available: boolean }>
  onSelect: (provider: UploadProvider) => void
}

export function RouteSelector({ selectedProvider, providers, onSelect }: RouteSelectorProps) {
  const { t } = useTranslation()
  const options: Array<{
    provider: UploadProvider
    icon: 'link' | 'cloud-upload'
    title: string
    description: string
  }> = [
    {
      provider: 'lan',
      icon: 'link',
      title: t('upload.lanDirect'),
      description: providers.lan.available ? t('upload.lanFast') : t('upload.routeUnavailable'),
    },
    {
      provider: 'cos',
      icon: 'cloud-upload',
      title: t('upload.publicDirect'),
      description: providers.cos.available ? t('upload.backupAvailable') : t('upload.routeUnavailable'),
    },
  ]

  return (
    <div className="route-selector" aria-label={t('upload.routeAria')}>
      {options.map((option) => (
        <button
          key={option.provider}
          type="button"
          className={selectedProvider === option.provider ? 'selected' : ''}
          disabled={!providers[option.provider].available}
          aria-pressed={selectedProvider === option.provider}
          onClick={() => onSelect(option.provider)}
        >
          <Icon name={option.icon} />
          <strong>{option.title}</strong>
          <span>{option.description}</span>
        </button>
      ))}
    </div>
  )
}
