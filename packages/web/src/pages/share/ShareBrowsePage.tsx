import { useCallback, useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { ApiError } from '../../api/errors'
import { validateShareToken, getSharedAssets } from '../../api/shareApi'
import type { SharedAsset } from '../../types/shareBrowse'
import { ShareLoading } from '../../components/share/ShareLoading'
import { ShareError } from '../../components/share/ShareError'
import { ShareBrowseHeader } from '../../components/share-browse/ShareBrowseHeader'
import { AssetsGrid } from '../../components/share-browse/AssetsGrid'
import { ShareBrowseFooter } from '../../components/share-browse/ShareBrowseFooter'

interface ShareBrowsePageProps {
  shareToken: string
}

export function ShareBrowsePage({ shareToken }: ShareBrowsePageProps) {
  const { t } = useTranslation()
  const [assets, setAssets] = useState<SharedAsset[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const validateAndLoadContent = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      const validationData = await validateShareToken(shareToken)

      if (!validationData.isValid) {
        setError(validationData.error || t('share.invalidOrExpired'))
        return
      }

      const assetsData = await getSharedAssets(shareToken)
      setAssets(assetsData)
    } catch (err) {
      const message = err instanceof ApiError ? err.message : err instanceof Error ? err.message : t('share.loadBookFailed')
      setError(message)
    } finally {
      setLoading(false)
    }
  }, [shareToken, t])

  useEffect(() => {
    validateAndLoadContent()
  }, [validateAndLoadContent])

  if (loading) {
    return <ShareLoading />
  }

  if (error) {
    return <ShareError title={t('share.invalidTitle')} message={error} onRetry={() => window.location.reload()} />
  }

  return (
    <div className="share-page browse">
      <ShareBrowseHeader />

      <main className="share-content">
        <div className="content-header">
          <h2>{t('share.contentTitle')}</h2>
          <p>{t('share.photoCount', { count: assets.length })}</p>
        </div>

        <AssetsGrid assets={assets} />
      </main>

      <ShareBrowseFooter assets={assets} />
    </div>
  )
}
