export interface SignedUploadTarget {
  method?: string
  url: string
  headers?: Record<string, string>
}

export async function uploadFileWithSignedUrl(
  file: File,
  signedUpload: SignedUploadTarget | undefined,
  onProgress: (progress: number) => void,
): Promise<void> {
  if (!signedUpload) throw new Error('Missing signed upload target')
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest()

    xhr.upload.addEventListener('progress', (event) => {
      if (event.lengthComputable) {
        onProgress(Math.round((event.loaded / event.total) * 100))
      }
    })

    xhr.addEventListener('load', () => {
      if (xhr.status >= 200 && xhr.status < 300) resolve()
      else reject(new Error(`Upload failed (${xhr.status})`))
    })
    xhr.addEventListener('error', () => reject(new Error('Upload failed: network error')))

    xhr.open(String(signedUpload.method ?? 'PUT'), signedUpload.url)
    Object.entries(signedUpload.headers ?? {}).forEach(([key, value]) => {
      xhr.setRequestHeader(key, String(value))
    })
    xhr.send(file)
  })
}
