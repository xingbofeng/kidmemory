import { useTranslation } from 'react-i18next'

export default function VisionSection() {
  const { t } = useTranslation()

  return (
    <section id="vision">
      <div className="head">
        <h2>{t('landing.visionTitle')}</h2>
        <p>{t('landing.visionDesc')}</p>
      </div>
      <div className="cards">
        <article className="card">
          <h3>{t('landing.visionCuratedTitle')}</h3>
          <p>{t('landing.visionCuratedDesc')}</p>
        </article>
        <article className="card">
          <h3>{t('landing.visionAiEditorTitle')}</h3>
          <p>{t('landing.visionAiEditorDesc')}</p>
        </article>
        <article className="card">
          <h3>{t('landing.visionPrivateTitle')}</h3>
          <p>{t('landing.visionPrivateDesc')}</p>
        </article>
      </div>
    </section>
  )
}
