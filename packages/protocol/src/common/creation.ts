export type CreationType = "storybook" | "memory_book" | "memoir_video";

export type CreationTaskStatus =
  | "planning"
  | "ready"
  | "generating"
  | "succeeded"
  | "failed"
  | "exporting"
  | "exported"
  | "sharing"
  | "shared"
  | "cancelled";

export type CreationStepStatus = "pending" | "running" | "succeeded" | "failed" | "skipped";

export type CreationFailureCategory =
  | "asset_validation"
  | "planning"
  | "generation"
  | "skill"
  | "hyperframes"
  | "export"
  | "share"
  | "environment";

export interface CreationStep {
  stepId: string;
  label: string;
  status: CreationStepStatus;
  detail?: string;
}

export interface CreationPlanRequirements {
  minAssets: number;
  recommendedAssets: number;
  needsCloudImage: boolean;
  needsHyperframes: boolean;
  needsFfmpeg: boolean;
}

export interface CreationArtifact {
  artifactId: string;
  taskId: string;
  kind: "book_json" | "book_html" | "pdf" | "mp4" | "long_image_png" | "long_image_jpg" | "web_share";
  localPath?: string;
  shareId?: string;
  shareUrl?: string;
  createdAt: string;
}

export interface CreationError {
  category: CreationFailureCategory;
  message: string;
  stepId?: string;
  code?: string;
}

export interface CreationTask {
  taskId: string;
  creationType: CreationType;
  goal: string;
  assetIds: string[];
  status: CreationTaskStatus;
  currentStepId: string | null;
  summary?: string;
  skillName?: string;
  steps: CreationStep[];
  requirements: CreationPlanRequirements;
  requirementItems: string[];
  artifacts: CreationArtifact[];
  error: CreationError | null;
  workspacePath: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreationEvent {
  eventId: string;
  taskId: string;
  stepId?: string;
  type: "plan" | "task" | "step" | "export" | "share" | "error";
  message: string;
  createdAt: string;
}

export interface CreationExportArtifact {
  artifactId: string;
  taskId: string;
  kind: "book_json" | "book_html" | "pdf" | "mp4" | "long_image_png" | "long_image_jpg" | "web_share";
  localPath?: string;
  shareId?: string;
  shareUrl?: string;
  createdAt: string;
}
