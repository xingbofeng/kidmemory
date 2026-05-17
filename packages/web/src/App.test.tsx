import { describe, expect, it } from 'vitest'
import { render, screen } from '@testing-library/react'
import App from './App'

describe('App route guards', () => {
  it('shows a recovery action for trusted upload links missing required params', () => {
    window.history.pushState({}, '', '/trusted-upload?sessionId=only-session')

    render(<App />)

    expect(screen.getByText('缺少必要参数：sessionId 和 token')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '返回扫码入口' })).toBeInTheDocument()
  })
})
