import { useDirectUploadTasks } from '../../hooks/useDirectUploadTasks'
import type { DirectUploadClient } from '../../lib/direct-upload-client'
import type { DirectUploadConfig } from '../../lib/direct-upload-types'
import { DirectUploadError } from '../../components/upload/DirectUploadError'
import { DirectUploadLoading } from '../../components/upload/DirectUploadLoading'
import { DirectUploadMain } from '../../components/upload/DirectUploadMain'

/**
 * Web Companion Direct Upload Page。
 *
 * 设计参考：
 *   docs/design/images/web-companion-connect-upload.png（视觉延续）
 *   docs/design/images/web-companion-connect-upload.png
 *
 * 安全约束：
 *   - 仅从 query 中读取非敏感配置（sessionId/childId/bucket/supabaseUrl/anonKey/...）。
 *   - 不持久化、不外发任何敏感配置；service role key、本地路径绝不出现。
 *
 * UX：
 *   - 顶部品牌 + 「Supabase 直传验证版」横幅，文案明确「对象需电脑端回拉后才算入库」。
 *   - 文件 picker（拍照 / 相册）+ 张数计数 + 「体验约束」提示。
 *   - 每张图独立 progress / 成功 / 失败状态；单张失败不阻塞其它。
 */

type ClientFactory = (config: DirectUploadConfig) => DirectUploadClient

interface DirectUploadPageProps {
  /** 注入式 query params；未提供时回退到 window.location.search。 */
  searchParams?: URLSearchParams
  /** 测试可注入 fake client factory；默认使用 createDirectUploadClient。 */
  clientFactory?: ClientFactory
}

export function DirectUploadPage({
  searchParams,
  clientFactory,
}: DirectUploadPageProps) {
  const {
    parsed,
    anonKey,
    anonKeyError,
    fullConfig,
    tasks,
    validationError,
    isUploading,
    handleFiles,
  } = useDirectUploadTasks({ searchParams, clientFactory })

  if (!parsed.ok) {
    return (
      <DirectUploadError
        title="无法加载上传页"
        message={`缺少必需参数：${parsed.missing.join(', ')}`}
        description="请重新扫描桌面端生成的二维码，或确认链接未被截断。"
      />
    )
  }

  if (!anonKey) {
    if (anonKeyError) {
      return (
        <DirectUploadError
          title="配置加载失败"
          message={anonKeyError}
          description="请检查网络连接后刷新页面，或重新扫描二维码。"
        />
      )
    }
    return <DirectUploadLoading />
  }

  const config = fullConfig!

  return (
    <DirectUploadMain
      config={config}
      tasks={tasks}
      isUploading={isUploading}
      validationError={validationError}
      onFilesSelected={handleFiles}
    />
  )
}
