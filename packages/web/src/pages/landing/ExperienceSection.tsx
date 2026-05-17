import { useTranslation } from 'react-i18next'

export default function ExperienceSection() {
  const { t } = useTranslation()

  return (
    <section id="experience">
      <div className="head">
        <h2>{t('landing.experienceTitle')}</h2>
        <p>{t('landing.experienceDesc')}</p>
      </div>
      <div className="flow">
        <article className="step">
          <small>01</small>
          <h3>{t('landing.f1Title')}</h3>
          <p>{t('landing.f1Desc')}</p>
        </article>
        <article className="step">
          <small>02</small>
          <h3>{t('landing.f2Title')}</h3>
          <p>{t('landing.f2Desc')}</p>
        </article>
        <article className="step">
          <small>03</small>
          <h3>{t('landing.f3Title')}</h3>
          <p>{t('landing.f3Desc')}</p>
        </article>
        <article className="step">
          <small>04</small>
          <h3>{t('landing.f4Title')}</h3>
          <p>{t('landing.f4Desc')}</p>
        </article>
      </div>
    </section>
  )
}
