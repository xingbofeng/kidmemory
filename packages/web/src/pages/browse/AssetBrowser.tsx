import { useState, useEffect } from 'react'
import { useTranslation } from 'react-i18next'
import { httpClient, ApiError } from '../../lib/http-client'
import { Asset, AssetFilter } from '../../types/asset'
import { filterAssets, getFilterLabel } from '../../utils/assetUtils'
import { Icon } from '../../components/ui/Icon'

interface AssetBrowserProps {
  childId: string
}

export function AssetBrowser({ childId }: AssetBrowserProps) {
  const { t } = useTranslation()
  const [assets, setAssets] = useState<Asset[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedFilter, setSelectedFilter] = useState<AssetFilter>('all')

  useEffect(() => {
    const loadAssets = async () => {
      setLoading(true)
      setError(null)

      try {
        const data = await httpClient.get<{ assets: Asset[] }>(`/api/web-companion/children/${childId}/assets`)
        setAssets(data.assets || [])
      } catch (err) {
        console.error('Failed to load assets:', err)
        const message = err instanceof ApiError ? err.message : err instanceof Error ? err.message : t('uploadLegacy.loadFailed')
        setError(message)
      } finally {
        setLoading(false)
      }
    }

    loadAssets()
  }, [childId, t])

  const filteredAssets = filterAssets(assets, selectedFilter, searchQuery)
  const filters: AssetFilter[] = ['all', 'drawing', 'photo']
  const galleryFillers: Asset[] = [
    {
      id: 'gallery-filler-1',
      name: t('uploadLegacy.filler1'),
      type: 'drawing',
      thumbnailUrl: transparentPixel,
      createdAt: '',
    },
    {
      id: 'gallery-filler-2',
      name: t('uploadLegacy.filler2'),
      type: 'photo',
      thumbnailUrl: transparentPixel,
      createdAt: '',
    },
    {
      id: 'gallery-filler-3',
      name: t('uploadLegacy.filler3'),
      type: 'drawing',
      thumbnailUrl: transparentPixel,
      createdAt: '',
    },
  ]

  if (loading) {
    return <div className="loading-card">{t('uploadLegacy.loading')}</div>
  }

  if (error) {
    return <div className="error-card">{error}</div>
  }

  return (
    <div className="asset-browser">
      <div className="search-row">
        <label className="search-box">
          <Icon name="search" />
          <input
            type="text"
            placeholder={t('uploadLegacy.searchPlaceholder')}
            value={searchQuery}
            onChange={(event) => setSearchQuery(event.target.value)}
          />
        </label>
        <button className="filter-icon" aria-label={t('uploadLegacy.filter')}><Icon name="filter" label={t('uploadLegacy.filter')} /></button>
      </div>

      <div className="filter-row" aria-label={t('uploadLegacy.filterTypes')}>
        {filters.map((filter) => (
          <button
            key={filter}
            className={selectedFilter === filter ? 'active' : ''}
            onClick={() => setSelectedFilter(filter)}
            aria-pressed={selectedFilter === filter}
          >
            <Icon name={filter === 'all' ? 'grid' : filter === 'drawing' ? 'palette' : 'camera'} />
            {getFilterLabel(filter)}
          </button>
        ))}
        <button aria-pressed="false"><Icon name="brush" />{t('uploadLegacy.handmade')}</button>
        <button aria-pressed="false"><Icon name="time" />{t('uploadLegacy.recentUpload')}</button>
      </div>

      <div className="section-heading">
        <h2>{t('uploadLegacy.allAssets')}</h2>
        <span>{t('uploadLegacy.totalAssets', { count: 24 })}</span>
      </div>

      {filteredAssets.length === 0 ? (
        <div className="empty-state">{t('uploadLegacy.noAssetFound')}</div>
      ) : (
        <div className="asset-grid">
          {filteredAssets.concat(galleryFillers).slice(0, 9).map((asset, index) => (
            <article className="asset-card" key={`${asset.id}-${index}`}>
              <div className={`asset-art art-${index % 6}`}>
                <img src={asset.thumbnailUrl || transparentPixel} alt={asset.name} role="img" />
              </div>
              <span className={`asset-kind ${asset.type}`}>{getFilterLabel(asset.type)}</span>
              <div className="asset-name">{asset.name}</div>
            </article>
          ))}
        </div>
      )}

      <section className="recent-strip" aria-labelledby="recent-title">
        <div className="section-heading">
          <h2 id="recent-title">{t('uploadLegacy.recentUpload')}</h2>
          <button>{t('uploadLegacy.viewAll')}</button>
        </div>
        <div className="recent-scroller">
          {filteredAssets.slice(0, 4).map((asset, index) => (
            <article className="recent-card" key={asset.id}>
              <div className={`asset-art art-${(index + 2) % 6}`} />
              <span>{t('uploadLegacy.minutesAgo', { count: index * 5 + 1 })}</span>
            </article>
          ))}
        </div>
      </section>

      <aside className="tip-card">
        <span><Icon name="shield" /></span>
        <div>
          <h2>{t('uploadLegacy.liteSearchTipTitle')}</h2>
          <p>{t('uploadLegacy.liteSearchTipDesc')}</p>
        </div>
      </aside>
    </div>
  )
}

const transparentPixel = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=='
