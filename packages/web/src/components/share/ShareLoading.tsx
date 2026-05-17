import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'

interface ShareLoadingProps {
  message?: string
}

export function ShareLoading({ message }: ShareLoadingProps) {
  const { t } = useTranslation()

  return (
    <div className="share-page loading">
      <div className="loading-spinner">
        <Icon name="bear-avatar" />
        <p>{message ?? t('share.loading')}</p>
      </div>
    </div>
  )
}
