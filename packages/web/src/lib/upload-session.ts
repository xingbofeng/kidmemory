import i18n from '../i18n'
import { httpClient, ApiError } from './http-client'
import { UploadResult, UploadSession } from '../types/api'

type UploadSessionResponse = Partial<UploadSession> & {
  child?: { id?: string; displayName?: string }
}

export function formatRemainingTime(expiresAt: string): string {
  const remainingTime = new Date(expiresAt).getTime() - Date.now()
  const remainingHours = Math.floor(remainingTime / (1000 * 60 * 60))
  const remainingMinutes = Math.floor((remainingTime % (1000 * 60 * 60)) / (1000 * 60))

  return i18n.t('time.hoursMinutes', { hours: remainingHours, minutes: remainingMinutes })
}

export function getUploadStatus(uploadCount: number, maxUploads: number) {
  const isAtLimit = uploadCount >= maxUploads
  const isNearLimit = uploadCount >= maxUploads - 5

  return {
    isAtLimit,
    isNearLimit: isNearLimit && !isAtLimit,
    progress: `${uploadCount} / ${maxUploads}`,
  }
}

export async function fetchUploadSession(sessionId: string, token?: string): Promise<UploadSession> {
  try {
    const query = token ? `?token=${encodeURIComponent(token)}` : ''
    const data = await httpClient.get<UploadSessionResponse>(`/api/web-companion/sessions/${sessionId}${query}`)
    return {
      sessionId: data.sessionId ?? sessionId,
      token: data.token ?? '',
      status: data.status ?? 'active',
      expiresAt: data.expiresAt ?? '',
      childId: data.childId ?? data.child?.id ?? '',
      childName: data.childName ?? data.child?.displayName ?? '',
      maxItems: data.maxItems ?? data.maxUploads ?? 0,
      usedItems: data.usedItems ?? data.uploadCount ?? 0,
      uploadCount: data.uploadCount ?? data.usedItems ?? 0,
      maxUploads: data.maxUploads ?? data.maxItems ?? 0,
      isValid: data.isValid ?? data.status === 'active',
      providers: data.providers,
    }
  } catch (error) {
    if (error instanceof ApiError) {
      throw new Error(error.message)
    }
    throw error
  }
}

export async function uploadSessionFile(session: UploadSession, file: File): Promise<UploadResult> {
  const body = new FormData()
  body.append('sessionId', session.sessionId)
  body.append('token', session.token ?? '')
  body.append('childId', session.childId ?? '')
  body.append('file', file)

  try {
    return await httpClient.post<UploadResult>('/api/web-companion/upload', body, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
  } catch (error) {
    if (error instanceof ApiError) {
      throw new Error(error.message)
    }
    throw new Error('Upload failed')
  }
}
