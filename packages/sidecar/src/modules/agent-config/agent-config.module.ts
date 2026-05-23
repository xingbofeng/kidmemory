/**
 * Agent Configuration Module
 *
 * NestJS module that wires together all the components of the Agent Configuration feature.
 * Follows Clean Architecture principles with proper dependency injection.
 */

import { Module } from "@nestjs/common";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { PrismaService } from "../../infrastructure/database/prisma.service.ts";
import { EncryptionService } from "../security/encryption.service.ts";

// Domain
import { AgentConfigDomainService } from './domain/agent-config-domain.service.ts';

// Application
import { AgentConfigApplicationService } from './application/agent-config-application.service.ts';

// Ports (interfaces)
import {
  AGENT_CONFIG_REPOSITORY,
  AGENT_TESTING_PORT,
  AUDIT_LOGGER_PORT,
  ENCRYPTION_PORT,
} from './ports/agent-config.ports.ts';
import type {
  AgentConfigRepository,
  EncryptionPort,
  AgentTestingPort,
  AuditLoggerPort
} from './ports/agent-config.ports.ts';

// Adapters
import { PrismaAgentConfigRepository } from './adapters/prisma-agent-config.repository.ts';
import { AgentTestingService } from './adapters/agent-testing.service.ts';
import { InMemoryAuditLogger } from './adapters/in-memory-audit-logger.ts';

// Presentation
import { AgentConfigController } from './presentation/agent-config.http-controller.ts';

export class AgentConfigModule {}

Module({
  imports: [InfrastructureModule],
  controllers: [AgentConfigController],
  providers: [
    // Domain services
    AgentConfigDomainService,

    // Application services
    {
      provide: AgentConfigApplicationService,
      useFactory: (
        repository: AgentConfigRepository,
        encryption: EncryptionPort,
        agentTesting: AgentTestingPort,
        auditLogger: AuditLoggerPort,
        domainService: AgentConfigDomainService
      ) => {
        return new AgentConfigApplicationService(
          repository,
          encryption,
          agentTesting,
          auditLogger,
          domainService
        );
      },
      inject: [
        AGENT_CONFIG_REPOSITORY,
        ENCRYPTION_PORT,
        AGENT_TESTING_PORT,
        AUDIT_LOGGER_PORT,
        AgentConfigDomainService
      ]
    },

    {
      provide: AGENT_CONFIG_REPOSITORY,
      useFactory: (prisma: PrismaService) => {
        return new PrismaAgentConfigRepository(prisma);
      },
      inject: [PrismaService],
    },
    {
      provide: ENCRYPTION_PORT,
      useFactory: () => createEncryptionService(),
    },

    {
      provide: AGENT_TESTING_PORT,
      useClass: AgentTestingService
    },

    // Audit logger (default to in-memory)
    {
      provide: AUDIT_LOGGER_PORT,
      useClass: InMemoryAuditLogger
    }
  ],
  exports: [
    AgentConfigApplicationService,
    AGENT_CONFIG_REPOSITORY,
    ENCRYPTION_PORT,
    AGENT_TESTING_PORT,
    AUDIT_LOGGER_PORT
  ]
})(AgentConfigModule);

function createEncryptionService(): EncryptionService {
  const encryptionKey = process.env.AGENT_CONFIG_ENCRYPTION_KEY;

  if (encryptionKey) {
    return new EncryptionService(encryptionKey);
  }

  if (process.env.NODE_ENV === "production") {
    throw new Error("AGENT_CONFIG_ENCRYPTION_KEY environment variable is required in production mode.");
  }

  const devKeyFile = resolveDevEncryptionKeyFile();
  const persistedKey = readPersistedDevEncryptionKey(devKeyFile);
  if (persistedKey) {
    console.warn(
      `AGENT_CONFIG_ENCRYPTION_KEY not set. Loaded persistent development key from ${devKeyFile}.`,
    );
    return new EncryptionService(persistedKey);
  }

  const service = new EncryptionService();
  const generatedKey = service.generateKey();
  persistDevEncryptionKey(devKeyFile, generatedKey);
  console.warn(
    `AGENT_CONFIG_ENCRYPTION_KEY not set. Generated persistent development key at ${devKeyFile}.`,
  );
  return new EncryptionService(generatedKey);
}

function resolveDevEncryptionKeyFile(): string {
  const configuredPath = process.env.KIDMEMORY_AGENT_CONFIG_KEY_FILE?.trim();
  if (configuredPath) {
    return path.resolve(configuredPath);
  }
  return path.resolve(process.cwd(), ".kidmemory/data/agent-config.encryption.key");
}

function readPersistedDevEncryptionKey(filePath: string): string | null {
  try {
    const value = readFileSync(filePath, "utf8").trim();
    return value.length > 0 ? value : null;
  } catch {
    return null;
  }
}

function persistDevEncryptionKey(filePath: string, key: string) {
  mkdirSync(path.dirname(filePath), { recursive: true });
  writeFileSync(filePath, `${key}\n`, { encoding: "utf8", mode: 0o600 });
}
