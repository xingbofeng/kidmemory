import { useState } from 'react'
import { BrowserRouter, Routes, Route, useSearchParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { DirectUploadPage } from './pages/upload/DirectUploadPage'
import { TrustedUploadPage } from './pages/upload/TrustedUploadPage'
import { ShareBrowsePage } from './pages/share/ShareBrowsePage'
import { ShareBookPage } from './pages/share/ShareBookPage'
import { WebCompanionApp, Book } from './components/web-companion/WebCompanionApp'
import LandingPage from './pages/landing/LandingPage'
import './i18n'
import './App.css'
import './styles/share.css'
import './styles/landing.css'

const DEFAULT_SESSION_ID = 'test-session-123'
const DEFAULT_CHILD_ID = 'child-123'

function WebCompanionRoute() {
  const { t } = useTranslation()
  const [sessionId, setSessionId] = useState<string>(DEFAULT_SESSION_ID)
  const recentBooks: Book[] = [
    {
      title: t('webCompanion.sampleBook1Title'),
      date: '2025-04-28',
      pages: 8,
      tag: t('webCompanion.sampleBook1Tag'),
      cover: '/sample-assets/birthday-boy.png',
    },
    {
      title: t('webCompanion.sampleBook2Title'),
      date: '2025-04-20',
      pages: 10,
      tag: t('webCompanion.sampleBook2Tag'),
      cover: '/sample-assets/family.png',
    },
    {
      title: t('webCompanion.sampleBook3Title'),
      date: '2025-04-15',
      pages: 6,
      tag: t('webCompanion.sampleBook3Tag'),
      cover: '/sample-assets/bear-drawing.png',
    },
  ]

  const handleResetSession = () => {
    setSessionId(`session-${Date.now()}`)
  }

  return (
    <WebCompanionApp
      sessionId={sessionId}
      defaultChildId={DEFAULT_CHILD_ID}
      recentBooks={recentBooks}
      onResetSession={handleResetSession}
    />
  )
}

function DirectUploadRoute() {
  const [searchParams] = useSearchParams()
  return <DirectUploadPage searchParams={searchParams} />
}

function TrustedUploadRoute() {
  const { t } = useTranslation()
  const [searchParams] = useSearchParams()
  const sessionId = searchParams.get('sessionId')
  const token = searchParams.get('token')

  if (!sessionId || !token) {
    return (
      <div style={{ padding: '20px', textAlign: 'center' }}>
        <h1>{t('app.errorTitle')}</h1>
        <p>{t('app.missingTrustedParams')}</p>
        <button type="button" onClick={() => window.location.assign('/')}>
          {t('app.backToHome')}
        </button>
      </div>
    )
  }

  return <TrustedUploadPage sessionId={sessionId} token={token} />
}

function ShareBrowseRoute() {
  const { t } = useTranslation()
  const [searchParams] = useSearchParams()
  const token = searchParams.get('token')

  if (!token) {
    return (
      <div style={{ padding: '20px', textAlign: 'center' }}>
        <h1>{t('app.invalidShareLink')}</h1>
        <p>{t('app.missingShareToken')}</p>
      </div>
    )
  }

  return <ShareBrowsePage shareToken={token} />
}

function ShareBookRoute() {
  const { t } = useTranslation()
  const [searchParams] = useSearchParams()
  const token = searchParams.get('token')
  const bookId = searchParams.get('bookId')

  if (!token) {
    return (
      <div style={{ padding: '20px', textAlign: 'center' }}>
        <h1>{t('app.invalidShareLink')}</h1>
        <p>{t('app.missingShareToken')}</p>
      </div>
    )
  }

  return <ShareBookPage shareToken={token} bookId={bookId} />
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/app" element={<WebCompanionRoute />} />
        <Route path="/direct-upload" element={<DirectUploadRoute />} />
        <Route path="/trusted-upload" element={<TrustedUploadRoute />} />
        <Route path="/share/browse" element={<ShareBrowseRoute />} />
        <Route path="/share/book" element={<ShareBookRoute />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
