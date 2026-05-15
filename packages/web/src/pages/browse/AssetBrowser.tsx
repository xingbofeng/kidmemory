import { useState, useEffect } from 'react'
import axios from 'axios'
import { Asset, AssetFilter } from '../../types/asset'
import { filterAssets, getFilterLabel } from '../../utils/assetUtils'
import { Icon } from '../../components/ui/Icon'

interface AssetBrowserProps {
  childId: string
}

export function AssetBrowser({ childId }: AssetBrowserProps) {
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
        const response = await axios.get(`/api/web-companion/children/${childId}/assets`)
        setAssets(response.data.assets || [])
      } catch (err) {
        console.error('Failed to load assets:', err)
        setError(err instanceof Error ? err.message : '加载失败')
      } finally {
        setLoading(false)
      }
    }

    loadAssets()
  }, [childId])

  const filteredAssets = filterAssets(assets, selectedFilter, searchQuery)
  const filters: AssetFilter[] = ['all', 'drawing', 'photo']

  if (loading) {
    return <div className="loading-card">加载中...</div>
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
            placeholder="搜索素材、标题、标签或描述..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </label>
        <button className="filter-icon" aria-label="筛选"><Icon name="filter" label="筛选" /></button>
      </div>

      <div className="filter-row" aria-label="素材类型筛选">
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
        <button aria-pressed="false"><Icon name="brush" />手工</button>
        <button aria-pressed="false"><Icon name="time" />最近上传</button>
      </div>

      <div className="section-heading">
        <h2>全部素材</h2>
        <span>共 24 项素材</span>
      </div>

      {filteredAssets.length === 0 ? (
        <div className="empty-state">没有找到相关素材</div>
      ) : (
        <div className="asset-grid">
          {filteredAssets.concat(galleryFillers).slice(0, 9).map((asset, index) => (
            <article className="asset-card" key={`${asset.id}-${index}`}>
              <div className={`asset-art art-${index % 6}`}>
                <img
                  src={asset.thumbnailUrl || transparentPixel}
                  alt={asset.name}
                  role="img"
                />
              </div>
              <span className={`asset-kind ${asset.type}`}>{getFilterLabel(asset.type)}</span>
              <div className="asset-name">{asset.name}</div>
            </article>
          ))}
        </div>
      )}

      <section className="recent-strip" aria-labelledby="recent-title">
        <div className="section-heading">
          <h2 id="recent-title">最近上传</h2>
          <button>查看全部 ›</button>
        </div>
        <div className="recent-scroller">
          {filteredAssets.slice(0, 4).map((asset, index) => (
            <article className="recent-card" key={asset.id}>
              <div className={`asset-art art-${(index + 2) % 6}`} />
              <span>{index * 5 + 1} 分钟前</span>
            </article>
          ))}
        </div>
      </section>

      <aside className="tip-card">
        <span><Icon name="shield" /></span>
        <div>
          <h2>轻量搜索提示</h2>
          <p>当前为移动端轻量搜索，仅支持关键词查找。需要更多筛选条件，请使用桌面端访问 KidMemory。</p>
        </div>
      </aside>
    </div>
  )
}

const transparentPixel =
  'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=='

const galleryFillers: Asset[] = [
  {
    id: 'gallery-filler-1',
    name: '彩虹房子',
    type: 'drawing',
    thumbnailUrl: transparentPixel,
    createdAt: ''
  },
  {
    id: 'gallery-filler-2',
    name: '周末照片',
    type: 'photo',
    thumbnailUrl: transparentPixel,
    createdAt: ''
  },
  {
    id: 'gallery-filler-3',
    name: '课堂手作',
    type: 'drawing',
    thumbnailUrl: transparentPixel,
    createdAt: ''
  }
]
