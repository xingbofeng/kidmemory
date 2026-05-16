import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'
import { FileUpload } from '../../pages/upload/FileUpload'
import { UploadSession as UploadSessionType } from '../../types/api'

interface UploadViewProps {
  activeSession: UploadSessionType | null
  onBack: () => void
}

export function UploadView({ activeSession, onBack }: UploadViewProps) {
  const { t } = useTranslation()

  return (
    <section className="upload-view" aria-labelledby="upload-title">
      <div className="top-bar">
        <button className="icon-button" onClick={onBack} aria-label={t('webCompanion.uploadBack')}>
          <Icon name="arrow-left" label={t('webCompanion.uploadBack')} />
        </button>
        <button className="icon-button" aria-label={t('webCompanion.uploadSettings')}>
          <Icon name="settings" label={t('webCompanion.uploadSettings')} />
        </button>
      </div>
      <h1 id="upload-title">{t('webCompanion.uploadTitle')}</h1>
      {activeSession ? <FileUpload session={activeSession} /> : <div className="inline-alert danger">{t('webCompanion.uploadNeedSession')}</div>}
    </section>
  )
}
