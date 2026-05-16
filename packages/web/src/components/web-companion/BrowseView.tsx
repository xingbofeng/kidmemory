import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import { AssetBrowser } from '../../pages/browse/AssetBrowser'

interface BrowseViewProps {
  childId: string
}

export function BrowseView({ childId }: BrowseViewProps) {
  const { t } = useTranslation()

  return (
    <section className="browse-view" aria-labelledby="browse-title">
      <div className="screen-title">
        <span className="cloud-mini" />
        <h1 id="browse-title">{t('webCompanion.browseTitle')}</h1>
        <button className="help-button" aria-label={t('webCompanion.help')}>
          <Icon name="info" label={t('webCompanion.help')} />
        </button>
      </div>
      <AssetBrowser childId={childId} />
    </section>
  )
}
