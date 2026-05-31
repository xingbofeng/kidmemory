import { describe, it, mock } from 'node:test';
import assert from 'node:assert';
import type { NextFunction, Request, Response } from 'express';

import { LocaleMiddleware } from '../../../../src/infrastructure/http/locale.middleware.ts';

function resolveLocale(acceptLanguage: string | undefined) {
  const middleware = new LocaleMiddleware();
  const request = {
    headers: acceptLanguage === undefined ? {} : { 'accept-language': acceptLanguage },
  } as Request;
  const next = mock.fn();

  middleware.use(request, {} as Response, next as NextFunction);

  assert.strictEqual(next.mock.callCount(), 1);
  return request.locale;
}

describe('LocaleMiddleware', () => {
  it('should default to zh-CN when no Accept-Language header', () => {
    const locale = resolveLocale(undefined);
    assert.strictEqual(locale, 'zh-CN');
  });

  it('should parse zh-CN from Accept-Language', () => {
    const locale = resolveLocale('zh-CN,zh;q=0.9');
    assert.strictEqual(locale, 'zh-CN');
  });

  it('should parse en-US from Accept-Language', () => {
    const locale = resolveLocale('en-US,en;q=0.9');
    assert.strictEqual(locale, 'en-US');
  });

  it('should match language prefix (zh -> zh-CN)', () => {
    const locale = resolveLocale('zh');
    assert.strictEqual(locale, 'zh-CN');
  });

  it('should match language prefix (en -> en-US)', () => {
    const locale = resolveLocale('en');
    assert.strictEqual(locale, 'en-US');
  });

  it('should respect quality values', () => {
    const locale = resolveLocale('en;q=0.8,zh-CN;q=0.9');
    assert.strictEqual(locale, 'zh-CN');
  });

  it('should fallback to zh-CN for unsupported language', () => {
    const locale = resolveLocale('fr-FR,fr;q=0.9');
    assert.strictEqual(locale, 'zh-CN');
  });
});
