import { useState, useEffect } from 'react'
import { ApiError } from '../../api/errors'
import { validateShareToken, getSharedAssets } from '../../api/shareApi'
import type { SharedAsset, ShareTokenValidation } from '../../types/shareBrowse'
import { ShareLoading } from '../../components/share/ShareLoading'
import { ShareError } from '../../components/share/ShareError'
import { ShareBrowseHeader } from '../../components/share-browse/ShareBrowseHeader'
import { AssetsGrid } from '../../components/share-browse/AssetsGrid'
import { ShareBrowseFooter } from '../../components/share-browse/ShareBrowseFooter'

interface ShareBrowsePageProps {
  shareToken: string
}

export function ShareBrowsePage({ shareToken }: ShareBrowsePageProps) {
  const [, setValidation] = useState<ShareTokenValidation | null>(null)
  const [assets, setAssets] = useState<SharedAsset[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const validateAndLoadContent = async () => {
    try {
      setLoading(true)
      setError(null)

      // Validate share token
      const validationData = await validateShareToken(shareToken)

      if (!validationData.isValid) {
        setError(validationData.error || '分享链接无效或已过期')
        return
      }

      setValidation(validationData)

      // Load shared content using browse API with share token context
      const assetsData = await getSharedAssets(shareToken)
      setAssets(assetsData)

    } catch (err) {
      console.error('Failed to load shared content:', err)
      const message = err instanceof ApiError ? err.message : (err instanceof Error ? err.message : '加载分享内容失败')
      setError(message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    validateAndLoadContent()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [shareToken])

  if (loading) {
    return <ShareLoading />
  }

  if (error) {
    return (
      <ShareError
        title="分享链接无效"
        message={error}
        onRetry={() => window.location.reload()}
      />
    )
  }

  return (
    <div className="share-page browse">
      <ShareBrowseHeader />

      <main className="share-content">
        <div className="content-header">
          <h2>分享的素材</h2>
          <p>共 {assets.length} 张照片</p>
        </div>

        <AssetsGrid assets={assets} />
      </main>

      <ShareBrowseFooter assets={assets} />
    </div>
  )
}