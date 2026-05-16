import { useRef } from 'react'
import { useTranslation } from 'react-i18next'
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
  const { t } = useTranslation()
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
        <header className="phone-status" aria-label={t('trustedUpload.statusBar')}>
          <span>9:41</span>
          <span className="status-cluster">▮▮▮ ))) ▭</span>
        </header>

        <div className="mobile-browser-bar" aria-label={t('trustedUpload.browserAddress')}>
          <span>🔒</span>
          <span>kidmemory.local/upload</span>
          <span>↻</span>
        </div>

        <main className="app-main trusted-main">
          <section className="trusted-hero" aria-labelledby="trusted-upload-title">
            <button className="trusted-icon-button" aria-label={t('trustedUpload.back')} type="button">←</button>
            <button className="trusted-icon-button" aria-label={t('trustedUpload.settings')} type="button">⚙</button>
            <h1 id="trusted-upload-title">{t('trustedUpload.title')}</h1>
            {session?.child?.displayName && (
              <p className="trusted-child-name">{t('trustedUpload.importForChild', { name: session.child.displayName })}</p>
            )}

            {loading && <div className="trusted-panel trusted-centered">{t('trustedUpload.connecting')}</div>}

            {!loading && error && (
              <div className="inline-alert danger" role="alert">{error}</div>
            )}

            {!loading && session && (
              <>
                <SessionStats session={session} usedCount={usedCount} remainingText={remainingText} />

                <ProviderSelector selectedProvider={selectedProvider} session={session} onProviderChange={setSelectedProvider} />

                <FilePicker ref={filePickerRef} onFilesSelected={handleFileSelect} />

                <TaskList tasks={tasks} onClearTasks={handleClearTasks} />

                <UploadFooter tasks={tasks} onContinueUpload={handleContinueUpload} />
              </>
            )}
          </section>
        </main>
      </div>
    </div>
  )
}
