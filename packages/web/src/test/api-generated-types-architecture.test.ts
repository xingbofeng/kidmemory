import { readFileSync } from 'node:fs';
import path from 'node:path';
import { describe, expect, it } from 'vitest';

const SRC_DIR = path.resolve(process.cwd(), 'src');

function read(relPath: string): string {
  return readFileSync(path.join(SRC_DIR, relPath), 'utf8');
}

describe('web api type migration', () => {
  it('domain type files use generated cloud-api protocol types', () => {
    const trustedUploadTypes = read('types/trustedUpload.ts');
    const shareBrowseTypes = read('types/shareBrowse.ts');
    const shareBookTypes = read('types/shareBook.ts');

    expect(trustedUploadTypes).toContain("@kidmemory/protocol/generated/cloud-api/ts");
    expect(shareBrowseTypes).toContain("@kidmemory/protocol/generated/cloud-api/ts");
    expect(shareBookTypes).toContain("@kidmemory/protocol/generated/cloud-api/ts");
  });

  it('api modules avoid hand-written response interfaces', () => {
    const uploadApi = read('api/uploadApi.ts');
    const shareApi = read('api/shareApi.ts');

    expect(uploadApi).not.toMatch(/export interface\s+DirectUploadConfigResponse/);
    expect(uploadApi).not.toMatch(/export interface\s+SessionSummary/);
    expect(uploadApi).not.toMatch(/export interface\s+UploadItem/);
    expect(shareApi).not.toMatch(/export interface\s+ShareTokenValidation/);
    expect(shareApi).not.toMatch(/export interface\s+SharedAsset/);
    expect(shareApi).not.toMatch(/export interface\s+SharedBook/);
  });
});
