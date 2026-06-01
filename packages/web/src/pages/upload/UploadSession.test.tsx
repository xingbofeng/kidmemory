import { describe, it, expect } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { UploadSession } from './UploadSession'

describe('UploadSession', () => {
  it('displays session info when session is valid', async () => {
    render(<UploadSession sessionId="test-session-123" sessionToken="test-token" />)

    await waitFor(() => {
      expect(screen.getByText('小明')).toBeInTheDocument()
      expect(screen.getByText('5 / 200')).toBeInTheDocument()
      expect(screen.getByText(/剩余时间/)).toBeInTheDocument()
    })
  })

  it('shows error when session is invalid', async () => {
    render(<UploadSession sessionId="invalid-session" sessionToken="test-token" />)

    await waitFor(() => {
      expect(screen.getByText(/会话已过期或无效/)).toBeInTheDocument()
    })
  })

  it('shows upload limit warning when approaching max uploads', async () => {
    render(<UploadSession sessionId="test-session-near-limit" sessionToken="test-token" />)

    await waitFor(() => {
      expect(screen.getByText(/即将达到上传上限/)).toBeInTheDocument()
    })
  })

  it('prevents upload when max uploads reached', async () => {
    render(<UploadSession sessionId="test-session-at-limit" sessionToken="test-token" />)

    await waitFor(() => {
      expect(screen.getByText(/已达到上传上限/)).toBeInTheDocument()
      expect(screen.getByRole('button', { name: /选择图片/ })).toBeDisabled()
    })
  })
})
