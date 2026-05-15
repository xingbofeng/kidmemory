import type { DirectUploadFileTask } from '../../lib/direct-upload-types'

interface UploadTaskListProps {
  tasks: DirectUploadFileTask[]
}

export function UploadTaskList({ tasks }: UploadTaskListProps) {
  return (
    <div className="upload-list" aria-live="polite">
      {tasks.map((task) => (
        <div
          className="upload-item"
          key={task.id}
          data-testid="direct-upload-row"
          data-status={task.status}
        >
          <div className="upload-copy">
            <span>{task.file.name}</span>
            <small>
              {(task.file.size / 1024 / 1024).toFixed(2)} MB
            </small>
          </div>
          {task.status === 'pending' && (
            <span className="item-status">等待中</span>
          )}
          {task.status === 'uploading' && (
            <span className="item-status uploading">
              上传中 {Math.round((task.progress || 0) * 100)}%
            </span>
          )}
          {task.status === 'success' && (
            <span className="item-status success">上传成功</span>
          )}
          {task.status === 'failed' && (
            <span className="item-status danger">
              {task.errorMessage || '上传失败'}
            </span>
          )}
        </div>
      ))}
    </div>
  )
}