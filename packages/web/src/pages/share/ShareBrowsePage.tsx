import { useState, useEffect } from 'react'
import axios from 'axios'
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
      const validationResponse = await axios.get(`/api/web-companion/share/${shareToken}/access`)
      const validationData: ShareTokenValidation = validationResponse.data

      if (!validationData.isValid) {
        setError(validationData.error || '分享链接无效或已过期')
        return
      }

      setValidation(validationData)

      // Load shared content using browse API with share token context
      const assetsResponse = await axios.get(`/api/web-companion/share/${shareToken}/assets`)
      const assetsData: SharedAsset[] = assetsResponse.data
      setAssets(assetsData)

    } catch (err) {
      console.error('Failed to load shared content:', err)
      setError(err instanceof Error ? err.message : '加载分享内容失败')
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