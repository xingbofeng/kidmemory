import { useState, useCallback } from 'react'
import { useTranslation } from 'react-i18next'
import { UploadSession as UploadSessionType } from '../../types/api'
import { PhoneShell } from './PhoneShell'
import { AppNavigation, TabType } from './AppNavigation'
import { ConnectView } from './ConnectView'
import { UploadView } from './UploadView'
import { BrowseView } from './BrowseView'
import { BooksView } from './BooksView'

interface Book {
  title: string
  date: string
  pages: number
  tag: string
  cover: string
}

interface WebCompanionAppProps {
  sessionId: string
  sessionToken: string
  recentBooks: Book[]
  onResetSession: () => void
}

export function WebCompanionApp({ sessionId, sessionToken, recentBooks, onResetSession }: WebCompanionAppProps) {
  const { t } = useTranslation()
  const [activeTab, setActiveTab] = useState<TabType>('connect')
  const [activeSession, setActiveSession] = useState<UploadSessionType | null>(null)

  const handleSessionChange = useCallback((session: UploadSessionType | null) => {
    setActiveSession(session)
  }, [])

  const handleStartUpload = () => {
    setActiveTab('upload')
  }

  const handleBackToConnect = () => {
    setActiveTab('connect')
  }

  const renderCurrentView = () => {
    switch (activeTab) {
      case 'connect':
        return (
          <ConnectView
            sessionId={sessionId}
            activeSession={activeSession}
            onSessionChange={handleSessionChange}
            onStartUpload={handleStartUpload}
          />
        )
      case 'upload':
        return <UploadView activeSession={activeSession} sessionToken={sessionToken} onBack={handleBackToConnect} />
      case 'browse':
        return <BrowseView sessionId={sessionId} sessionToken={sessionToken} />
      case 'books':
        return <BooksView recentBooks={recentBooks} />
      default:
        return null
    }
  }

  return (
    <div className="app">
      <PhoneShell activeTab={activeTab}>
        {renderCurrentView()}
        <AppNavigation activeTab={activeTab} onTabChange={setActiveTab} />
      </PhoneShell>

      <button className="reset-session" onClick={onResetSession}>
        {t('webCompanion.resetSession')}
      </button>
    </div>
  )
}

export type { Book }
