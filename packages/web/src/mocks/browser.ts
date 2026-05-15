import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

// 这配置了一个 Service Worker，用于在开发环境中拦截网络请求
export const worker = setupWorker(...handlers)