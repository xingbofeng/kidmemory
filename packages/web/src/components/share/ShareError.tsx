import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'

interface ShareErrorProps {
  title: string
  message: string
  onRetry?: () => void
  icon?: 'shield' | 'book' | 'bear-avatar'
}

export function ShareError({ title, message, onRetry, icon = 'shield' }: ShareErrorProps) {
  const { t } = useTranslation()

  return (
    <div className="share-page error">
      <div className="error-content">
        <Icon name={icon} />
        <h1>{title}</h1>
        <p>{message}</p>
        {onRetry && (
          <div className="error-actions">
            <button onClick={onRetry}>{t('common.retry')}</button>
          </div>
        )}
      </div>
    </div>
  )
}
