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

export function DirectUploadMain({
  config,
  tasks,
  isUploading,
  validationError,
  onFilesSelected
}: DirectUploadMainProps) {
  const successCount = tasks.filter((t) => t.status === 'success').length
  const totalSelected = tasks.length

  return (
    <div className="app">
      <div className="phone-shell" data-view="direct-upload">
        <header className="phone-status" aria-label="手机状态栏">
          <span>9:41</span>
          <span className="status-cluster">▮▮▮ ))) ▭</span>
        </header>

        <main className="app-main">
          <section className="upload-view" aria-labelledby="direct-upload-title">
            <div className="brand-lockup" aria-label="KidMemory Web Companion">
              <strong>KidMemory</strong>
              <small>Web Companion</small>
            </div>

            <div
              className="inline-alert warning"
              role="status"
              data-testid="direct-upload-risk-banner"
            >
              <strong>Supabase 直传验证版</strong>
              <span> — 对象需电脑端回拉后才算入库</span>
            </div>

            <h1 id="direct-upload-title">扫码上传素材</h1>

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