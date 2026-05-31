export function formatShareDate(dateString: string, language: string | undefined) {
  const locale = (language ?? 'zh-CN').startsWith('en') ? 'en-US' : 'zh-CN'
  return new Date(dateString).toLocaleDateString(locale, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}
