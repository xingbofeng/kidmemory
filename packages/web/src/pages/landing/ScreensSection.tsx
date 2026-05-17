import { useTranslation } from 'react-i18next'

export default function ScreensSection() {
  const { t } = useTranslation()

  return (
    <section id="screens">
      <div className="head">
        <h2>{t('landing.screensTitle')}</h2>
        <p>{t('landing.screensDesc')}</p>
      </div>
      <div className="showcase">
        <article className="show-main">
          <img src="design/images/desktop-asset-library.png" alt="KidMemory desktop asset library" />
          <div className="show-copy">
            <h3>{t('landing.assetTitle')}</h3>
            <p>{t('landing.assetDesc')}</p>
          </div>
        </article>
        <div className="show-side">
          <article>
            <img src="design/images/desktop-generate-export.png" alt="KidMemory generate and export" />
            <div className="show-copy">
              <h3>{t('landing.generateTitle')}</h3>
              <p>{t('landing.generateDesc')}</p>
            </div>
          </article>
          <article>
            <img src="design/images/mobile-books-share.png" alt="KidMemory Web Companion books and share" />
            <div className="show-copy">
              <h3>{t('landing.mobileTitle')}</h3>
              <p>{t('landing.mobileDesc')}</p>
            </div>
          </article>
        </div>
      </div>
    </section>
  )
}
