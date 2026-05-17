import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { Locale, SUPPORTED_LOCALES, DEFAULT_LOCALE, isValidLocale } from '../src/common/locale.js';

describe('Locale', () => {
  it('支持 zh-CN 和 en-US', () => {
    const zhCN: Locale = 'zh-CN';
    const enUS: Locale = 'en-US';

    assert.equal(zhCN, 'zh-CN');
    assert.equal(enUS, 'en-US');
  });

  it('SUPPORTED_LOCALES 包含所有支持的语言', () => {
    assert.ok(SUPPORTED_LOCALES.includes('zh-CN'));
    assert.ok(SUPPORTED_LOCALES.includes('en-US'));
    assert.equal(SUPPORTED_LOCALES.length, 2);
  });

  it('DEFAULT_LOCALE 为 zh-CN', () => {
    assert.equal(DEFAULT_LOCALE, 'zh-CN');
  });

  it('isValidLocale 可以验证语言代码', () => {
    assert.ok(isValidLocale('zh-CN'));
    assert.ok(isValidLocale('en-US'));
    assert.ok(!isValidLocale('fr-FR'));
    assert.ok(!isValidLocale('invalid'));
  });
});
