import { useTranslation } from 'react-i18next'
import { useDirectUploadTasks } from '../../hooks/useDirectUploadTasks'
import type { DirectUploadClient } from '../../lib/direct-upload-client'
import type { DirectUploadConfig } from '../../lib/direct-upload-types'
import { DirectUploadError } from '../../components/upload/DirectUploadError'
import { DirectUploadLoading } from '../../components/upload/DirectUploadLoading'
import { DirectUploadMain } from '../../components/upload/DirectUploadMain'

type ClientFactory = (config: DirectUploadConfig) => DirectUploadClient

interface DirectUploadPageProps {
  searchParams?: URLSearchParams
  clientFactory?: ClientFactory
}

export function DirectUploadPage({ searchParams, clientFactory }: DirectUploadPageProps) {
  const { t } = useTranslation()
  const { parsed, anonKey, anonKeyError, fullConfig, tasks, validationError, isUploading, handleFiles } = useDirectUploadTasks({
    searchParams,
    clientFactory,
  })

  if (!parsed.ok) {
    return (
      <DirectUploadError
        title={t('directUpload.errorLoadTitle')}
        message={t('directUpload.errorMissingParams', { params: parsed.missing.join(', ') })}
        description={t('directUpload.errorMissingDesc')}
      />
    )
  }

  if (!anonKey) {
    if (anonKeyError) {
      return (
        <DirectUploadError
          title={t('directUpload.errorConfigTitle')}
          message={anonKeyError}
          description={t('directUpload.errorConfigDesc')}
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
