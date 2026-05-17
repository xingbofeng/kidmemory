import { useTranslation } from 'react-i18next'

const LANGUAGE_OPTIONS = [
  { id: 'zh-CN', labelKey: 'lang.zh' },
  { id: 'en-US', labelKey: 'lang.en' },
] as const

export default function LanguageToggle() {
  const { t, i18n } = useTranslation()
  const activeLanguage = i18n.resolvedLanguage ?? i18n.language ?? 'zh-CN'
  const currentLang = activeLanguage.startsWith('en') ? 'en-US' : 'zh-CN'

  return (
    <div className="lang" aria-label="Language switcher">
      {LANGUAGE_OPTIONS.map((option) => (
        <button
          key={option.id}
          className={currentLang === option.id ? 'active' : ''}
          onClick={() => i18n.changeLanguage(option.id)}
          type="button"
        >
          {t(option.labelKey)}
        </button>
      ))}
    </div>
  )
}
