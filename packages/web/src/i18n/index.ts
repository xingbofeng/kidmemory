import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import zhCN from './zh-CN.json'
import enUS from './en-US.json'

const STORAGE_KEY = 'kidmemory-lang'
const DEFAULT_LANG = 'zh-CN'

function safeGetStorageLanguage(): string | null {
  if (typeof window === 'undefined') return null
  try {
    return window.localStorage.getItem(STORAGE_KEY)
  } catch {
    return null
  }
}

function safeSetStorageLanguage(language: string): void {
  if (typeof window === 'undefined') return
  try {
    window.localStorage.setItem(STORAGE_KEY, language)
  } catch {
    // Ignore storage access errors in constrained test/runtime environments.
  }
}

function normalizeLanguage(input: string | null): 'zh-CN' | 'en-US' {
  if (!input) return DEFAULT_LANG
  const normalized = input.toLowerCase()
  if (normalized.startsWith('en')) return 'en-US'
  return 'zh-CN'
}

const initialLanguage = normalizeLanguage(safeGetStorageLanguage())

i18n.use(initReactI18next).init({
  resources: {
    'zh-CN': { translation: zhCN },
    'en-US': { translation: enUS },
  },
  lng: initialLanguage,
  fallbackLng: DEFAULT_LANG,
  interpolation: {
    escapeValue: false,
  },
})

if (typeof window !== 'undefined') {
  safeSetStorageLanguage(initialLanguage)
  document.documentElement.lang = initialLanguage
  i18n.on('languageChanged', (lng: string) => {
    const next = normalizeLanguage(lng)
    safeSetStorageLanguage(next)
    document.documentElement.lang = next
  })
}

export default i18n
