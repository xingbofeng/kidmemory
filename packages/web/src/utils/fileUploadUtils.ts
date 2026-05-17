import i18n from '../i18n'

export function createFileId(file: File): string {
  const randomId = globalThis.crypto?.randomUUID?.() ?? `${Date.now()}-${Math.random().toString(36).slice(2)}`
  return `${randomId}-${file.name}`
}

export function formatCompactRemaining(expiresAt: string): string {
  const remaining = Math.max(0, new Date(expiresAt).getTime() - Date.now())
  const hours = Math.floor(remaining / 3_600_000)
  const minutes = Math.floor((remaining % 3_600_000) / 60_000)

  return i18n.t('time.hoursMinutesShort', { hours, minutes })
}

export const SUPPORTED_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
export const SUPPORTED_TYPE_LABEL = 'JPG、PNG、GIF、WebP'
