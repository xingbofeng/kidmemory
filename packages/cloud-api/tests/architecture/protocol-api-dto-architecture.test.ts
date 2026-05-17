import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

describe('Protocol API DTO Architecture (cloud-api)', () => {
  const root = process.cwd();
  const dtoFiles = [
    'src/modules/devices/devices.dto.ts',
    'src/modules/jobs/jobs.dto.ts',
    'src/modules/upload-items/upload-items.dto.ts',
    'src/modules/web-companion/web-companion.dto.ts',
  ];

  it('dto modules should only alias protocol-generated types', () => {
    for (const file of dtoFiles) {
      const content = readFileSync(resolve(root, file), 'utf-8');
      assert.match(
        content,
        /@kidmemory\/protocol\/generated\/cloud-api\/ts/,
        `${file} must import protocol generated types`,
      );
      assert.doesNotMatch(
        content,
        /\b(class|interface)\s+\w+(Request|Response|Dto)\b/,
        `${file} must not define local Request/Response/Dto class or interface`,
      );
      assert.doesNotMatch(
        content,
        /\btype\s+\w+(Request|Response)\s*=\s*{/,
        `${file} must not define local Request/Response object type`,
      );
    }
  });
});
