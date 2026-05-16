import { useState, useEffect } from 'react'
import { useTranslation } from 'react-i18next'
import { ApiError } from '../../api/errors'
import { validateShareToken, getSharedBook } from '../../api/shareApi'
import type { SharedBook, ShareTokenValidation } from '../../types/shareBook'
import { ShareLoading } from '../../components/share/ShareLoading'
import { ShareError } from '../../components/share/ShareError'
import { ShareHeader } from '../../components/share/ShareHeader'
import { BookShowcase } from '../../components/share/BookShowcase'
import { BookPreviewSection } from '../../components/share/BookPreviewSection'
import { ShareFooter } from '../../components/share/ShareFooter'

interface ShareBookPageProps {
  shareToken: string
  bookId?: string | null
}

export function ShareBookPage({ shareToken, bookId }: ShareBookPageProps) {
  const { t } = useTranslation()
  const [, setValidation] = useState<ShareTokenValidation | null>(null)
  const [book, setBook] = useState<SharedBook | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const validateAndLoadContent = async () => {
    try {
      setLoading(true)
      setError(null)

      const validationData = await validateShareToken(shareToken)

      if (!validationData.isValid) {
        setError(validationData.error || t('share.invalidOrExpired'))
        return
      }

      setValidation(validationData)

      if (validationData.shareToken?.resourceType === 'specific_book') {
        const tokenBookId = validationData.shareToken.resourceId
        if (bookId && tokenBookId && bookId !== tokenBookId) {
          setError(t('share.bookMismatch'))
          return
        }
      }

      let targetBookId = bookId
      if (validationData.shareToken?.resourceType === 'specific_book') {
        targetBookId = validationData.shareToken.resourceId
      }

      if (!targetBookId) {
        setError(t('share.unableToDetermineBook'))
        return
      }

      const bookData = await getSharedBook(shareToken, targetBookId)
      setBook(bookData)
    } catch (err) {
      console.error('Failed to load shared book:', err)
      const message = err instanceof ApiError ? err.message : err instanceof Error ? err.message : t('share.loadBookFailed')
      setError(message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    validateAndLoadContent()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [shareToken, bookId])

  const handleViewBook = () => {
    if (book) {
      window.open(`/books/${book.id}/preview`, '_blank')
    }
  }

  const handleDownloadBook = () => {
    if (book) {
      const link = document.createElement('a')
      link.href = `/api/books/${book.id}/download`
      link.download = `${book.title}.pdf`
      link.click()
    }
  }

  const handleSaveToPhotos = () => {
    if (book) {
      const link = document.createElement('a')
      link.href = `/api/books/${book.id}/long-image`
      link.download = `${book.title}_${t('share.longImageSuffix')}.jpg`
      link.click()
    }
  }

  if (loading) {
    return <ShareLoading />
  }

  if (error) {
    return <ShareError title={t('share.invalidTitle')} message={error} onRetry={() => window.location.reload()} />
  }

  if (!book) {
    return <ShareError title={t('share.bookNotFoundTitle')} message={t('share.bookNotFoundMessage')} icon="book" />
  }

  return (
    <div className="share-page book">
      <ShareHeader />

      <main className="share-content">
        <BookShowcase book={book} onViewBook={handleViewBook} />
        <BookPreviewSection book={book} />
      </main>

      <ShareFooter book={book} onViewBook={handleViewBook} onDownloadBook={handleDownloadBook} onSaveToPhotos={handleSaveToPhotos} />
    </div>
  )
}
