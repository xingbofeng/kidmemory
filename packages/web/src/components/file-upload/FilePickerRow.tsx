import { useRef, type ChangeEvent } from 'react'
import { Icon } from '../ui/Icon'

interface FilePickerRowProps {
  onFileSelect: (event: ChangeEvent<HTMLInputElement>) => void
  canSelectMore: boolean
  isUploading: boolean
}

export function FilePickerRow({ onFileSelect, canSelectMore, isUploading }: FilePickerRowProps) {
  const fileInputRef = useRef<HTMLInputElement>(null)

  return (
    <div className="picker-row">
      <label className="picker-tile">
        <Icon name="camera" /> 拍照
        <input
          ref={fileInputRef}
          className="file-input"
          type="file"
          multiple
          accept="image/*"
          onChange={onFileSelect}
          disabled={!canSelectMore || isUploading}
          aria-label="选择图片"
        />
      </label>
      <label className="picker-tile">
        <Icon name="image" /> 从相册选择
        <input
          className="file-input"
          type="file"
          multiple
          accept="image/*"
          onChange={onFileSelect}
          disabled={!canSelectMore || isUploading}
          aria-label="相册导入"
        />
      </label>
    </div>
  )
}