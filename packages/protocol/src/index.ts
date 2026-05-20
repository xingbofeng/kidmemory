/**
 * Protocol 包主入口。
 *
 * 这里保留通用基础类型；具体 API contract 从 `./sidecar` 和
 * `./cloud-api` 子路径导出，避免生成类型命名冲突。
 */

// 通用类型
export { ApiCode } from './common/api-code.js';
export type { ApiResponse, PageData } from './common/api-response.js';
export type {
  CreationArtifact,
  CreationError,
  CreationEvent,
  CreationFailureCategory,
  CreationJob,
  CreationJobStatus,
  CreationPlan,
  CreationPlanStatus,
  CreationStep,
  CreationStepStatus,
  CreationType,
} from './common/creation.js';
export type { Locale } from './common/locale.js';
export { SUPPORTED_LOCALES, DEFAULT_LOCALE, isValidLocale } from './common/locale.js';
