import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import type { SharedAsset } from '../../types/shareBrowse'

interface ShareBrowseFooterProps {
  assets: SharedAsset[]
}

export function ShareBrowseFooter({ assets }: ShareBrowseFooterProps) {
  const { t } = useTranslation()

  const handleSaveAll = () => {
    assets.forEach((asset) => {
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
        title: t('share.shareTitle'),
        text: t('share.shareText', { count: assets.length }),
        url: window.location.href,
      })
    } else {
      navigator.clipboard.writeText(window.location.href)
      alert(t('share.shareCopied'))
    }
  }

  return (
    <footer className="share-footer">
      <div className="share-actions">
        <button className="action-button primary" onClick={handleSaveAll}>
          <Icon name="download" />
          {t('share.saveAll')}
        </button>
        <button className="action-button secondary" onClick={handleShare}>
          <Icon name="link" />
          {t('share.shareToFriend')}
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
