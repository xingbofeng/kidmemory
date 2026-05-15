import { Icon } from '../ui/Icon'
import type { SharedBook } from '../../types/shareBook'

interface BookPreviewSectionProps {
  book: SharedBook
}

export function BookPreviewSection({ book }: BookPreviewSectionProps) {
  return (
    <section className="book-preview-section">
      <h3>作品集预览</h3>
      <p>点击下方按钮查看完整的 {book.pageCount} 页作品集</p>

      <div className="preview-grid">
        {/* Mock preview pages */}
        {[1, 2, 3, 4].map((pageNum) => (
          <div key={pageNum} className="preview-page">
            <img
              src={book.previewUrl}
              alt={`第${pageNum}页预览`}
              loading="lazy"
            />
            <span className="page-number">第 {pageNum} 页</span>
          </div>
        ))}
        {book.pageCount && book.pageCount > 4 && (
          <div className="preview-more">
            <Icon name="more" />
            <span>还有 {book.pageCount - 4} 页</span>
          </div>
        )}
      </div>
    </section>
  )
}