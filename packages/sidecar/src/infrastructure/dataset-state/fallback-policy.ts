export function allowInMemoryDatasetFallback(): boolean {
  if (process.env.KIDMEMORY_ALLOW_IN_MEMORY_DATASET_FALLBACK === "true") return true;
  return process.env.NODE_ENV !== "production";
}
