import { useTranslation } from 'react-i18next'

export default function FinalSection() {
  const { t } = useTranslation()

  return (
    <section>
      <div className="final">
        <img src="design/images/design-system-overview.png" alt="KidMemory design system overview" />
        <div>
          <h2>{t('landing.finalTitle')}</h2>
          <p>{t('landing.finalDesc')}</p>
          <a className="btn primary" href="/app">
            {t('landing.finalCta')}
          </a>
        </div>
      </div>
    </section>
  )
}
