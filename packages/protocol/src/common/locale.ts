/**
 * 支持的语言类型
 */
export type Locale = 'zh-CN' | 'en-US';

/**
 * 所有支持的语言列表
 */
export const SUPPORTED_LOCALES: readonly Locale[] = ['zh-CN', 'en-US'] as const;

/**
 * 默认语言
 */
export const DEFAULT_LOCALE: Locale = 'zh-CN';

/**
 * 验证语言代码是否有效
 *
 * @param locale - 待验证的语言代码
 * @returns 是否为有效的语言代码
 */
export function isValidLocale(locale: string): locale is Locale {
  return SUPPORTED_LOCALES.includes(locale as Locale);
}
