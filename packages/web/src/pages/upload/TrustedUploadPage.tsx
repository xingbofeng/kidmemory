import { useRef } from 'react'
import { useTrustedUploadSession } from '../../hooks/useTrustedUploadSession'
import { SessionStats } from '../../components/trusted-upload/SessionStats'
import { ProviderSelector } from '../../components/trusted-upload/ProviderSelector'
import { FilePicker, type FilePickerRef } from '../../components/trusted-upload/FilePicker'
import { TaskList } from '../../components/trusted-upload/TaskList'
import { UploadFooter } from '../../components/trusted-upload/UploadFooter'

interface TrustedUploadPageProps {
  sessionId: string
  token: string
}

export function TrustedUploadPage({ sessionId, token }: TrustedUploadPageProps) {
  const filePickerRef = useRef<FilePickerRef>(null)

  const {
    session,
    tasks,
    loading,
    error,
    selectedProvider,
    remainingText,
    usedCount,
    setSelectedProvider,
    handleFileSelect,
    handleClearTasks,
  } = useTrustedUploadSession({ sessionId, token })

  const handleContinueUpload = () => {
    filePickerRef.current?.triggerGalleryPicker()
  }

  return (
    <div className="app trusted-app">
      <div className="phone-shell trusted-shell" data-view="trusted-upload">
        <header className="phone-status" aria-label="手机状态栏">
          <span>9:41</span>
          <span className="status-cluster">▮▮▮ ))) ▭</span>
        </header>

        <div className="mobile-browser-bar" aria-label="浏览器地址">
          <span>🔒</span>
          <span>kidmemory.local/upload</span>
          <span>↻</span>
        </div>

        <main className="app-main trusted-main">
          <section className="trusted-hero" aria-labelledby="trusted-upload-title">
            <button className="trusted-icon-button" aria-label="返回" type="button">←</button>
            <button className="trusted-icon-button" aria-label="上传设置" type="button">⚙</button>
            <h1 id="trusted-upload-title">选择并上传照片</h1>
            {session?.child.displayName && (
              <p className="trusted-child-name">正在为 {session.child.displayName} 导入素材</p>
            )}

            {loading && (
              <div className="trusted-panel trusted-centered">正在连接电脑端会话…</div>
            )}

            {!loading && error && (
              <div className="inline-alert danger" role="alert">{error}</div>
            )}

            {!loading && session && (
              <>
                <SessionStats
                  session={session}
                  usedCount={usedCount}
                  remainingText={remainingText}
                />

                <ProviderSelector
                  selectedProvider={selectedProvider}
                  session={session}
                  onProviderChange={setSelectedProvider}
                />

                <FilePicker ref={filePickerRef} onFilesSelected={handleFileSelect} />

                <TaskList
                  tasks={tasks}
                  onClearTasks={handleClearTasks}
                />

                <UploadFooter
                  tasks={tasks}
                  onContinueUpload={handleContinueUpload}
                />
              </>
            )}
          </section>
        </main>
      </div>
    </div>
  )
}
