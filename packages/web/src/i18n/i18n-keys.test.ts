import { describe, expect, it } from 'vitest';

import enUS from './en-US.json';
import zhCN from './zh-CN.json';

function flattenKeys(value: unknown, prefix = '', acc: string[] = []): string[] {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return acc;
  }

  for (const [key, nested] of Object.entries(value)) {
    const path = prefix ? `${prefix}.${key}` : key;
    if (nested && typeof nested === 'object' && !Array.isArray(nested)) {
      flattenKeys(nested, path, acc);
      continue;
    }
    acc.push(path);
  }

  return acc;
}

describe('i18n message bundles', () => {
  it('keeps zh-CN and en-US translation keys in sync', () => {
    const zhKeys = flattenKeys(zhCN).sort();
    const enKeys = flattenKeys(enUS).sort();

    expect(zhKeys).toEqual(enKeys);
  });
});
