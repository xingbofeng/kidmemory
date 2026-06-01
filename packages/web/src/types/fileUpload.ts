export interface SelectedFile {
  file: File
  id: string
  status: 'pending' | 'uploading' | 'committing' | 'success' | 'error'
  progress: number
  error?: string
}
