import { Icon } from '../ui/Icon'
import type { SelectedFile } from '../../types/fileUpload'

interface UploadListProps {
  selectedFiles: SelectedFile[]
  onRemoveFile: (id: string) => void
  onClearAll?: () => void
}

export function UploadList({ selectedFiles, onRemoveFile, onClearAll }: UploadListProps) {
  return (
    <>
      <div className="queue-heading">
        <h2>上传队列（{selectedFiles.length}）</h2>
        <button
          type="button"
          onClick={onClearAll}
          disabled={selectedFiles.length === 0}
        >
          清空队列
        </button>
      </div>

      <div className="upload-list">
        {selectedFiles.map(selectedFile => (
          <div className="upload-item" key={selectedFile.id}>
            <div className="upload-thumb drawing-thumb" />
            <div className="upload-copy">
              <span>{selectedFile.file.name}</span>
              <small>{(selectedFile.file.size / 1024 / 1024 || 4.2).toFixed(1)} MB</small>
            </div>

            {selectedFile.status === 'pending' && (
              <button
                className="remove-file"
                onClick={() => onRemoveFile(selectedFile.id)}
                aria-label="删除"
              >
                <Icon name="delete" label="删除" />
              </button>
            )}

            {selectedFile.status === 'uploading' && (
              <span className="item-status uploading">上传中</span>
            )}

            {selectedFile.status === 'success' && (
              <span className="item-status success">上传成功</span>
            )}

            {selectedFile.status === 'error' && (
              <span className="item-status danger">{selectedFile.error || '上传失败'}</span>
            )}
          </div>
        ))}

        {selectedFiles.length === 0 && (
          <div className="empty-upload-list">选择图片后会出现在这里</div>
        )}
      </div>
    </>
  )
}