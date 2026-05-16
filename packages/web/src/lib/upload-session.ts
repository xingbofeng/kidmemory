import { httpClient, ApiError } from './http-client'
import { UploadResponse, UploadSession } from '../types/api'

export function formatRemainingTime(expiresAt: string): string {
  const remainingTime = new Date(expiresAt).getTime() - Date.now()
  const remainingHours = Math.floor(remainingTime / (1000 * 60 * 60))
  const remainingMinutes = Math.floor((remainingTime % (1000 * 60 * 60)) / (1000 * 60))

  return `${remainingHours}小时${remainingMinutes}分钟`
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

export async function fetchUploadSession(sessionId: string): Promise<UploadSession> {
  try {
    return await httpClient.get<UploadSession>(`/api/web-companion/sessions/${sessionId}`)
  } catch (error) {
    if (error instanceof ApiError) {
      throw new Error(error.message)
    }
    throw error
  }
}

export async function uploadSessionFile(session: UploadSession, file: File): Promise<UploadResponse> {
  const body = new FormData()
  body.append('sessionId', session.sessionId)
  body.append('token', session.token)
  body.append('childId', session.childId)
  body.append('file', file)

  try {
    return await httpClient.post<UploadResponse>('/api/web-companion/upload', body, {
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
