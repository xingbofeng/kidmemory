import type { FileTask } from '../../types/trustedUpload'
import { formatSize, statusLabel } from '../../utils/trustedUploadUtils'

interface TaskListProps {
  tasks: FileTask[]
  onClearTasks: () => void
}

export function TaskList({ tasks, onClearTasks }: TaskListProps) {
  return (
    <>
      <div className="trusted-queue-heading">
        <strong>上传队列（{tasks.length}）</strong>
        <button type="button" onClick={onClearTasks} disabled={tasks.length === 0}>
          清空队列
        </button>
      </div>

      <div className="trusted-task-list" aria-live="polite">
        {tasks.length === 0 && (
          <div className="trusted-empty">
            还没有选择图片。请拍照或从相册选择，素材会先上传到可信会话，再由电脑端回拉入库。
          </div>
        )}

        {tasks.map((task) => (
          <article className={`trusted-task trusted-task-${task.status}`} key={task.id}>
            <div className="trusted-thumb" />
            <div className="trusted-task-copy">
              <strong>{task.file.name}</strong>
              <span>{formatSize(task.file.size)}</span>
            </div>
            <div className="trusted-task-status">
              <span>{statusLabel(task.status)}</span>
              {task.status === 'uploading' && <small>{task.progress}%</small>}
              {task.errorMessage && <small>{task.errorMessage}</small>}
            </div>
          </article>
        ))}
      </div>
    </>
  )
}