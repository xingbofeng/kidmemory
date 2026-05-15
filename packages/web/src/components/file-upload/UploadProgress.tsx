import { Icon } from '../ui/Icon'
import type { SelectedFile } from '../../types/fileUpload'

interface UploadProgressProps {
  selectedFiles: SelectedFile[]
  isUploading: boolean
  onUpload: () => void
}

export function UploadProgress({ selectedFiles, isUploading, onUpload }: UploadProgressProps) {
  const uploadingCount = selectedFiles.filter(file => file.status === 'uploading').length

  return (
    <>
      {isUploading && (
        <div className="batch-progress">
          <span><Icon name="cloud-upload" /> 正在上传 {uploadingCount} 个文件</span>
          <div><i /></div>
        </div>
      )}

      <button
        className="primary-action"
        onClick={onUpload}
        aria-label="开始上传"
        disabled={selectedFiles.length === 0 || isUploading}
      >
        <Icon name="upload" /> {selectedFiles.length > 0 ? '开始上传' : '继续上传'}
      </button>
    </>
  )
}