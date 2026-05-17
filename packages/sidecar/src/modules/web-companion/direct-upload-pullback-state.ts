/**
 * Web Companion Supabase Direct Upload — `direct_upload_pullbacks` 状态机纯函数。
 *
 * 设计 D3 中状态机：
 *   pending_remote → downloading → ready
 *                 └────────────→ failed
 *   failed → downloading（重试）
 *
 * 这一层是**纯逻辑**，不与数据库或 HTTP 层耦合，便于独立测试与跨调用方复用。
 *
 * 注意：刻意使用 `as const` + union type 而不是 `enum`，与 sidecar 其它代码风格一致，
 *      并避免 Node 26 strip-only TS 模式不支持 enum 的问题。
 */

export const DIRECT_UPLOAD_PULLBACK_STATUSES = [
  "pending_remote",
  "downloading",
  "ready",
  "failed",
] as const;

export type DirectUploadPullbackStatus = (typeof DIRECT_UPLOAD_PULLBACK_STATUSES)[number];

const ALLOWED_TRANSITIONS: Record<DirectUploadPullbackStatus, DirectUploadPullbackStatus[]> = {
  pending_remote: ["downloading"],
  downloading: ["ready", "failed"],
  ready: [],
  failed: ["downloading"],
};

export interface DirectUploadPullbackRecord {
  id: string;
  sessionId: string;
  childId: string;
  objectKey: string;
  status: DirectUploadPullbackStatus;
  assetId: string | null;
  localPath: string | null;
  errorCode: string | null;
  errorMessage: string | null;
  pulledAt: string | null;
}

export type DirectUploadPullbackTransition =
  | { type: "begin_download" }
  | {
      type: "mark_ready";
      assetId: string;
      localPath: string;
      pulledAt: string;
    }
  | {
      type: "mark_failed";
      errorCode: string;
      errorMessage: string;
    };

export function isValidDirectUploadPullbackTransition(
  from: DirectUploadPullbackStatus,
  to: DirectUploadPullbackStatus,
): boolean {
  return ALLOWED_TRANSITIONS[from].includes(to);
}

/**
 * 在不可变记录上应用一次状态机转移；返回新记录。
 *
 * - 对终态 `ready` 重复 `mark_ready` 同字段保持幂等（no-op，原值返回）。
 * - 对成功路径 (`mark_ready`) 强制要求 `assetId` 与 `localPath` 非空。
 * - 对失败路径 (`mark_failed`) 强制要求 `errorCode` 与 `errorMessage` 非空，且**不**填充
 *   `assetId / localPath`，便于下一次 retry 幂等。
 * - 对非法状态转移直接抛错而非静默吞掉。
 */
export function applyDirectUploadPullbackTransition(
  record: DirectUploadPullbackRecord,
  transition: DirectUploadPullbackTransition,
): DirectUploadPullbackRecord {
  switch (transition.type) {
    case "begin_download": {
      // ready → downloading 是非法的（ready 是终态）；其它 from 必须允许 → downloading
      assertTransition(record.status, "downloading");
      return {
        ...record,
        status: "downloading",
        // 重试场景：清空上一次失败的诊断信息
        errorCode: null,
        errorMessage: null,
      };
    }
    case "mark_ready": {
      // 幂等：在 ready 上 mark_ready 同字段是 no-op
      if (
        record.status === "ready"
        && record.assetId === transition.assetId
        && record.localPath === transition.localPath
        && record.pulledAt === transition.pulledAt
      ) {
        return record;
      }
      assertTransition(record.status, "ready");
      if (!transition.assetId) {
        throw new DirectUploadPullbackTransitionError(
          "mark_ready transition requires non-empty assetId",
        );
      }
      if (!transition.localPath) {
        throw new DirectUploadPullbackTransitionError(
          "mark_ready transition requires non-empty localPath",
        );
      }
      return {
        ...record,
        status: "ready",
        assetId: transition.assetId,
        localPath: transition.localPath,
        pulledAt: transition.pulledAt,
        errorCode: null,
        errorMessage: null,
      };
    }
    case "mark_failed": {
      assertTransition(record.status, "failed");
      if (!transition.errorCode) {
        throw new DirectUploadPullbackTransitionError(
          "mark_failed transition requires non-empty errorCode",
        );
      }
      if (!transition.errorMessage) {
        throw new DirectUploadPullbackTransitionError(
          "mark_failed transition requires non-empty errorMessage",
        );
      }
      return {
        ...record,
        status: "failed",
        errorCode: transition.errorCode,
        errorMessage: transition.errorMessage,
        // 失败时刻意不填充 assetId / localPath，保留 retry 幂等
        assetId: null,
        localPath: null,
      };
    }
    default: {
      // 编译期 exhaustive check
      const _exhaustive: never = transition;
      throw new DirectUploadPullbackTransitionError(
        `unknown transition: ${JSON.stringify(_exhaustive)}`,
      );
    }
  }
}

export class DirectUploadPullbackTransitionError extends Error {
  readonly code = "direct_upload_pullback_invalid_transition" as const;
  constructor(message: string) {
    super(message);
    this.name = "DirectUploadPullbackTransitionError";
  }
}

function assertTransition(
  from: DirectUploadPullbackStatus,
  to: DirectUploadPullbackStatus,
): void {
  if (!isValidDirectUploadPullbackTransition(from, to)) {
    throw new DirectUploadPullbackTransitionError(
      `invalid direct_upload_pullbacks transition: ${from} → ${to}`,
    );
  }
}
