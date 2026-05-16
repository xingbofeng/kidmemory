import { useTranslation } from 'react-i18next'

export function DirectUploadLoading() {
  const { t } = useTranslation()

  return (
    <div className="app">
      <div className="phone-shell" data-view="direct-upload-loading">
        <main className="app-main">
          <section className="connect-view" aria-label={t('directUpload.loadingConfigAria')}>
            <div className="brand-lockup">
              <strong>KidMemory</strong>
              <small>Web Companion</small>
            </div>
            <p className="privacy-note" aria-live="polite">{t('directUpload.loadingConfig')}</p>
          </section>
        </main>
      </div>
    </div>
  )
}
