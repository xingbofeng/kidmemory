import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'

interface Book {
  title: string
  date: string
  pages: number
  tag: string
  cover: string
}

interface BooksViewProps {
  recentBooks: Book[]
}

export function BooksView({ recentBooks }: BooksViewProps) {
  const { t } = useTranslation()

  return (
    <section className="books-view" aria-labelledby="books-title">
      <div className="screen-title">
        <span className="cloud-mini" />
        <h1 id="books-title">{t('webCompanion.booksTitle')}</h1>
        <button className="help-button" aria-label={t('webCompanion.help')}>
          <Icon name="info" label={t('webCompanion.help')} />
        </button>
      </div>
      <div className="books-hero">
        <div>
          <h2>{t('webCompanion.booksHeroTitle')}</h2>
          <p>{t('webCompanion.booksHeroDesc')}</p>
        </div>
        <div className="sun-bear" aria-hidden="true">
          <span className="hero-sun">☀</span>
          <Icon name="bear-avatar" />
        </div>
      </div>
      <article className="featured-book">
        <div className="book-cover">
          <img src="/sample-assets/grass-boy.png" alt={t('webCompanion.featuredAlt', { title: t('webCompanion.featuredTitle') })} />
          <strong>{t('webCompanion.featuredTitle')}</strong>
        </div>
        <div className="book-copy">
          <div className="book-copy-top">
            <span className="status-pill success"><Icon name="check" /> {t('webCompanion.completed')}</span>
            <button aria-label={t('webCompanion.moreActions')} className="more-button">
              <Icon name="more" label={t('webCompanion.moreActions')} />
            </button>
          </div>
          <h2>{t('webCompanion.featuredTitle')}</h2>
          <p>{t('webCompanion.featuredDesc')}</p>
          <dl className="book-meta">
            <div><Icon name="pdf" /><dt>{t('webCompanion.pageCountLabel')}</dt><dd>{t('webCompanion.pageCount')}</dd></div>
            <div><Icon name="time" /><dt>{t('webCompanion.generatedAtLabel')}</dt><dd>{t('webCompanion.generatedAt')}</dd></div>
          </dl>
          <span className="book-tag">{t('webCompanion.bookTag')}</span>
        </div>
        <div className="book-actions">
          <button><Icon name="pdf" /> {t('webCompanion.viewPdf')}</button>
          <button><Icon name="image" /> {t('webCompanion.saveToAlbum')}</button>
          <button><Icon name="folder" /> {t('webCompanion.saveToFile')}</button>
        </div>
      </article>
      <section className="share-panel" aria-labelledby="share-title">
        <div className="share-heading">
          <span className="wechat-mark"><Icon name="link" /></span>
          <div>
            <h2 id="share-title">{t('webCompanion.wechatShareTitle')}</h2>
            <p>{t('webCompanion.wechatShareDesc')}</p>
          </div>
        </div>
        <div className="share-grid">
          <button><Icon name="download" /> {t('webCompanion.exportLongImage')}<span>{t('webCompanion.exportLongImageHint')}</span></button>
          <button><Icon name="more" /> {t('webCompanion.copyShareCopy')}<span>{t('webCompanion.copyShareCopyHint')}</span></button>
        </div>
        <p className="share-tip"><Icon name="info" /> {t('webCompanion.shareTip')}</p>
      </section>
      <section className="recent-books" aria-labelledby="recent-books-title">
        <div className="section-heading">
          <h2 id="recent-books-title">{t('webCompanion.recentBooks')}</h2>
          <button>{t('uploadLegacy.viewAll')}</button>
        </div>
        {recentBooks.map((book) => (
          <article className="book-row" key={book.title}>
            <img className="book-thumb" src={book.cover} alt={t('webCompanion.featuredAlt', { title: book.title })} />
            <div>
              <h3>{book.title}</h3>
              <p>{t('webCompanion.bookRowMeta', { date: book.date, pages: book.pages })}</p>
              <span>{book.tag}</span>
            </div>
            <span className="status-pill success"><Icon name="check" /> {t('webCompanion.completed')}</span>
            <button aria-label={t('webCompanion.rowMoreAria', { title: book.title })} className="row-more">
              <Icon name="more" label={t('webCompanion.rowMoreAria', { title: book.title })} />
            </button>
          </article>
        ))}
      </section>
    </section>
  )
}
