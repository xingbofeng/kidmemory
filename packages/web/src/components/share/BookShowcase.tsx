import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import type { SharedBook } from '../../types/shareBook'
import { formatShareDate } from '../../utils/shareDate'

interface BookShowcaseProps {
  book: SharedBook
  onViewBook: () => void
}

export function BookShowcase({ book, onViewBook }: BookShowcaseProps) {
  const { t, i18n } = useTranslation()
  const language = i18n.resolvedLanguage ?? i18n.language

  return (
    <article className="book-showcase">
      <div className="book-cover-large">
        <img src={book.previewUrl || '/placeholder-book.png'} alt={t('share.bookCoverAlt', { title: book.title })} />
        <div className="book-overlay">
          <button className="play-button" onClick={onViewBook} aria-label={t('share.previewBookAria', { title: book.title })}>
            <Icon name="pdf" />
            <span>{t('share.previewBookBtn')}</span>
          </button>
        </div>
      </div>

      <div className="book-details">
        <div className="book-header">
          <h2>{book.title}</h2>
          <span className="status-pill success">
            <Icon name="check" />
            {t('share.completed')}
          </span>
        </div>

        <p className="book-description">{book.description}</p>

        <dl className="book-meta">
          <div>
            <dt><Icon name="pdf" />{t('share.metaPages')}</dt>
            <dd>{t('share.pageCount', { count: book.pageCount })}</dd>
          </div>
          <div>
            <dt><Icon name="time" />{t('share.metaCreatedAt')}</dt>
            <dd>{formatShareDate(book.createdAt, language)}</dd>
          </div>
          <div>
            <dt><Icon name="folder" />{t('share.metaType')}</dt>
            <dd>{t('share.bookType')}</dd>
          </div>
        </dl>

        <div className="book-tags">
          <span className="book-tag">{t('share.tag1')}</span>
          <span className="book-tag">{t('share.tag2')}</span>
          <span className="book-tag">{t('share.tag3')}</span>
        </div>
      </div>
    </article>
  )
}
