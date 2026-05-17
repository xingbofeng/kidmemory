import { Injectable } from "@nestjs/common";
import { PrismaPg } from "@prisma/adapter-pg";
import * as PrismaClientModule from "@prisma/client";
import type { OnModuleDestroy, OnModuleInit } from "@nestjs/common";

function resolvePrismaClient() {
  const direct = (PrismaClientModule as { PrismaClient?: typeof PrismaClientModule.PrismaClient }).PrismaClient;
  const fallback = (PrismaClientModule as { default?: { PrismaClient?: typeof PrismaClientModule.PrismaClient } })
    .default?.PrismaClient;

  const client = direct ?? fallback;
  if (!client) {
    throw new Error("PrismaClient export not found in @prisma/client");
  }
  return client;
}

const PrismaClient = resolvePrismaClient();

function fallbackConnectionString(): string {
  const host = process.env.POSTGRES_HOST || "127.0.0.1";
  const port = process.env.POSTGRES_PORT || "5432";
  const database = process.env.POSTGRES_DATABASE || "kidmemory";
  const user = process.env.POSTGRES_USER || process.env.USER || "postgres";
  const password = process.env.POSTGRES_PASSWORD;
  const credentials = password
    ? `${encodeURIComponent(user)}:${encodeURIComponent(password)}`
    : encodeURIComponent(user);
  return `postgresql://${credentials}@${host}:${port}/${database}`;
}

export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  constructor() {
    super({
      adapter: new PrismaPg({
        connectionString: process.env.DATABASE_URL ?? process.env.POSTGRES_URL ?? fallbackConnectionString(),
      }),
    });
  }

  async onModuleInit() {
    if (!process.env.DATABASE_URL) {
      return;
    }
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}

Injectable()(PrismaService);
