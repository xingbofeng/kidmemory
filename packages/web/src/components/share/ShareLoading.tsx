import { Icon } from '../ui/Icon'

interface ShareLoadingProps {
  message?: string
}

export function ShareLoading({ message = '正在验证分享链接...' }: ShareLoadingProps) {
  return (
    <div className="share-page loading">
      <div className="loading-spinner">
        <Icon name="bear-avatar" />
        <p>{message}</p>
      </div>
    </div>
  )
}