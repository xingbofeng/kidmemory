import { useState, useEffect } from 'react'
import axios from 'axios'
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
  const [, setValidation] = useState<ShareTokenValidation | null>(null)
  const [book, setBook] = useState<SharedBook | null>(null)
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

      // Verify the book ID matches the share token resource
      if (validationData.shareToken?.resourceType === 'specific_book') {
        const tokenBookId = validationData.shareToken.resourceId
        if (bookId && tokenBookId && bookId !== tokenBookId) {
          setError('分享链接与请求的作品集不匹配')
          return
        }
      }

      // Load shared book content
      let targetBookId = bookId;

      // If share token is for a specific book, get the book ID from the token
      if (validationData.shareToken?.resourceType === 'specific_book') {
        targetBookId = validationData.shareToken.resourceId;
      }

      if (!targetBookId) {
        setError('无法确定要显示的作品集');
        return;
      }

      // Fetch shared book data from backend
      const bookResponse = await axios.get(`/api/web-companion/share/${shareToken}/book?bookId=${targetBookId}`)
      const bookData: SharedBook = bookResponse.data;
      setBook(bookData);

    } catch (err) {
      console.error('Failed to load shared book:', err)
      setError(err instanceof Error ? err.message : '加载分享作品集失败')
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
      link.download = `${book.title}_长图.jpg`
      link.click()
    }
  }

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

  if (!book) {
    return (
      <ShareError
        title="作品集不存在"
        message="请检查分享链接是否正确"
        icon="book"
      />
    )
  }

  return (
    <div className="share-page book">
      <ShareHeader />

      <main className="share-content">
        <BookShowcase book={book} onViewBook={handleViewBook} />
        <BookPreviewSection book={book} />
      </main>

      <ShareFooter
        book={book}
        onViewBook={handleViewBook}
        onDownloadBook={handleDownloadBook}
        onSaveToPhotos={handleSaveToPhotos}
      />
    </div>
  )
}
