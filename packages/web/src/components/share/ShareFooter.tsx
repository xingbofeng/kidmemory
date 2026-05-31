import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import type { SharedBook } from '../../types/shareBook'
import { shareCurrentPage } from '../../lib/share-current-page'

interface ShareFooterProps {
  book: SharedBook
  onViewBook: () => void
  onDownloadBook: () => void
  onSaveToPhotos: () => void
}

export function ShareFooter({ book, onViewBook, onDownloadBook, onSaveToPhotos }: ShareFooterProps) {
  const { t } = useTranslation()

  const handleShare = () => {
    shareCurrentPage({
      title: t('share.shareBookTitle', { title: book.title }),
      text: t('share.shareBookText', { title: book.title }),
      url: window.location.href,
      copiedMessage: t('share.shareCopied'),
    })
  }

  return (
    <footer className="share-footer">
      <div className="share-actions">
        <button className="action-button primary" onClick={onViewBook}>
          <Icon name="pdf" />
          {t('share.viewFullBook')}
        </button>
        <button className="action-button secondary" onClick={onDownloadBook}>
          <Icon name="download" />
          {t('share.downloadPdf')}
        </button>
        <button className="action-button secondary" onClick={onSaveToPhotos}>
          <Icon name="image" />
          {t('share.saveLongImage')}
        </button>
      </div>

      <div className="share-more">
        <button className="share-link-button" onClick={handleShare}>
          <Icon name="link" />
          {t('share.shareToFriends')}
        </button>
      </div>

      <div className="share-branding">
        <p>
          <Icon name="bear-avatar" />
          {t('share.branding')}
        </p>
      </div>
    </footer>
  )
}
