import { useTranslation } from 'react-i18next'

export default function HeroSection() {
  const { t } = useTranslation()

  return (
    <section className="hero">
      <div>
        <div className="eyebrow">{t('landing.eyebrow')}</div>
        <h1>KidMemory</h1>
        <p className="slogan">{t('landing.slogan')}</p>
        <p className="desc">{t('landing.desc')}</p>
        <div className="cta">
          <a className="btn primary" href="#vision">{t('landing.cta1')}</a>
          <a className="btn secondary" href="/app">{t('landing.cta2')}</a>
        </div>
        <div className="tags">
          <span className="tag">{t('landing.tag1')}</span>
          <span className="tag">{t('landing.tag2')}</span>
          <span className="tag">{t('landing.tag3')}</span>
        </div>
      </div>

      <div className="visual" aria-label="KidMemory product preview">
        <div className="desktop">
          <div className="top">
            <div className="dots"><span className="dot" /><span className="dot" /><span className="dot" /></div>
            <strong>{t('landing.desktopTitle')}</strong>
            <span />
          </div>
          <div className="product-shot">
            <img src="design/images/page-overview.png" alt="KidMemory product overview" />
          </div>
        </div>
        <div className="phone">
          <div className="screen">
            <img src="design/images/mobile-upload.png" alt="KidMemory mobile upload" />
          </div>
        </div>
        <div className="note-card">
          <b>{t('landing.noteTitle')}</b>
          <span>{t('landing.noteText')}</span>
        </div>
      </div>
    </section>
  )
}
