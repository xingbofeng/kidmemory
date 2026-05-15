import type { PrismaService } from "../../infrastructure/database/prisma.service.ts";
import type { LanReceiverRepository } from "./lan-receiver.service.ts";
import type { LanSession } from "./lan-receiver.types.ts";

export class PrismaLanReceiverRepository implements LanReceiverRepository {
  private readonly prisma: PrismaService;

  constructor(prisma: PrismaService) {
    this.prisma = prisma;
  }

  async saveLanSession(session: LanSession): Promise<void> {
    await this.prisma.lanSession.upsert({
      where: { id: session.id },
      create: {
        id: session.id,
        deviceId: session.deviceId,
        childId: session.childId,
        tokenHash: session.tokenHash,
        expiresAt: session.expiresAt,
        maxConcurrentUploads: session.maxConcurrentUploads,
        currentUploads: session.currentUploads,
        lastSeenAt: session.lastSeenAt ?? null,
      },
      update: {
        childId: session.childId,
        tokenHash: session.tokenHash,
        expiresAt: session.expiresAt,
        maxConcurrentUploads: session.maxConcurrentUploads,
        currentUploads: session.currentUploads,
        lastSeenAt: session.lastSeenAt ?? null,
      },
    });
  }

  async getLanSessionById(sessionId: string): Promise<LanSession | null> {
    const session = await this.prisma.lanSession.findUnique({
      where: { id: sessionId },
    });
    return session ? mapLanSession(session) : null;
  }

  async countReadyUploadsBySession(sessionId: string): Promise<number> {
    return this.prisma.lanUpload.count({
      where: {
        sessionId,
        status: "ready",
      },
    });
  }

  async deleteExpiredSessions(now: Date): Promise<void> {
    await this.prisma.lanSession.deleteMany({
      where: {
        expiresAt: { lt: now },
      },
    });
  }
}

function mapLanSession(session: {
  id: string;
  deviceId: string;
  childId: string;
  tokenHash: string;
  expiresAt: Date;
  createdAt: Date;
  lastSeenAt: Date | null;
  maxConcurrentUploads: number;
  currentUploads: number;
}): LanSession {
  return {
    id: session.id,
    deviceId: session.deviceId,
    childId: session.childId,
    tokenHash: session.tokenHash,
    expiresAt: session.expiresAt,
    createdAt: session.createdAt,
    lastSeenAt: session.lastSeenAt ?? undefined,
    maxConcurrentUploads: session.maxConcurrentUploads,
    currentUploads: session.currentUploads,
  };
}
