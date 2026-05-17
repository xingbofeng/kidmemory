/**
 * Sidecar API contract entrypoint.
 *
 * This subpath re-exports the generated OpenAPI types for the local sidecar
 * HTTP surface so consumers can import from `@kidmemory/protocol/sidecar`
 * instead of reaching into generated paths directly.
 */
export type * from '../../generated/sidecar/ts/index.js';
