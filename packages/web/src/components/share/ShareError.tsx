import { Icon } from '../ui/Icon'

interface ShareErrorProps {
  title: string
  message: string
  onRetry?: () => void
  icon?: 'shield' | 'book' | 'bear-avatar'
}

export function ShareError({ title, message, onRetry, icon = 'shield' }: ShareErrorProps) {
  return (
    <div className="share-page error">
      <div className="error-content">
        <Icon name={icon} />
        <h1>{title}</h1>
        <p>{message}</p>
        {onRetry && (
          <div className="error-actions">
            <button onClick={onRetry}>
              重试
            </button>
          </div>
        )}
      </div>
    </div>
  )
}