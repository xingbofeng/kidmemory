import { useTranslation } from 'react-i18next'
import type { FileTask } from '../../types/trustedUpload'
import { formatSize, statusLabel } from '../../utils/trustedUploadUtils'

interface TaskListProps {
  tasks: FileTask[]
  onClearTasks: () => void
}

export function TaskList({ tasks, onClearTasks }: TaskListProps) {
  const { t } = useTranslation()

  return (
    <>
      <div className="trusted-queue-heading">
        <strong>{t('trustedUpload.queueTitle', { count: tasks.length })}</strong>
        <button type="button" onClick={onClearTasks} disabled={tasks.length === 0}>
          {t('trustedUpload.clearQueue')}
        </button>
      </div>

      <div className="trusted-task-list" aria-live="polite">
        {tasks.length === 0 && <div className="trusted-empty">{t('trustedUpload.queueEmpty')}</div>}

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
