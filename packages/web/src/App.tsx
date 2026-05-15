import { useState } from 'react'
import { BrowserRouter, Routes, Route, useSearchParams } from 'react-router-dom'
import { DirectUploadPage } from './pages/upload/DirectUploadPage'
import { TrustedUploadPage } from './pages/upload/TrustedUploadPage'
import { ShareBrowsePage } from './pages/share/ShareBrowsePage'
import { ShareBookPage } from './pages/share/ShareBookPage'
import { WebCompanionApp, Book } from './components/web-companion/WebCompanionApp'
import LandingPage from './pages/landing/LandingPage'
import './App.css'
import './styles/share.css'
import './styles/landing.css'

const DEFAULT_SESSION_ID = 'test-session-123'
const DEFAULT_CHILD_ID = 'child-123'

// Web Companion 路由组件
function WebCompanionRoute() {
  const [sessionId, setSessionId] = useState<string>(DEFAULT_SESSION_ID)

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

// Direct Upload 路由组件
function DirectUploadRoute() {
  const [searchParams] = useSearchParams()
  return <DirectUploadPage searchParams={searchParams} />
}

// Trusted Upload 路由组件
function TrustedUploadRoute() {
  const [searchParams] = useSearchParams()
  const sessionId = searchParams.get('sessionId')
  const token = searchParams.get('token')

  if (!sessionId || !token) {
    return (
      <div style={{ padding: '20px', textAlign: 'center' }}>
        <h1>错误</h1>
        <p>缺少必要参数：sessionId 和 token</p>
        <button type="button" onClick={() => window.location.assign('/')}>
          返回扫码入口
        </button>
      </div>
    )
  }

  return <TrustedUploadPage sessionId={sessionId} token={token} />
}

// Share Browse 路由组件
function ShareBrowseRoute() {
  const [searchParams] = useSearchParams()
  const token = searchParams.get('token')

  if (!token) {
    return (
      <div style={{ padding: '20px', textAlign: 'center' }}>
        <h1>分享链接无效</h1>
        <p>缺少分享令牌参数</p>
      </div>
    )
  }

  return <ShareBrowsePage shareToken={token} />
}

// Share Book 路由组件
function ShareBookRoute() {
  const [searchParams] = useSearchParams()
  const token = searchParams.get('token')
  const bookId = searchParams.get('bookId')

  if (!token) {
    return (
      <div style={{ padding: '20px', textAlign: 'center' }}>
        <h1>分享链接无效</h1>
        <p>缺少分享令牌参数</p>
      </div>
    )
  }

  return <ShareBookPage shareToken={token} bookId={bookId} />
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* 落地页 */}
        <Route path="/" element={<LandingPage />} />

        {/* Web Companion */}
        <Route path="/app" element={<WebCompanionRoute />} />

        {/* 上传页面 */}
        <Route path="/direct-upload" element={<DirectUploadRoute />} />
        <Route path="/trusted-upload" element={<TrustedUploadRoute />} />

        {/* 分享页面 */}
        <Route path="/share/browse" element={<ShareBrowseRoute />} />
        <Route path="/share/book" element={<ShareBookRoute />} />
      </Routes>
    </BrowserRouter>
  )
}

const recentBooks: Book[] = [
  {
    title: '生日快乐',
    date: '2025-04-28',
    pages: 8,
    tag: '成长纪念册',
    cover: '/sample-assets/birthday-boy.png',
  },
  {
    title: '我们的春游记',
    date: '2025-04-20',
    pages: 10,
    tag: '家庭活动',
    cover: '/sample-assets/family.png',
  },
  {
    title: '晚安，小星星',
    date: '2025-04-15',
    pages: 6,
    tag: '睡前故事',
    cover: '/sample-assets/bear-drawing.png',
  },
]

export default App