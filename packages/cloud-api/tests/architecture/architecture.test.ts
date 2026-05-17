/**
 * Architecture Tests for Cloud API
 * 
 * Ensures cloud-api maintains same architecture as sidecar
 */

import { describe, it } from 'node:test';
import assert from 'node:assert';
import { readFileSync, existsSync } from 'fs';
import { join } from 'path';

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
        'Job',
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
