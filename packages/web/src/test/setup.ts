import '@testing-library/jest-dom'
import { beforeAll, afterEach, afterAll } from 'vitest'
import { setupServer } from 'msw/node'
import { handlers } from './mocks/handlers'
import '../i18n'

// Setup MSW server for API mocking
export const server = setupServer(...handlers)
const originalConsoleError = console.error

function isReactActWarning(firstArg: unknown): firstArg is string {
  return typeof firstArg === 'string' && firstArg.includes('not wrapped in act')
}

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
beforeAll(() => {
  console.error = (...args: unknown[]) => {
    if (isReactActWarning(args[0])) {
      throw new Error(`React act warning detected: ${args[0]}`)
    }
    originalConsoleError(...args)
  }
})
afterEach(() => server.resetHandlers())
afterAll(() => {
  server.close()
  console.error = originalConsoleError
})
