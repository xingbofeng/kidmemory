import { useState, useEffect } from 'react'
import { useTranslation } from 'react-i18next'
import { httpClient, ApiError } from '../../lib/http-client'
import { Asset, AssetFilter } from '../../types/asset'
import { filterAssets, getFilterLabel } from '../../utils/assetUtils'
import { Icon } from '../../components/ui/Icon'

interface AssetBrowserProps {
  sessionId: string
  sessionToken: string
}

interface RecentUploadResponse {
  id: string
  title?: string
  name?: string
  type: string
  previewUrl?: string
  thumbnailUrl?: string
  createdAt: string
}

export function AssetBrowser({ sessionId, sessionToken }: AssetBrowserProps) {
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
        const data = await httpClient.get<RecentUploadResponse[] | { assets: RecentUploadResponse[] }>(
          `/api/web-companion/sessions/${sessionId}/recent?token=${encodeURIComponent(sessionToken)}&limit=20`,
        )
        const recentUploads = Array.isArray(data) ? data : data.assets || []
        setAssets(recentUploads.map(toAsset))
      } catch (err) {
        const message = err instanceof ApiError ? err.message : err instanceof Error ? err.message : t('upload.loadFailed')
        setError(message)
      } finally {
        setLoading(false)
      }
    }

    loadAssets()
  }, [sessionId, sessionToken, t])

  const filteredAssets = filterAssets(assets, selectedFilter, searchQuery)
  const filters: AssetFilter[] = ['all', 'drawing', 'photo']
  const galleryFillers: Asset[] = [
    {
      id: 'gallery-filler-1',
      name: t('upload.filler1'),
      type: 'drawing',
      thumbnailUrl: transparentPixel,
      createdAt: '',
    },
    {
      id: 'gallery-filler-2',
      name: t('upload.filler2'),
      type: 'photo',
      thumbnailUrl: transparentPixel,
      createdAt: '',
    },
    {
      id: 'gallery-filler-3',
      name: t('upload.filler3'),
      type: 'drawing',
      thumbnailUrl: transparentPixel,
      createdAt: '',
    },
  ]

  if (loading) {
    return <div className="loading-card">{t('upload.loading')}</div>
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
            placeholder={t('upload.searchPlaceholder')}
            value={searchQuery}
            onChange={(event) => setSearchQuery(event.target.value)}
          />
        </label>
        <button className="filter-icon" aria-label={t('upload.filter')}><Icon name="filter" label={t('upload.filter')} /></button>
      </div>

      <div className="filter-row" aria-label={t('upload.filterTypes')}>
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
        <button aria-pressed="false"><Icon name="brush" />{t('upload.handmade')}</button>
        <button aria-pressed="false"><Icon name="time" />{t('upload.recentUpload')}</button>
      </div>

      <div className="section-heading">
        <h2>{t('upload.allAssets')}</h2>
        <span>{t('upload.totalAssets', { count: assets.length })}</span>
      </div>

      {filteredAssets.length === 0 ? (
        <div className="empty-state">{t('upload.noAssetFound')}</div>
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
          <h2 id="recent-title">{t('upload.recentUpload')}</h2>
          <button>{t('upload.viewAll')}</button>
        </div>
        <div className="recent-scroller">
          {filteredAssets.slice(0, 4).map((asset, index) => (
            <article className="recent-card" key={asset.id}>
              <div className={`asset-art art-${(index + 2) % 6}`} />
              <span>{t('upload.minutesAgo', { count: index * 5 + 1 })}</span>
            </article>
          ))}
        </div>
      </section>

      <aside className="tip-card">
        <span><Icon name="shield" /></span>
        <div>
          <h2>{t('upload.liteSearchTipTitle')}</h2>
          <p>{t('upload.liteSearchTipDesc')}</p>
        </div>
      </aside>
    </div>
  )
}

const transparentPixel = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=='

const toAsset = (upload: RecentUploadResponse): Asset => ({
  id: upload.id,
  name: upload.name || upload.title || upload.id,
  type: toAssetType(upload.type),
  thumbnailUrl: upload.thumbnailUrl || upload.previewUrl || transparentPixel,
  createdAt: upload.createdAt,
})

const toAssetType = (type: string): Asset['type'] => {
  if (type === 'drawing' || type === 'photo' || type === 'video') return type
  return 'photo'
}
