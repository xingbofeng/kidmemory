import { Inject, Injectable } from "@nestjs/common";

import { MemoryDatasetDb, type SampleDb } from "./memory-dataset-db.ts";
import { PrismaDatasetDbService } from "./prisma-dataset-db.service.ts";

export class DatasetState<T> {
  private activeDb: T;
  private persistentDb?: T;
  private connectPersistentDb: () => Promise<T>;

  constructor(
    memoryDb: T,
    connectPersistentDb: () => Promise<T>,
  ) {
    this.activeDb = memoryDb;
    this.connectPersistentDb = connectPersistentDb;
  }

  async current() {
    return this.activeDb;
  }

  async activatePersistent() {
    this.persistentDb ||= await this.connectPersistentDb();
    this.activeDb = this.persistentDb;
    return this.activeDb;
  }
}

export class DatasetStateService extends DatasetState<SampleDb> {
  constructor(database?: PrismaDatasetDbService) {
    if (!database) throw new Error("PrismaDatasetDbService is required.");
    super(new MemoryDatasetDb(), () => database.connect());
  }
}

Inject(PrismaDatasetDbService)(DatasetStateService, undefined, 0);
Injectable()(DatasetStateService);
