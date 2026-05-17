import { describe, expect, it } from 'vitest'
import { ApiError } from '../api/errors'
import { resolveTrustedUploadErrorMessage } from './trustedUploadError'

const t = (key: string) => (key === 'trustedUpload.authRequired' ? 'AUTH_REQUIRED' : key)

describe('resolveTrustedUploadErrorMessage', () => {
  it('maps api token errors to auth-required message', () => {
    const message = resolveTrustedUploadErrorMessage(new ApiError(401, 'Trusted upload token required'), t)
    expect(message).toBe('AUTH_REQUIRED')
  })

  it('maps generic 401 errors to auth-required message', () => {
    const message = resolveTrustedUploadErrorMessage(new Error('Request failed with status code 401'), t)
    expect(message).toBe('AUTH_REQUIRED')
  })

  it('keeps non-auth api errors unchanged', () => {
    const message = resolveTrustedUploadErrorMessage(new ApiError(500, 'Internal server error'), t)
    expect(message).toBe('Internal server error')
  })
})
