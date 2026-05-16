import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import type { SharedBook } from '../../types/shareBook'

interface BookPreviewSectionProps {
  book: SharedBook
}

export function BookPreviewSection({ book }: BookPreviewSectionProps) {
  const { t } = useTranslation()

  return (
    <section className="book-preview-section">
      <h3>{t('share.previewTitle')}</h3>
      <p>{t('share.previewDesc', { count: book.pageCount })}</p>

      <div className="preview-grid">
        {[1, 2, 3, 4].map((pageNum) => (
          <div key={pageNum} className="preview-page">
            <img
              src={book.previewUrl}
              alt={t('share.pagePreviewAlt', { page: pageNum })}
              loading="lazy"
            />
            <span className="page-number">{t('share.pageLabel', { page: pageNum })}</span>
          </div>
        ))}
        {book.pageCount && book.pageCount > 4 && (
          <div className="preview-more">
            <Icon name="more" />
            <span>{t('share.remainingPages', { count: book.pageCount - 4 })}</span>
          </div>
        )}
      </div>
    </section>
  )
}
