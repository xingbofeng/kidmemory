import type { FileTask } from '../../types/trustedUpload'

interface UploadFooterProps {
  tasks: FileTask[]
  onContinueUpload: () => void
}

export function UploadFooter({ tasks, onContinueUpload }: UploadFooterProps) {
  const successCount = tasks.filter((t) => t.status === 'success').length
  const failedCount = tasks.filter((t) => t.status === 'failed').length
  const activeCount = tasks.filter((t) => t.status === 'uploading' || t.status === 'committing').length
  const progressPercent = tasks.length === 0 ? 0 : Math.round((successCount / tasks.length) * 100)

  return (
    <footer className="trusted-footer">
      <div className="batch-progress">
        <span>正在上传 {activeCount} 个文件 · 成功 {successCount} · 失败 {failedCount}</span>
        <div><i style={{ width: `${progressPercent}%` }} /></div>
      </div>
      <button className="primary-action" type="button" onClick={onContinueUpload}>
        ☁ 继续上传
      </button>
      <p className="privacy-note">🔒 仅允许上传到本次会话，过期自动失效</p>
    </footer>
  )
}