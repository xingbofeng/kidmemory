import { getUploadSessionDetail } from '../api/uploadApi'

export interface UploadItemReadyResult {
  status: string
  errorMessage?: string | null
}

export interface WaitForUploadItemReadyOptions {
  maxAttempts?: number
  pollIntervalMs?: number
}

export async function waitForUploadItemReady(
  sessionId: string,
  token: string,
  uploadItemId: string,
  options: WaitForUploadItemReadyOptions = {},
): Promise<UploadItemReadyResult> {
  const maxAttempts = options.maxAttempts ?? 60
  const pollIntervalMs = options.pollIntervalMs ?? 1000

  for (let attempt = 0; attempt < maxAttempts; attempt += 1) {
    const detail = await getUploadSessionDetail(sessionId, token)
    const item = detail.items.find((candidate) => candidate.uploadItemId === uploadItemId)
    if (item?.status === 'ready' || item?.status === 'failed') {
      return { status: item.status, errorMessage: item.errorCode }
    }
    await delay(pollIntervalMs)
  }

  return { status: 'failed', errorMessage: 'Timed out waiting for local import.' }
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms))
}
