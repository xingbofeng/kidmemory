import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'

export function RouteSelector() {
  const { t } = useTranslation()

  return (
    <div className="route-selector" aria-label={t('uploadLegacy.routeAria')}>
      <button className="selected">
        <Icon name="link" />
        <strong>{t('uploadLegacy.lanDirect')}</strong>
        <span>{t('uploadLegacy.lanFast')}</span>
      </button>
      <button>
        <Icon name="cloud-upload" />
        <strong>{t('uploadLegacy.publicDirect')}</strong>
        <span>{t('uploadLegacy.backupPending')}</span>
      </button>
    </div>
  )
}
