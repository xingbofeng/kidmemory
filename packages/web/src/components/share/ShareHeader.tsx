import { Icon } from '../ui/Icon'

export function ShareHeader() {
  return (
    <header className="share-header">
      <div className="share-brand">
        <Icon name="bear-avatar" />
        <div>
          <h1>KidMemory 分享</h1>
          <p>来自家庭的珍贵回忆</p>
        </div>
      </div>
      <div className="share-info">
        <span className="share-type">
          <Icon name="book" />
          作品集分享
        </span>
      </div>
    </header>
  )
}