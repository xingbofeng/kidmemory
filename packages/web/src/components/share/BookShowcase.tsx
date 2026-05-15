import { Icon } from '../ui/Icon'
import type { SharedBook } from '../../types/shareBook'

interface BookShowcaseProps {
  book: SharedBook
  onViewBook: () => void
}

export function BookShowcase({ book, onViewBook }: BookShowcaseProps) {
  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  return (
    <article className="book-showcase">
      <div className="book-cover-large">
        <img
          src={book.previewUrl || '/placeholder-book.png'}
          alt={`${book.title}封面`}
        />
        <div className="book-overlay">
          <button
            className="play-button"
            onClick={onViewBook}
            aria-label={`预览${book.title}`}
          >
            <Icon name="pdf" />
            <span>预览作品集</span>
          </button>
        </div>
      </div>

      <div className="book-details">
        <div className="book-header">
          <h2>{book.title}</h2>
          <span className="status-pill success">
            <Icon name="check" />
            已完成
          </span>
        </div>

        <p className="book-description">{book.description}</p>

        <dl className="book-meta">
          <div>
            <dt><Icon name="pdf" />页数</dt>
            <dd>{book.pageCount} 页</dd>
          </div>
          <div>
            <dt><Icon name="time" />创建时间</dt>
            <dd>{formatDate(book.createdAt)}</dd>
          </div>
          <div>
            <dt><Icon name="folder" />类型</dt>
            <dd>儿童成长记录</dd>
          </div>
        </dl>

        <div className="book-tags">
          <span className="book-tag">儿童绘本</span>
          <span className="book-tag">成长记录</span>
          <span className="book-tag">家庭回忆</span>
        </div>
      </div>
    </article>
  )
}