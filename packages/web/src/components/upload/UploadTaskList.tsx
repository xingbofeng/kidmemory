import { useTranslation } from 'react-i18next'
import type { DirectUploadFileTask } from '../../lib/direct-upload-types'

interface UploadTaskListProps {
  tasks: DirectUploadFileTask[]
}

export function UploadTaskList({ tasks }: UploadTaskListProps) {
  const { t } = useTranslation()

  return (
    <div className="upload-list" aria-live="polite">
      {tasks.map((task) => (
        <div className="upload-item" key={task.id} data-testid="direct-upload-row" data-status={task.status}>
          <div className="upload-copy">
            <span>{task.file.name}</span>
            <small>{(task.file.size / 1024 / 1024).toFixed(2)} MB</small>
          </div>
          {task.status === 'pending' && <span className="item-status">{t('directUpload.taskPending')}</span>}
          {task.status === 'uploading' && (
            <span className="item-status uploading">{t('directUpload.taskUploading', { percent: Math.round((task.progress || 0) * 100) })}</span>
          )}
          {task.status === 'importing' && <span className="item-status uploading">{t('directUpload.taskImporting')}</span>}
          {task.status === 'success' && <span className="item-status success">{t('directUpload.taskSuccess')}</span>}
          {task.status === 'failed' && <span className="item-status danger">{task.errorMessage || t('directUpload.taskFailed')}</span>}
        </div>
      ))}
    </div>
  )
}
