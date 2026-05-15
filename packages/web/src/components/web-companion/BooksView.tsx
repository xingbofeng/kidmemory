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
  return (
    <section className="books-view" aria-labelledby="books-title">
      <div className="screen-title">
        <span className="cloud-mini" />
        <h1 id="books-title">作品集</h1>
        <button className="help-button" aria-label="帮助">
          <Icon name="info" label="帮助" />
        </button>
      </div>
      <div className="books-hero">
        <div>
          <h2>你的专属成长作品集</h2>
          <p>每一份回忆，都值得被珍藏与分享。</p>
        </div>
        <div className="sun-bear" aria-hidden="true">
          <span className="hero-sun">☀</span>
          <Icon name="bear-avatar" />
        </div>
      </div>
      <article className="featured-book">
        <div className="book-cover">
          <img src="/sample-assets/grass-boy.png" alt="阳光的一天封面" />
          <strong>阳光的一天</strong>
        </div>
        <div className="book-copy">
          <div className="book-copy-top">
            <span className="status-pill success"><Icon name="check" /> 已完成</span>
            <button aria-label="更多操作" className="more-button">
              <Icon name="more" label="更多操作" />
            </button>
          </div>
          <h2>阳光的一天</h2>
          <p>记录孩子在阳光下玩耍、探索和成长的美好时光。</p>
          <dl className="book-meta">
            <div><Icon name="pdf" /><dt>页数</dt><dd>12 页</dd></div>
            <div><Icon name="time" /><dt>生成时间</dt><dd>2025-04-30 12:32</dd></div>
          </dl>
          <span className="book-tag">儿童绘本</span>
        </div>
        <div className="book-actions">
          <button><Icon name="pdf" /> 查看 PDF</button>
          <button><Icon name="image" /> 保存到相册</button>
          <button><Icon name="folder" /> 保存到文件</button>
        </div>
      </article>
      <section className="share-panel" aria-labelledby="share-title">
        <div className="share-heading">
          <span className="wechat-mark"><Icon name="link" /></span>
          <div>
            <h2 id="share-title">微信好友分享</h2>
            <p>文件较大，建议通过以下方式分享给微信</p>
          </div>
        </div>
        <div className="share-grid">
          <button><Icon name="download" /> 导出长图<span>生成高清长图</span></button>
          <button><Icon name="more" /> 复制分享文案<span>复制描述与分享语</span></button>
        </div>
        <p className="share-tip">
          <Icon name="info" /> 提示：生成的长图或文案可粘贴到微信聊天中手动发送给家人朋友
        </p>
      </section>
      <section className="recent-books" aria-labelledby="recent-books-title">
        <div className="section-heading">
          <h2 id="recent-books-title">最近作品</h2>
          <button>查看全部 ›</button>
        </div>
        {recentBooks.map((book) => (
          <article className="book-row" key={book.title}>
            <img className="book-thumb" src={book.cover} alt={`${book.title}封面`} />
            <div>
              <h3>{book.title}</h3>
              <p>{book.date} · {book.pages} 页</p>
              <span>{book.tag}</span>
            </div>
            <span className="status-pill success"><Icon name="check" /> 已完成</span>
            <button aria-label={`${book.title}更多操作`} className="row-more">
              <Icon name="more" label={`${book.title}更多操作`} />
            </button>
          </article>
        ))}
      </section>
    </section>
  )
}