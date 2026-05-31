import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'

export function RouteSelector() {
  const { t } = useTranslation()

  return (
    <div className="route-selector" aria-label={t('upload.routeAria')}>
      <button className="selected">
        <Icon name="link" />
        <strong>{t('upload.lanDirect')}</strong>
        <span>{t('upload.lanFast')}</span>
      </button>
      <button>
        <Icon name="cloud-upload" />
        <strong>{t('upload.publicDirect')}</strong>
        <span>{t('upload.backupPending')}</span>
      </button>
    </div>
  )
}
