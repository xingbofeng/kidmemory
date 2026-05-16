import i18n from '../i18n'

export function nextTaskId(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID()
  }
  return `task-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`
}

export function formatRemaining(expiresAt: string): string {
  const remainingMs = new Date(expiresAt).getTime() - Date.now()
  if (!Number.isFinite(remainingMs) || remainingMs <= 0) return i18n.t('trustedUploadStatus.expired')
  const minutes = Math.floor(remainingMs / 60000)
  const hours = Math.floor(minutes / 60)
  const rest = minutes % 60
  if (hours <= 0) return i18n.t('trustedUploadStatus.minutes', { count: rest })
  return i18n.t('trustedUploadStatus.hoursMinutes', { hours, minutes: rest })
}

export function formatSize(size: number): string {
  if (size >= 1024 * 1024) return `${(size / 1024 / 1024).toFixed(1)} MB`
  return `${Math.max(1, Math.round(size / 1024))} KB`
}

export function statusLabel(status: 'pending' | 'uploading' | 'committing' | 'success' | 'failed'): string {
  switch (status) {
    case 'pending':
      return i18n.t('trustedUploadStatus.pending')
    case 'uploading':
      return i18n.t('trustedUploadStatus.uploading')
    case 'committing':
      return i18n.t('trustedUploadStatus.committing')
    case 'success':
      return i18n.t('trustedUploadStatus.success')
    case 'failed':
      return i18n.t('trustedUploadStatus.failed')
  }
}
