import { Icon } from '../ui/Icon'
import { UploadSession } from '../../pages/upload/UploadSession'
import { UploadSession as UploadSessionType } from '../../types/api'

interface ConnectViewProps {
  sessionId: string
  activeSession: UploadSessionType | null
  onSessionChange: (session: UploadSessionType | null) => void
  onStartUpload: () => void
}

export function ConnectView({
  sessionId,
  activeSession,
  onSessionChange,
  onStartUpload
}: ConnectViewProps) {
  return (
    <section className="connect-view" aria-labelledby="connect-title">
      <div className="cloud cloud-left" />
      <div className="cloud cloud-right" />
      <div className="brand-lockup" aria-label="KidMemory Web Companion">
        <span className="brand-mark"><Icon name="bear-avatar" /></span>
        <strong>KidMemory</strong>
        <small>Web Companion</small>
      </div>
      <h1 id="connect-title">扫码上传素材</h1>
      <p className="lead">无需登录，会话将在 3 小时后过期</p>

      <UploadSession sessionId={sessionId} onSessionChange={onSessionChange} />

      <button
        className="primary-action"
        onClick={onStartUpload}
        disabled={!activeSession || activeSession.isValid === false}
      >
        <Icon name="image" /> 开始选择图片
      </button>
      <p className="privacy-note"><Icon name="shield" /> 仅允许上传到本次会话，过期自动失效</p>
      <div className="ground-art" aria-hidden="true">
        <span className="sprout">♧</span>
        <span className="hill" />
        <span className="bear">ʕ•ᴥ•ʔ</span>
      </div>
    </section>
  )
}