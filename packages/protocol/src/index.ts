/**
 * Protocol 包主入口
 *
 * 导出所有公共 API
 */

// 通用类型
export { ApiCode } from './common/api-code.js';
export type { ApiResponse, PageData } from './common/api-response.js';
export type { Locale } from './common/locale.js';
export { SUPPORTED_LOCALES, DEFAULT_LOCALE, isValidLocale } from './common/locale.js';

// Sidecar API 类型
export * from './sidecar/index.js';

// Cloud API 类型
export * from './cloud-api/index.js';
