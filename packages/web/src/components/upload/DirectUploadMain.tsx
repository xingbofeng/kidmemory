import { useTranslation } from 'react-i18next'
import type { DirectUploadConfig, DirectUploadFileTask } from '../../lib/direct-upload-types'
import { SessionInfoCard } from './SessionInfoCard'
import { UploadControls } from './UploadControls'
import { UploadTaskList } from './UploadTaskList'

interface DirectUploadMainProps {
  config: DirectUploadConfig
  tasks: DirectUploadFileTask[]
  isUploading: boolean
  validationError: string | null
  onFilesSelected: (files: File[]) => void
}

export function DirectUploadMain({ config, tasks, isUploading, validationError, onFilesSelected }: DirectUploadMainProps) {
  const { t } = useTranslation()
  const successCount = tasks.filter((task) => task.status === 'success').length
  const totalSelected = tasks.length

  return (
    <div className="app">
      <div className="phone-shell" data-view="direct-upload">
        <header className="phone-status" aria-label={t('directUpload.phoneStatus')}>
          <span>9:41</span>
          <span className="status-cluster">▮▮▮ ))) ▭</span>
        </header>

        <main className="app-main">
          <section className="upload-view" aria-labelledby="direct-upload-title">
            <div className="brand-lockup" aria-label={t('directUpload.brandAria')}>
              <strong>KidMemory</strong>
              <small>Web Companion</small>
            </div>

            <div className="inline-alert warning" role="status" data-testid="direct-upload-risk-banner">
              <strong>{t('directUpload.riskTitle')}</strong>
              <span> - {t('directUpload.riskDesc')}</span>
            </div>

            <h1 id="direct-upload-title">{t('directUpload.title')}</h1>

            <SessionInfoCard config={config} totalSelected={totalSelected} />

            <UploadControls
              config={config}
              successCount={successCount}
              totalSelected={totalSelected}
              isUploading={isUploading}
              validationError={validationError}
              onFilesSelected={onFilesSelected}
            />

            <UploadTaskList tasks={tasks} />
          </section>
        </main>
      </div>
    </div>
  )
}
