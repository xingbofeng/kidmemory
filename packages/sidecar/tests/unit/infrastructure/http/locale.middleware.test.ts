import { describe, it, mock } from 'node:test';
import assert from 'node:assert';

// 纯函数版本用于测试
type Locale = 'zh-CN' | 'en-US';

const SUPPORTED_LOCALES: Locale[] = ['zh-CN', 'en-US'];
const DEFAULT_LOCALE: Locale = 'zh-CN';

function parseLocale(acceptLanguage: string | undefined): Locale {
  if (!acceptLanguage) {
    return DEFAULT_LOCALE;
  }

  const languages = acceptLanguage
    .split(',')
    .map((lang) => {
      const [locale, qValue] = lang.trim().split(';');
      const quality = qValue ? parseFloat(qValue.split('=')[1]) : 1.0;
      return { locale: locale.trim(), quality };
    })
    .sort((a, b) => b.quality - a.quality);

  for (const { locale } of languages) {
    if (SUPPORTED_LOCALES.includes(locale as Locale)) {
      return locale as Locale;
    }
    const prefix = locale.split('-')[0];
    const matched = SUPPORTED_LOCALES.find((supported) =>
      supported.startsWith(prefix),
    );
    if (matched) {
      return matched;
    }
  }

  return DEFAULT_LOCALE;
}

describe('LocaleMiddleware', () => {
  it('should default to zh-CN when no Accept-Language header', () => {
    const locale = parseLocale(undefined);
    assert.strictEqual(locale, 'zh-CN');
  });

  it('should parse zh-CN from Accept-Language', () => {
    const locale = parseLocale('zh-CN,zh;q=0.9');
    assert.strictEqual(locale, 'zh-CN');
  });

  it('should parse en-US from Accept-Language', () => {
    const locale = parseLocale('en-US,en;q=0.9');
    assert.strictEqual(locale, 'en-US');
  });

  it('should match language prefix (zh -> zh-CN)', () => {
    const locale = parseLocale('zh');
    assert.strictEqual(locale, 'zh-CN');
  });

  it('should match language prefix (en -> en-US)', () => {
    const locale = parseLocale('en');
    assert.strictEqual(locale, 'en-US');
  });

  it('should respect quality values', () => {
    const locale = parseLocale('en;q=0.8,zh-CN;q=0.9');
    assert.strictEqual(locale, 'zh-CN');
  });

  it('should fallback to zh-CN for unsupported language', () => {
    const locale = parseLocale('fr-FR,fr;q=0.9');
    assert.strictEqual(locale, 'zh-CN');
  });
});
