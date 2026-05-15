import { Icon } from '../ui/Icon'
import type { SharedBook } from '../../types/shareBook'

interface ShareFooterProps {
  book: SharedBook
  onViewBook: () => void
  onDownloadBook: () => void
  onSaveToPhotos: () => void
}

export function ShareFooter({ book, onViewBook, onDownloadBook, onSaveToPhotos }: ShareFooterProps) {
  const handleShare = () => {
    if (navigator.share) {
      navigator.share({
        title: `${book.title} - KidMemory 作品集`,
        text: `查看这本珍贵的家庭作品集：${book.title}`,
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
          onClick={onViewBook}
        >
          <Icon name="pdf" />
          查看完整作品集
        </button>
        <button
          className="action-button secondary"
          onClick={onDownloadBook}
        >
          <Icon name="download" />
          下载 PDF
        </button>
        <button
          className="action-button secondary"
          onClick={onSaveToPhotos}
        >
          <Icon name="image" />
          保存长图到相册
        </button>
      </div>

      <div className="share-more">
        <button
          className="share-link-button"
          onClick={handleShare}
        >
          <Icon name="link" />
          分享给更多朋友
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