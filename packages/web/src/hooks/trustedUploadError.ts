import { ApiError } from '../api/errors'

function isAuthFailureMessage(message: string) {
  const normalized = message.toLowerCase()
  return (
    normalized.includes('token')
    || normalized.includes('unauthorized')
    || normalized.includes('authorization')
    || normalized.includes('access denied')
    || normalized.includes('401')
  )
}

export function resolveTrustedUploadErrorMessage(
  error: unknown,
  t: (key: string) => string,
) {
  if (error instanceof ApiError) {
    if (isAuthFailureMessage(error.message)) {
      return t('trustedUpload.authRequired')
    }
    return error.message
  }

  if (error instanceof Error) {
    if (isAuthFailureMessage(error.message)) {
      return t('trustedUpload.authRequired')
    }
    return error.message
  }

  const fallback = String(error)
  if (isAuthFailureMessage(fallback)) {
    return t('trustedUpload.authRequired')
  }
  return fallback
}
