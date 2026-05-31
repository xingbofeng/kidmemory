import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import type { SharedAsset } from '../../types/shareBrowse'
import { formatShareDate } from '../../utils/shareDate'

interface AssetsGridProps {
  assets: SharedAsset[]
}

export function AssetsGrid({ assets }: AssetsGridProps) {
  const { t, i18n } = useTranslation()
  const language = i18n.resolvedLanguage ?? i18n.language

  if (assets.length === 0) {
    return (
      <div className="empty-state">
        <Icon name="image" />
        <h3>{t('share.emptyTitle')}</h3>
        <p>{t('share.emptyDesc')}</p>
      </div>
    )
  }

  return (
    <div className="assets-grid">
      {assets.map((asset) => (
        <article key={asset.id} className="asset-card">
          <div className="asset-image">
            <img src={asset.previewUrl || '/placeholder-image.png'} alt={asset.title} loading="lazy" />
          </div>
          <div className="asset-info">
            <h3>{asset.title}</h3>
            <p className="asset-date">
              <Icon name="time" />
              {formatShareDate(asset.createdAt, language)}
            </p>
          </div>
          <button
            className="asset-action"
            onClick={() => {
              window.open(asset.previewUrl, '_blank')
            }}
            aria-label={t('share.viewAssetAria', { title: asset.title })}
          >
            <Icon name="search" />
          </button>
        </article>
      ))}
    </div>
  )
}
