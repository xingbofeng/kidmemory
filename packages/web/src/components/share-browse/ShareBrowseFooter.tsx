import { Icon } from '../ui/Icon'
import type { SharedAsset } from '../../types/shareBrowse'

interface ShareBrowseFooterProps {
  assets: SharedAsset[]
}

export function ShareBrowseFooter({ assets }: ShareBrowseFooterProps) {
  const handleSaveAll = () => {
    assets.forEach(asset => {
      if (asset.previewUrl) {
        const link = document.createElement('a')
        link.href = asset.previewUrl
        link.download = `${asset.title}.jpg`
        link.click()
      }
    })
  }

  const handleShare = () => {
    if (navigator.share) {
      navigator.share({
        title: 'KidMemory 分享',
        text: `查看这些珍贵的家庭回忆 (${assets.length} 张照片)`,
        url: window.location.href
      })
    } else {
      navigator.clipboard.writeText(window.location.href)
      alert('分享链接已复制到剪贴板')
    }
  }

  return (
    <footer className="share-footer">
      <div className="share-actions">
        <button
          className="action-button primary"
          onClick={handleSaveAll}
        >
          <Icon name="download" />
          保存全部到相册
        </button>
        <button
          className="action-button secondary"
          onClick={handleShare}
        >
          <Icon name="link" />
          分享给朋友
        </button>
      </div>

      <div className="share-branding">
        <p>
          <Icon name="bear-avatar" />
          由 <strong>KidMemory</strong> 生成 · 家庭记忆，值得珍藏
        </p>
      </div>
    </footer>
  )
}