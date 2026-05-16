import { useTranslation } from 'react-i18next'

export default function LandingFooter() {
  const { t } = useTranslation()

  return (
    <footer className="footer page">
      <h2>KidMemory</h2>
      <p>
        <span>{t('landing.footer')}</span>{' '}
        <a href="https://github.com/xingbofeng/kidmemory" target="_blank" rel="noreferrer">
          GitHub
        </a>
      </p>
    </footer>
  )
}
