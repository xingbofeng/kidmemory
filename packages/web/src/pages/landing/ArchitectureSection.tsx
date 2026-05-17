import { useTranslation } from 'react-i18next'

export default function ArchitectureSection() {
  const { t } = useTranslation()

  return (
    <section id="architecture">
      <div className="head">
        <h2>{t('landing.archTitle')}</h2>
        <p>{t('landing.archDesc')}</p>
      </div>
      <div className="arch">
        <div className="agent-map" aria-label="KidMemory architecture illustration">
          <svg className="agent-lines" viewBox="0 0 640 500" preserveAspectRatio="none" aria-hidden="true">
            <path d="M162 132 C238 112 260 192 318 214" />
            <path d="M478 164 C420 178 390 204 330 222" />
            <path d="M176 368 C230 318 276 288 318 246" />
            <path d="M470 356 C424 314 382 282 330 246" />
          </svg>
          <article className="agent-card desktop-node">
            <div className="agent-icon">🖥️</div>
            <b>{t('landing.mapDesktopTitle')}</b>
            <span>{t('landing.mapDesktopDesc')}</span>
          </article>
          <article className="agent-card sidecar-node">
            <div className="agent-icon">🧩</div>
            <b>{t('landing.mapSidecarTitle')}</b>
            <span>{t('landing.mapSidecarDesc')}</span>
          </article>
          <article className="agent-card export-node">
            <div className="agent-icon">💛</div>
            <b>{t('landing.mapOutputTitle')}</b>
            <span>{t('landing.mapOutputDesc')}</span>
          </article>
          <article className="agent-card data-node">
            <div className="agent-icon">🗂️</div>
            <b>{t('landing.mapDataTitle')}</b>
            <span>{t('landing.mapDataDesc')}</span>
          </article>
          <article className="agent-card agent-node">
            <div className="agent-icon">✨</div>
            <b>{t('landing.mapAgentTitle')}</b>
            <span>{t('landing.mapAgentDesc')}</span>
          </article>
          <div className="agent-badge">{t('landing.mapBadge')}</div>
        </div>
        <div className="principles">
          <article className="mini">
            <h3>{t('landing.p1Title')}</h3>
            <p>{t('landing.p1Desc')}</p>
          </article>
          <article className="mini">
            <h3>{t('landing.p2Title')}</h3>
            <p>{t('landing.p2Desc')}</p>
          </article>
          <article className="mini">
            <h3>{t('landing.p3Title')}</h3>
            <p>{t('landing.p3Desc')}</p>
          </article>
          <article className="mini">
            <h3>{t('landing.p4Title')}</h3>
            <p>{t('landing.p4Desc')}</p>
          </article>
        </div>
      </div>
    </section>
  )
}
