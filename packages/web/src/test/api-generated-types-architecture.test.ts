import { readFileSync, readdirSync, statSync } from 'node:fs';
import path from 'node:path';
import { describe, expect, it } from 'vitest';

const SRC_DIR = path.resolve(process.cwd(), 'src');

function read(relPath: string): string {
  return readFileSync(path.join(SRC_DIR, relPath), 'utf8');
}

function listProductionFiles(dir: string): string[] {
  return readdirSync(dir).flatMap((entry) => {
    const fullPath = path.join(dir, entry);
    const stats = statSync(fullPath);

    if (stats.isDirectory()) {
      return listProductionFiles(fullPath);
    }

    if (entry.endsWith('.test.ts') || entry.endsWith('.test.tsx')) {
      return [];
    }

    return /\.(ts|tsx)$/.test(entry) ? [fullPath] : [];
  });
}

describe('web generated api type architecture', () => {
  it('api generated type architecture guard uses current-state wording', () => {
    const source = readFileSync(__filename, 'utf8');
    const historicalSuiteName = ['web api type', 'migration'].join(' ');

    expect(source).not.toContain(historicalSuiteName);
  });

  it('web companion domain type files use generated sidecar protocol types', () => {
    const trustedUploadTypes = read('types/trustedUpload.ts');
    const shareBrowseTypes = read('types/shareBrowse.ts');
    const shareBookTypes = read('types/shareBook.ts');

    expect(trustedUploadTypes).toContain("@kidmemory/protocol/sidecar");
    expect(shareBrowseTypes).toContain("@kidmemory/protocol/sidecar");
    expect(shareBookTypes).toContain("@kidmemory/protocol/sidecar");
  });

  it('web companion production files do not import cloud-api contracts', () => {
    const offenders = listProductionFiles(SRC_DIR)
      .filter((filePath) => readFileSync(filePath, 'utf8').includes('@kidmemory/protocol/cloud-api'))
      .map((filePath) => path.relative(SRC_DIR, filePath));

    expect(offenders).toEqual([]);
  });

  it('legacy upload session helpers are removed from the web companion client', () => {
    const uploadApi = read('api/uploadApi.ts');
    const uploadSession = read('lib/upload-session.ts');
    const assetBrowser = read('pages/browse/AssetBrowser.tsx');

    expect(uploadApi).not.toContain('createUploadSession');
    expect(uploadSession).not.toContain('uploadSessionFile');
    expect(assetBrowser).not.toContain('interface RecentUploadResponse');
  });

  it('signed upload XHR plumbing lives in one shared helper', () => {
    const offenders = listProductionFiles(SRC_DIR)
      .filter((filePath) => readFileSync(filePath, 'utf8').includes('new XMLHttpRequest'))
      .map((filePath) => path.relative(SRC_DIR, filePath));

    expect(offenders).toEqual(['lib/signed-upload.ts']);
  });

  it('api modules avoid hand-written response interfaces', () => {
    const uploadApi = read('api/uploadApi.ts');
    const shareApi = read('api/shareApi.ts');
    const apiTypes = read('types/api.ts');
    const sidecarApi = read('api/sidecarApi.ts');

    expect(uploadApi).not.toMatch(/export interface\s+DirectUploadConfigResponse/);
    expect(uploadApi).not.toMatch(/export interface\s+SessionSummary/);
    expect(uploadApi).not.toMatch(/export interface\s+UploadItem/);
    expect(shareApi).not.toMatch(/export interface\s+ShareTokenValidation/);
    expect(shareApi).not.toMatch(/export interface\s+SharedAsset/);
    expect(shareApi).not.toMatch(/export interface\s+SharedBook/);
    expect(apiTypes).not.toMatch(/export interface\s+\w+Request\b/);
    expect(apiTypes).not.toMatch(/export interface\s+\w+Response\b/);
    expect(sidecarApi).not.toMatch(/export interface\s+\w+Request\b/);
    expect(sidecarApi).not.toMatch(/export interface\s+\w+Response\b/);
  });

  it('pages surface load failures through UI state instead of console logging', () => {
    const offenders = listProductionFiles(path.join(SRC_DIR, 'pages'))
      .filter((filePath) => readFileSync(filePath, 'utf8').includes('console.error'))
      .map((filePath) => path.relative(SRC_DIR, filePath));

    expect(offenders).toEqual([]);
  });

  it('api modules avoid boilerplate module and future-use comments', () => {
    const offenders = [
      'api/index.ts',
      'api/uploadApi.ts',
      'api/shareApi.ts',
      'api/sidecarApi.ts',
      'api/errors.ts',
    ].filter((relPath) => /Module|Handles all|future use|Additional .* as needed|for convenience/.test(read(relPath)));

    expect(offenders).toEqual([]);
  });
});
