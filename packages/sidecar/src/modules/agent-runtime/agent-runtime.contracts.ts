export type RuntimeStage = "plan" | "generate_book" | "generate_video";

export type RunCreationStageInput = {
  taskId: string;
  workspacePath: string;
  stage: RuntimeStage;
  creationType: "storybook" | "memory_book" | "memoir_video";
  prompt: string;
  traceId: string;
  metadata?: Record<string, unknown>;
};

export type RunCreationStageResult = {
  ok: boolean;
  runId?: string;
  sessionId?: string;
  error?: {
    category: string;
    message: string;
    code?: string;
  };
  summary?: string;
};

export const REQUIRED_OUTPUT_FILES_BY_STAGE: Record<RuntimeStage, string[]> = {
  plan: ["output/plan.json"],
  generate_book: ["output/book.json", "output/book.html"],
  generate_video: ["output/video.mp4"],
};

export const STAGE_TIMEOUT_PLAN_MS = 5 * 60 * 1000;
export const STAGE_TIMEOUT_GENERATE_BOOK_MS = 15 * 60 * 1000;
export const STAGE_TIMEOUT_GENERATE_VIDEO_MS = 15 * 60 * 1000;

export const RUNTIME_EVENT_TO_CREATION_EVENT_TYPE: Record<string, string> = {
  "agent.run.started": "plan",
  "agent.run.finished": "task",
  "agent.run.failed": "error",
  "agent.tool.started": "step",
  "agent.tool.finished": "step",
  "agent.tool.failed": "error",
  "agent.artifact.detected": "task",
};
