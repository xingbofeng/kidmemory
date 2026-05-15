import { Icon } from '../ui/Icon'

export function RouteSelector() {
  return (
    <div className="route-selector" aria-label="上传通道">
      <button className="selected">
        <Icon name="link" />
        <strong>局域网直传</strong>
        <span>优先使用，速度更快</span>
      </button>
      <button>
        <Icon name="cloud-upload" />
        <strong>公网直传</strong>
        <span>备用通道（待命中）</span>
      </button>
    </div>
  )
}