import { describe, expect, it, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'
import App from './App'

vi.mock('./api/uploadApi', () => ({}))

vi.mock('./components/web-companion/WebCompanionApp', () => ({
  WebCompanionApp: ({ sessionId, sessionToken }: { sessionId: string; sessionToken: string }) => (
    <div>
      <span>web companion session {sessionId}</span>
      <span>web companion token {sessionToken}</span>
    </div>
  ),
}))

describe('App route guards', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('shows a recovery action for trusted upload links missing required params', () => {
    window.history.pushState({}, '', '/trusted-upload?sessionId=only-session')

    render(<App />)

    expect(screen.getByText('缺少必要参数：sessionId 和 token')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '返回扫码入口' })).toBeInTheDocument()
  })

  it('uses the desktop-created session from /app query params', () => {
    window.history.pushState({}, '', '/app?sessionId=session-from-desktop&token=token-from-desktop')

    render(<App />)

    expect(screen.getByText('web companion session session-from-desktop')).toBeInTheDocument()
    expect(screen.getByText('web companion token token-from-desktop')).toBeInTheDocument()
  })

  it('does not create a sample upload session when /app params are missing', () => {
    window.history.pushState({}, '', '/app')

    render(<App />)

    expect(screen.getByText('缺少必要参数：sessionId 和 token')).toBeInTheDocument()
  })
})
