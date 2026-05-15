import { useRef, forwardRef, useImperativeHandle, type ChangeEvent } from 'react'

const ACCEPTED_IMAGE_TYPES = 'image/jpeg,image/png,image/webp,image/heic,image/heif'

interface FilePickerProps {
  onFilesSelected: (files: File[]) => void
}

export interface FilePickerRef {
  triggerGalleryPicker: () => void
}

export const FilePicker = forwardRef<FilePickerRef, FilePickerProps>(
  ({ onFilesSelected }, ref) => {
    const cameraInputRef = useRef<HTMLInputElement>(null)
    const galleryInputRef = useRef<HTMLInputElement>(null)

    useImperativeHandle(ref, () => ({
      triggerGalleryPicker: () => {
        galleryInputRef.current?.click()
      }
    }))

    const onInputChange = (event: ChangeEvent<HTMLInputElement>) => {
      const files = Array.from(event.target.files ?? [])
      event.target.value = ''
      if (files.length > 0) {
        onFilesSelected(files)
      }
    }

    return (
      <div className="picker-row trusted-picker-row">
        <label className="picker-tile trusted-picker">
          📷 拍照
          <input
            ref={cameraInputRef}
            className="file-input"
            type="file"
            accept={ACCEPTED_IMAGE_TYPES}
            capture="environment"
            onChange={onInputChange}
            aria-label="拍照上传"
          />
        </label>
        <label className="picker-tile trusted-picker">
          🖼 从相册选择
          <input
            ref={galleryInputRef}
            className="file-input"
            type="file"
            accept={ACCEPTED_IMAGE_TYPES}
            multiple
            onChange={onInputChange}
            aria-label="从相册选择"
          />
        </label>
      </div>
    )
  }
)