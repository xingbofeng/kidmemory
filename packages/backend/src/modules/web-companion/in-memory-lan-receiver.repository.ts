import type { LanReceiverRepository } from "./lan-receiver.service.ts";
import type { LanSession } from "./lan-receiver.types.ts";

export class InMemoryLanReceiverRepository implements LanReceiverRepository {
  private readonly sessions = new Map<string, LanSession>();

  async saveLanSession(session: LanSession): Promise<void> {
    this.sessions.set(session.id, { ...session });
  }

  async getLanSessionById(sessionId: string): Promise<LanSession | null> {
    const session = this.sessions.get(sessionId);
    return session ? { ...session } : null;
  }

  async countReadyUploadsBySession(): Promise<number> {
    return 0;
  }

  async deleteExpiredSessions(now: Date): Promise<void> {
    for (const [sessionId, session] of this.sessions.entries()) {
      if (session.expiresAt < now) {
        this.sessions.delete(sessionId);
      }
    }
  }
}
