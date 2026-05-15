import { Icon } from '../ui/Icon'
import { FileUpload } from '../../pages/upload/FileUpload'
import { UploadSession as UploadSessionType } from '../../types/api'

interface UploadViewProps {
  activeSession: UploadSessionType | null
  onBack: () => void
}

export function UploadView({ activeSession, onBack }: UploadViewProps) {
  return (
    <section className="upload-view" aria-labelledby="upload-title">
      <div className="top-bar">
        <button className="icon-button" onClick={onBack} aria-label="返回">
          <Icon name="arrow-left" label="返回" />
        </button>
        <button className="icon-button" aria-label="上传设置">
          <Icon name="settings" label="上传设置" />
        </button>
      </div>
      <h1 id="upload-title">选择并上传照片</h1>
      {activeSession ? (
        <FileUpload session={activeSession} />
      ) : (
        <div className="inline-alert danger">请先返回连接页，获取有效上传会话</div>
      )}
    </section>
  )
}