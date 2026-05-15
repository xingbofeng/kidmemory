import { Icon } from '../ui/Icon'
import type { SharedAsset } from '../../types/shareBrowse'

interface AssetsGridProps {
  assets: SharedAsset[]
}

export function AssetsGrid({ assets }: AssetsGridProps) {
  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  if (assets.length === 0) {
    return (
      <div className="empty-state">
        <Icon name="image" />
        <h3>暂无分享内容</h3>
        <p>这个分享链接中还没有素材</p>
      </div>
    )
  }

  return (
    <div className="assets-grid">
      {assets.map((asset) => (
        <article key={asset.id} className="asset-card">
          <div className="asset-image">
            <img
              src={asset.previewUrl || '/placeholder-image.png'}
              alt={asset.title}
              loading="lazy"
            />
          </div>
          <div className="asset-info">
            <h3>{asset.title}</h3>
            <p className="asset-date">
              <Icon name="time" />
              {formatDate(asset.createdAt)}
            </p>
          </div>
          <button
            className="asset-action"
            onClick={() => {
              window.open(asset.previewUrl, '_blank')
            }}
            aria-label={`查看 ${asset.title}`}
          >
            <Icon name="search" />
          </button>
        </article>
      ))}
    </div>
  )
}