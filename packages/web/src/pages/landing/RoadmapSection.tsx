import { useTranslation } from 'react-i18next'

export default function RoadmapSection() {
  const { t } = useTranslation()

  return (
    <section id="roadmap">
      <div className="head">
        <h2>{t('landing.roadTitle')}</h2>
        <p>{t('landing.roadDesc')}</p>
      </div>
      <div className="road">
        <article className="phase">
          <b>{t('landing.r1Label')}</b>
          <h3>{t('landing.r1Title')}</h3>
          <p>{t('landing.r1Desc')}</p>
        </article>
        <article className="phase">
          <b>{t('landing.r2Label')}</b>
          <h3>{t('landing.r2Title')}</h3>
          <p>{t('landing.r2Desc')}</p>
        </article>
        <article className="phase">
          <b>{t('landing.r3Label')}</b>
          <h3>{t('landing.r3Title')}</h3>
          <p>{t('landing.r3Desc')}</p>
        </article>
        <article className="phase">
          <b>{t('landing.r4Label')}</b>
          <h3>{t('landing.r4Title')}</h3>
          <p>{t('landing.r4Desc')}</p>
        </article>
        <article className="phase">
          <b>{t('landing.r5Label')}</b>
          <h3>{t('landing.r5Title')}</h3>
          <p>{t('landing.r5Desc')}</p>
        </article>
      </div>
    </section>
  )
}
