export type CreationType = "storybook" | "memory_book" | "memoir_video";

export type CreationPlanStatus = "ready" | "invalidated";

export type CreationJobStatus =
  | "creating"
  | "running"
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

export interface CreationPlan {
  planId: string;
  creationType: CreationType;
  goal: string;
  assetIds: string[];
  summary: string;
  skillName: string;
  steps: CreationStep[];
  requirements: CreationPlanRequirements;
  requirementItems: string[];
  status: CreationPlanStatus;
  createdAt: string;
  updatedAt: string;
}

export interface CreationArtifact {
  artifactId: string;
  kind: "pdf" | "mp4" | "web_share";
  jobId: string;
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

export interface CreationJob {
  jobId: string;
  planId: string;
  creationType: CreationType;
  status: CreationJobStatus;
  currentStepId: string | null;
  steps: CreationStep[];
  artifacts: CreationArtifact[];
  error: CreationError | null;
  createdAt: string;
  updatedAt: string;
}

export interface CreationEvent {
  eventId: string;
  jobId: string;
  stepId?: string;
  type: "plan" | "job" | "step" | "export" | "share" | "error";
  message: string;
  createdAt: string;
}
