// Reuse the same MSW handlers in development (browser worker) and tests (Node).
// Source of truth lives under src/test/mocks/handlers.ts so the two
// environments cannot drift.
export { handlers } from '../test/mocks/handlers'
