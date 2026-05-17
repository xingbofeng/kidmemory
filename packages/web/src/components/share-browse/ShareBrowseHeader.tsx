import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'

export function ShareBrowseHeader() {
  const { t } = useTranslation()

  return (
    <header className="share-header">
      <div className="share-brand">
        <Icon name="bear-avatar" />
        <div>
          <h1>{t('share.headerTitle')}</h1>
          <p>{t('share.headerSubtitle')}</p>
        </div>
      </div>
      <div className="share-info">
        <span className="share-type">
          <Icon name="image" />
          {t('share.headerBrowseType')}
        </span>
      </div>
    </header>
  )
}
