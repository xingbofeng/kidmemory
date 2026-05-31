/**
 * Architecture Tests for Cloud API
 * 
 * Ensures cloud-api maintains same architecture as sidecar
 */

import { describe, it } from 'node:test';
import assert from 'node:assert';
import { readFileSync, existsSync } from 'fs';
import { readdirSync } from 'fs';
import { join, relative } from 'path';

function listTestFiles(dir: string): string[] {
  const files: string[] = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const fullPath = join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...listTestFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith('.test.ts')) {
      files.push(fullPath);
    }
  }
  return files;
}

function listSourceFiles(dir: string): string[] {
  const files: string[] = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const fullPath = join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...listSourceFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith('.ts')) {
      files.push(fullPath);
    }
  }
  return files;
}

describe('Cloud API Architecture', () => {
  const rootDir = join(process.cwd());
  const sidecarDir = join(rootDir, '../sidecar');

  describe('Project Structure', () => {
    it('should have same directory structure as sidecar', () => {
      const requiredDirs = [
        'src/infrastructure',
        'src/infrastructure/http',
        'src/infrastructure/database',
        'src/infrastructure/security',
        'src/modules',
        'tests/unit',
        'tests/integration',
        'tests/architecture',
        'prisma',
      ];

      for (const dir of requiredDirs) {
        const path = join(rootDir, dir);
        assert.ok(existsSync(path), `Directory ${dir} should exist`);
      }
    });

    it('should have nest-cli.json', () => {
      const path = join(rootDir, 'nest-cli.json');
      assert.ok(existsSync(path), 'nest-cli.json should exist');
    });

    it('should have tsconfig.json', () => {
      const path = join(rootDir, 'tsconfig.json');
      assert.ok(existsSync(path), 'tsconfig.json should exist');
    });

    it('should have tsconfig.build.json', () => {
      const path = join(rootDir, 'tsconfig.build.json');
      assert.ok(existsSync(path), 'tsconfig.build.json should exist');
    });
  });

  describe('Test Quality', () => {
    it('unit tests should exercise production modules instead of local placeholders', () => {
      const offenders = listTestFiles(join(rootDir, 'tests/unit'))
        .filter((file) => !readFileSync(file, 'utf-8').includes('../../../../src/'))
        .map((file) => relative(rootDir, file));

      assert.deepStrictEqual(offenders, []);
    });

    it('service unit tests should use typed Prisma doubles', () => {
      const files = [
        'tests/unit/modules/devices/device-registration.test.ts',
        'tests/unit/modules/upload-items/upload-items.service.test.ts',
      ];
      const offenders = files.filter((file) => /as never|\bas any\b|:\s*any\b|any\[\]/.test(
        readFileSync(join(rootDir, file), 'utf-8'),
      ));

      assert.deepStrictEqual(offenders, []);
    });

    it('sync services should not carry comments that restate the next line', () => {
      const files = [
        'src/modules/devices/devices.service.ts',
        'src/modules/upload-items/upload-items.service.ts',
      ];
      const redundantPatterns = [
        /\/\/ Validate /,
        /\/\/ Update /,
        /\/\/ Allow retry/,
        /\/\/ Terminal state/,
        /\/\/ Higher priority first/,
        /\/\/ Older first/,
        /\/\*\*\s*\n\s*\*\s*(Get|Update|Validate|Register|Check)/,
      ];
      const offenders = files
        .filter((file) => redundantPatterns.some((pattern) => pattern.test(
          readFileSync(join(rootDir, file), 'utf-8'),
        )))
        .map((file) => relative(rootDir, join(rootDir, file)));

      assert.deepStrictEqual(offenders, []);
    });

    it('sync services share status transition checking instead of duplicating includes logic', () => {
      const helperPath = join(rootDir, 'src/infrastructure/state/status-transition.ts');
      const files = [
        'src/modules/upload-items/upload-items.service.ts',
      ];

      assert.ok(existsSync(helperPath), 'status transition helper should exist');
      assert.match(
        readFileSync(helperPath, 'utf-8'),
        /export function isValidStatusTransition\(from: string, to: string, transitions: StatusTransitions\): boolean/,
      );

      for (const file of files) {
        const source = readFileSync(join(rootDir, file), 'utf-8');
        assert.match(source, /infrastructure\/state\/status-transition\.ts/);
        assert.doesNotMatch(source, /validTransitions\[from\]\?\.includes\(to\)/);
        assert.doesNotMatch(source, /private isValidTransition/);
      }
    });

    it('cloud api should not keep the legacy distributed jobs sync surface', () => {
      const forbiddenFiles = [
        'src/modules/jobs',
        'tests/unit/modules/jobs',
      ].filter((file) => existsSync(join(rootDir, file)));
      const sourceChecks = [
        ['src/app.module.ts', /\bJobsModule\b|modules\/jobs/],
        ['prisma/schema.prisma', /\bmodel Job\b|jobs\s+Job\[\]|@@map\("jobs"\)/],
        ['prisma/migrations/init/migration.sql', /CREATE TABLE "jobs"|jobs_deviceId_idx|jobs_status_idx|jobs_deviceId_fkey/],
        ['../protocol/openapi/cloud-api.openapi.yaml', /\/jobs\/pending|\/jobs\/\{id\}\/status|JobResponseDto|UpdateJobStatusRequestDto/],
        ['../protocol/openapi/cloud-api.openapi.json', /"\/jobs\/pending"|"\/jobs\/\{id\}\/status"|JobResponseDto|UpdateJobStatusRequestDto/],
      ];
      const offenders = sourceChecks
        .filter(([file, pattern]) => pattern.test(readFileSync(join(rootDir, file), 'utf-8')))
        .map(([file]) => file);

      assert.deepStrictEqual(
        [...forbiddenFiles, ...offenders],
        [],
      );
    });
  });

  describe('Package Configuration', () => {
    it('should have correct package name', () => {
      const pkg = JSON.parse(readFileSync(join(rootDir, 'package.json'), 'utf-8'));
      assert.strictEqual(pkg.name, '@kidmemory/cloud-api');
    });

    it('should use same Node.js version as sidecar', () => {
      const cloudPkg = JSON.parse(readFileSync(join(rootDir, 'package.json'), 'utf-8'));
      
      if (existsSync(join(sidecarDir, 'package.json'))) {
        const sidecarPkg = JSON.parse(readFileSync(join(sidecarDir, 'package.json'), 'utf-8'));
        assert.strictEqual(cloudPkg.engines.node, sidecarPkg.engines.node);
      }
    });

    it('should use same NestJS version as sidecar', () => {
      const cloudPkg = JSON.parse(readFileSync(join(rootDir, 'package.json'), 'utf-8'));
      
      if (existsSync(join(sidecarDir, 'package.json'))) {
        const sidecarPkg = JSON.parse(readFileSync(join(sidecarDir, 'package.json'), 'utf-8'));
        assert.strictEqual(
          cloudPkg.dependencies['@nestjs/core'],
          sidecarPkg.dependencies['@nestjs/core']
        );
      }
    });

    it('should use same Prisma version as sidecar', () => {
      const cloudPkg = JSON.parse(readFileSync(join(rootDir, 'package.json'), 'utf-8'));
      
      if (existsSync(join(sidecarDir, 'package.json'))) {
        const sidecarPkg = JSON.parse(readFileSync(join(sidecarDir, 'package.json'), 'utf-8'));
        assert.strictEqual(
          cloudPkg.dependencies['@prisma/client'],
          sidecarPkg.dependencies['@prisma/client']
        );
      }
    });
  });

  describe('Infrastructure Layer', () => {
    it('bootstrap logs through Nest logger instead of stdout console', () => {
      const source = readFileSync(join(rootDir, 'src/main.ts'), 'utf-8');

      assert.match(source, /new Logger\(['"]CloudApiBootstrap['"]\)/);
      assert.doesNotMatch(source, /console\.warn|console\.log/);
    });

    it('bootstrap avoids comments that restate setup calls', () => {
      const source = readFileSync(join(rootDir, 'src/main.ts'), 'utf-8');

      assert.doesNotMatch(
        source,
        /Enable shutdown hooks|Configure CORS|Configure security headers|Configure global exception filter|Configure global response interceptor|Configure rate limiting|Configure Swagger\/OpenAPI documentation|Graceful shutdown handling/,
      );
    });

    it('should have GlobalExceptionFilter', () => {
      const path = join(rootDir, 'src/infrastructure/http/global-exception.filter.ts');
      assert.ok(existsSync(path), 'GlobalExceptionFilter should exist');
    });

    it('should have ApiResponseInterceptor', () => {
      const path = join(rootDir, 'src/infrastructure/http/api-response.interceptor.ts');
      assert.ok(existsSync(path), 'ApiResponseInterceptor should exist');
    });

    it('should have RateLimitMiddleware', () => {
      const path = join(rootDir, 'src/infrastructure/security/rate-limit.middleware.ts');
      assert.ok(existsSync(path), 'RateLimitMiddleware should exist');
    });

    it('should have PrismaService', () => {
      const path = join(rootDir, 'src/infrastructure/database/prisma.service.ts');
      assert.ok(existsSync(path), 'PrismaService should exist');
    });

    it('PrismaService logs lifecycle through Nest logger', () => {
      const source = readFileSync(
        join(rootDir, 'src/infrastructure/database/prisma.service.ts'),
        'utf-8',
      );

      assert.match(source, /new Logger\(PrismaService\.name\)/);
      assert.doesNotMatch(source, /console\.warn|console\.error/);
    });

    it('production source logs through framework loggers instead of console', () => {
      const offenders = listSourceFiles(join(rootDir, 'src'))
        .filter((file) => /console\.(log|warn|error)/.test(readFileSync(file, 'utf-8')))
        .map((file) => relative(rootDir, file));

      assert.deepStrictEqual(offenders, []);
    });

    it('controllers share Swagger schema references instead of duplicating helpers', () => {
      const helperPath = join(rootDir, 'src/infrastructure/http/swagger-schema.ts');
      const controllers = [
        'src/modules/devices/devices.controller.ts',
        'src/modules/upload-items/upload-items.controller.ts',
        'src/modules/web-companion/web-companion.controller.ts',
      ];

      assert.ok(existsSync(helperPath), 'Swagger schema helper should exist');
      assert.match(
        readFileSync(helperPath, 'utf-8'),
        /export function schemaRef\(name: string\)/,
      );

      for (const file of controllers) {
        const source = readFileSync(join(rootDir, file), 'utf-8');
        assert.match(source, /infrastructure\/http\/swagger-schema\.ts/);
        assert.doesNotMatch(source, /const schemaRef =/);
      }
    });

    it('rate limit env integer parsing is shared instead of copied inline', () => {
      const helperPath = join(rootDir, 'src/infrastructure/config/env-parsing.ts');
      const middlewarePath = join(rootDir, 'src/infrastructure/security/rate-limit.middleware.ts');
      const source = readFileSync(middlewarePath, 'utf-8');

      assert.ok(existsSync(helperPath), 'env parsing helper should exist');
      assert.match(
        readFileSync(helperPath, 'utf-8'),
        /export function parseEnvInteger\(value: string \| undefined, fallback: number\): number/,
      );
      assert.match(source, /config\/env-parsing\.ts/);
      assert.doesNotMatch(source, /parseInt\(process\.env\./);
      assert.doesNotMatch(source, /Cleanup old entries every minute/);
    });

    it('should have InfrastructureModule', () => {
      const path = join(rootDir, 'src/infrastructure/infrastructure.module.ts');
      assert.ok(existsSync(path), 'InfrastructureModule should exist');
    });
  });

  describe('Database Schema', () => {
    it('should have independent Prisma schema', () => {
      const path = join(rootDir, 'prisma/schema.prisma');
      assert.ok(existsSync(path), 'Prisma schema should exist');
    });

    it('should not contain local-only tables', () => {
      const schemaPath = join(rootDir, 'prisma/schema.prisma');
      const schema = readFileSync(schemaPath, 'utf-8');

      // Should not have local-only tables
      const localOnlyTables = [
        'agent_jobs',
        'agent_runs',
        'agent_configs',
        'asset_embeddings',
      ];

      for (const table of localOnlyTables) {
        assert.ok(
          !schema.includes(`model ${table.charAt(0).toUpperCase() + table.slice(1)}`),
          `Schema should not contain local-only table: ${table}`
        );
      }
    });

    it('should not contain local path fields', () => {
      const schemaPath = join(rootDir, 'prisma/schema.prisma');
      const schema = readFileSync(schemaPath, 'utf-8');

      const localPathFields = [
        'localPath',
        'workspacePath',
        'imagePath',
        'thumbnailPath',
        'pdfPath',
      ];

      for (const field of localPathFields) {
        assert.ok(
          !schema.includes(field),
          `Schema should not contain local path field: ${field}`
        );
      }
    });

    it('should not contain API key fields', () => {
      const schemaPath = join(rootDir, 'prisma/schema.prisma');
      const schema = readFileSync(schemaPath, 'utf-8');

      assert.ok(
        !schema.includes('apiKeyEncrypted'),
        'Schema should not contain apiKeyEncrypted field'
      );
    });

    it('should contain cloud-only tables', () => {
      const schemaPath = join(rootDir, 'prisma/schema.prisma');
      const schema = readFileSync(schemaPath, 'utf-8');

      const cloudOnlyTables = [
        'Device',
        'UploadSession',
        'UploadItem',
        'ShareToken',
      ];

      for (const table of cloudOnlyTables) {
        assert.ok(
          schema.includes(`model ${table}`),
          `Schema should contain cloud-only table: ${table}`
        );
      }
    });
  });

  describe('API Response Format', () => {
    it('should use unified code/msg/data format', () => {
      const interceptorPath = join(rootDir, 'src/infrastructure/http/api-response.interceptor.ts');
      const content = readFileSync(interceptorPath, 'utf-8');

      assert.ok(content.includes('code:'), 'Should have code field');
      assert.ok(content.includes('msg:'), 'Should have msg field');
      assert.ok(content.includes('data') || content.includes('data:'), 'Should have data field');
    });
  });
});
